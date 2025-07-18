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
using ProjectManagement.Domain;


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
        var normalized= _userManager.NormalizeEmail(body.Email.Trim());
        var invitee = await _userManager.Users
        .SingleOrDefaultAsync(u => u.NormalizedEmail == normalized);
        if (invitee is null) return NotFound("User not found");

        var exists = await _db.ProjectInvitations.FindAsync(projectId, invitee.Id);
        if (exists is not null && exists.Status == ProjectInvitation.InvitationStatus.Pending)
            return Conflict("Already invited");

        // record invitation
        _db.ProjectInvitations.Add(new ProjectInvitation
        {
            ProjectId = projectId,
            UserId    = invitee.Id
        });

        // create notification
        var project = await _db.Projects.FindAsync(projectId);
        var notif = new Notification
        {
            UserId      = invitee.Id,
            Type        = NotificationType.Invite,
            PayloadJson = JsonSerializer.Serialize(new
            {
                projectId,
                projectName = project!.Name
            })
        };
        _db.Notifications.Add(notif);
        await _db.SaveChangesAsync();

        // push real-time via SignalR
        await _hub.Clients.User(invitee.Id)
            .SendAsync("NotificationAdded", new
            {
                notif.Id,
                notif.Type,
                notif.Status,
                notif.CreatedUtc,
                payload = JsonSerializer.Deserialize<object>(notif.PayloadJson)
            });

        return Ok();
    }
}
