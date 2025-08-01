using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.SignalR;
using WebApiWithRoleAuthentication.DTOs;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Hubs;
using WebApiWithRoleAuthentication.Extensions;
using WebApiWithRoleAuthentication.Domain;
using WebApiWithRoleAuthentication.Domain.Enums;


namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProjectsController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly UserManager<IdentityUser> _userManager;
    private readonly IHubContext<BoardHub> _hub = null!;

    public ProjectsController(
        AppDbContext db,
        UserManager<IdentityUser> um,
        IHubContext<BoardHub> hub)
    {
        _db = db;
        _userManager = um;
        _hub = hub;
    }

    /* ------------------------------------------------------------------
       List projects the current user is member of
       ------------------------------------------------------------------ */
    [HttpGet]
    public async Task<IReadOnlyList<ProjectSummaryDto>> List()
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        return await _db.ProjectMembers
            .Where(pm => pm.UserId == uid)
            .Include(pm => pm.Project)
                .ThenInclude(p => p.CreatedBy)
            .Include(pm => pm.Project)
                .ThenInclude(p => p.Members)
            .Select(pm => new ProjectSummaryDto(
                pm.ProjectId,
                pm.Project.Name,
                pm.Project.CreatedBy.Email!,
                pm.Project.Members.Count))
            .ToListAsync();
    }

    /* ------------------------------------------------------------------
       Get details of a single project
       ------------------------------------------------------------------ */
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ProjectDetailsDto>> Get(Guid id)
    {
        var proj = await _db.Projects
            .Include(p => p.CreatedBy)
            .Include(p => p.Members).ThenInclude(m => m.User)
            .Include(p => p.Columns)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (proj == null) return NotFound();

        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        if (!proj.Members.Any(m => m.UserId == uid)) return Forbid();

        return new ProjectDetailsDto(
            proj.Id,
            proj.Name,
            proj.Description,
            proj.CreatedBy.Email!,
            proj.Members.Select(m =>
                new MemberDto(m.UserId, m.User.Email!, m.Role)).ToList(),
            proj.Columns
                .OrderBy(c => c.Position)
                .Select(c => new ColumnDto(c.Id, c.Title, c.Position))
                .ToList());
    }

    /* ------------------------------------------------------------------
       Create new project
       ------------------------------------------------------------------ */
    [HttpPost]
    public async Task<ActionResult<ProjectSummaryDto>> Create(CreateProjectDto dto)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var user = await _userManager.FindByIdAsync(uid);

        var project = new Project
        {
            Name = dto.Name,
            Description = dto.Description,
            CreatedByUserId = uid,
            Members =
            {
                new ProjectMember { UserId = uid, Role = ProjectRole.Lead }
            }
        };
        _db.Projects.Add(project);
        await _db.SaveChangesAsync();

        return Created(string.Empty, new ProjectSummaryDto(
            project.Id, project.Name, user!.Email!, 1));
    }

    /* ------------------------------------------------------------------
       Delete a project (lead only)
       ------------------------------------------------------------------ */
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(pm => pm.ProjectId == id && pm.UserId == uid);

        if (member is null || member.Role != ProjectRole.Lead)
            return Forbid();

        var proj = await _db.Projects.FindAsync(id);
        if (proj == null) return NotFound();

        _db.Remove(proj);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    /* ------------------------------------------------------------------
       INVITE MEMBER  (owner/lead only)
       ------------------------------------------------------------------ */
    public record InviteRequest(string Email);
[Authorize(Policy = "CanManageProject")]
[HttpPost("{projectId:guid}/invite")]
public async Task<IActionResult> Invite(Guid projectId, [FromBody] InviteRequest body)
{
    var emailRaw = body.Email.Trim();
    var normalized = emailRaw.ToUpperInvariant();

    var invitee = await _userManager.Users
        .AsNoTracking()
        .SingleOrDefaultAsync(u =>
            u.NormalizedEmail == normalized ||
            u.Email == emailRaw);

    if (invitee == null)
        return NotFound("User not found");

    var exists = await _db.ProjectInvitations.FindAsync(projectId, invitee.Id);
    if (exists is not null && exists.Status == ProjectInvitation.InvitationStatus.Pending)
        return Conflict("Already invited");

    // Add records
    var invitation = new ProjectInvitation
    {
        ProjectId = projectId,
        UserId = invitee.Id
    };
    _db.ProjectInvitations.Add(invitation);

    var project = await _db.Projects.FindAsync(projectId);
    var notif = new Notification
    {
        UserId = invitee.Id,
        Type = NotificationType.Invite,
        PayloadJson = JsonSerializer.Serialize(new
        {
            projectId,
            projectName = project?.Name ?? "(unknown)"
        })
    };
    _db.Notifications.Add(notif);

    try
    {
        await _db.SaveChangesAsync();
        Console.WriteLine("Invite & notification successfully added!");
    }
    catch (Exception ex)
    {
        Console.WriteLine("DB Save Error: " + ex.Message);
        return StatusCode(500, ex.Message);
    }

    return Ok();
}


// For members (including owner, but frontend should block owner from self-removal)
[HttpDelete("{projectId:guid}/leave")]
public async Task<IActionResult> Leave(Guid projectId)
{
    var uid = User.GetUserId();
    var member = await _db.ProjectMembers
        .FirstOrDefaultAsync(pm => pm.ProjectId == projectId && pm.UserId == uid);
    if (member == null) return NotFound();
    // Prevent owner from leaving via this route
    if (member.Role == ProjectRole.Lead)
        return BadRequest("Owner cannot leave; must delete project or transfer ownership.");
    _db.ProjectMembers.Remove(member);
    await _db.SaveChangesAsync();
    return NoContent();
}

// For owner to remove a member
[HttpDelete("{projectId:guid}/members/{userId}")]
public async Task<IActionResult> RemoveMember(Guid projectId, string userId)
{
    var uid = User.GetUserId();
    var owner = await _db.ProjectMembers
        .FirstOrDefaultAsync(pm => pm.ProjectId == projectId && pm.UserId == uid && pm.Role == ProjectRole.Lead);
    if (owner == null) return Forbid(); // Only owner allowed

    // Prevent removing self (owner)
    if (userId == uid) return BadRequest("Owner cannot remove themselves.");

    var member = await _db.ProjectMembers
        .FirstOrDefaultAsync(pm => pm.ProjectId == projectId && pm.UserId == userId);
    if (member == null) return NotFound();
    _db.ProjectMembers.Remove(member);
    await _db.SaveChangesAsync();
    return NoContent();
}



}
