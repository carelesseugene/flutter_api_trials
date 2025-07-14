// Controllers/ProjectsController.cs
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
    private readonly UserManager<IdentityUser> _um;

    public ProjectsController(AppDbContext db, UserManager<IdentityUser> um)
        => (_db, _um) = (db, um);

    /* ---------- actions that use the DTOs ---------- */

    [HttpPost]
    public async Task<ActionResult<ProjectSummaryDto>> Create(CreateProjectDto dto)
    {
        var user = await _um.GetUserAsync(User);
        var project = new Project
        {
            Name = dto.Name,
            Description = dto.Description,
            Members =
            {
                new ProjectMember { UserId = user!.Id, Role = ProjectRole.Lead }
            },
            Columns =
            {
                new BoardColumn { Title = "To Do",       Position = 0 },
                new BoardColumn { Title = "In Progress", Position = 1 },
                new BoardColumn { Title = "Done",        Position = 2 }
            }
        };
        _db.Projects.Add(project);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(Get), new { id = project.Id },
            new ProjectSummaryDto(project.Id, project.Name));
    }

    [HttpGet]
    public async Task<IReadOnlyList<ProjectSummaryDto>> List()
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        return await _db.ProjectMembers
                        .Where(pm => pm.UserId == uid)
                        .Select(pm => new ProjectSummaryDto(pm.ProjectId, pm.Project.Name))
                        .ToListAsync();
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ProjectDetailsDto>> Get(Guid id)
    {
        var proj = await _db.Projects
            .Include(p => p.Columns.OrderBy(c => c.Position))
            .Include(p => p.Members).ThenInclude(m => m.User)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (proj == null) return NotFound();

        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        if (!proj.Members.Any(m => m.UserId == uid)) return Forbid();

        return new ProjectDetailsDto(
            proj.Id, proj.Name, proj.Description,
            proj.Columns.Select(c => new ColumnDto(c.Id, c.Title, c.Position)).ToList(),
            proj.Members.Select(m =>
                new MemberDto(m.UserId, m.User.Email!, m.Role)).ToList());
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(pm => pm.ProjectId == id && pm.UserId == uid);

        if (member is null || member.Role != ProjectRole.Lead)
            return Forbid();

        var proj = await _db.Projects.FindAsync(id);
        _db.Remove(proj!);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
