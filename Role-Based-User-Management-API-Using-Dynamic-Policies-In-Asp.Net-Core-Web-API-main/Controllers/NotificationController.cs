using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectManagement.Domain;
using WebApiWithRoleAuthentication.Data;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.SignalR;
using WebApiWithRoleAuthentication.Hubs;
using WebApiWithRoleAuthentication.Extensions;
using ProjectManagement.Domain;

namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _db;
    public NotificationsController(AppDbContext db) => _db = db;
    private readonly IHubContext<BoardHub> _hub=null!;

    public NotificationsController(AppDbContext db, IHubContext<BoardHub> hub)
        => (_db, _hub) = (db, hub);


    [HttpGet]
    public async Task<IEnumerable<object>> Get()
    {
        var uid = User.GetUserId();
        var list = await _db.Notifications
                        .Where(n => n.UserId == uid)
                        .OrderByDescending(n => n.CreatedUtc)
                        .ToListAsync();

    // switch to LINQ‑to‑Objects so JsonSerializer runs in memory
    return list.Select(n => new {
                 n.Id,
                 n.Type,
                 n.Status,
                 n.CreatedUtc,
                 payload = JsonSerializer.Deserialize<object>(n.PayloadJson)
             });
    }

    [HttpPost("{projectId:guid}/invites/{decision:regex(accept|reject)}")]
    public async Task<IActionResult> Decide(Guid projectId, string decision)
    {
        var uid = User.GetUserId();
        var invite = await _db.ProjectInvitations.FindAsync(projectId, uid);
        if (invite is null || invite.Status != ProjectInvitation.InvitationStatus.Pending)
            return NotFound();

        invite.Status = decision == "accept"
                        ? ProjectInvitation.InvitationStatus.Accepted
                        : ProjectInvitation.InvitationStatus.Rejected;

        // mark notification actioned
        var notif = await _db.Notifications.FirstAsync(n =>
            n.UserId == uid &&
            n.Type == NotificationType.Invite &&
            n.PayloadJson.Contains(projectId.ToString()));
        notif.Status = NotificationStatus.Actioned;

        if (decision == "accept")
        {
        _db.ProjectMembers.Add(new ProjectMember {
        ProjectId = projectId,
        UserId    = uid,
        Role      = ProjectRole.Member });
        }

        await _db.SaveChangesAsync();

        if (decision == "accept")
        {
            // broadcast new member
            await _hub.Clients.Group($"project-{projectId}").SendAsync("MemberAdded", new {
        userId = uid,
        email  = User.Identity!.Name,
        role   = ProjectRole.Member
    });
        }
        return NoContent();
    }
}
