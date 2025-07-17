using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApiWithRoleAuthentication.DTOs;
using ProjectManagement.Domain;
using WebApiWithRoleAuthentication.Data;

namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProjectsController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly UserManager<IdentityUser> _userManager;

    public ProjectsController(AppDbContext db, UserManager<IdentityUser> um)
        => (_db, _userManager) = (db, um);

    // ---------- List projects current user is member of ----------
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

    // ---------- Get details of a single project ----------
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

    // ---------- Create new project ----------
    [HttpPost]
    public async Task<ActionResult<ProjectSummaryDto>> Create(CreateProjectDto dto)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var user = await _userManager.FindByIdAsync(uid);

        var project = new Project {
            Name = dto.Name,
            Description = dto.Description,
            CreatedByUserId = uid,
            Members = {
                new ProjectMember { UserId = uid, Role = ProjectRole.Lead }
            }
        };
        _db.Projects.Add(project);
        await _db.SaveChangesAsync();

        return Created("", new ProjectSummaryDto(
            project.Id, project.Name, user!.Email!, 1));
    }

    // ---------- Delete a project (lead only) ----------
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
}
