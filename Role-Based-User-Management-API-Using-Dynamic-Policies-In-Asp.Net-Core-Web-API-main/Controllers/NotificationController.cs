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

namespace WebApiWithRoleAuthentication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly IHubContext<BoardHub>? _hub; // Now nullable for safety

        // Only this constructor!
        public NotificationsController(AppDbContext db, IHubContext<BoardHub> hub)
            => (_db, _hub) = (db, hub);

        [HttpGet]
        public async Task<IEnumerable<object>> Get()
        {
            var uid = User.GetUserId();

            var list = await _db.Notifications
                .Where(n => n.UserId == uid && n.Status != NotificationStatus.Actioned)
                .OrderByDescending(n => n.CreatedUtc)
                .ToListAsync();

            // Filter out invites for projects that don't exist
            var filtered = new List<Notification>();
            foreach (var n in list)
            {
                if (n.Type == NotificationType.Invite)
                {
                    // Get projectId from payload
                    var payload = JsonSerializer.Deserialize<Dictionary<string, object>>(n.PayloadJson);
                    if (payload != null && payload.TryGetValue("projectId", out var projIdObj))
                    {
                        Guid projId;
                        if (Guid.TryParse(projIdObj.ToString(), out projId))
                        {
                            var projectExists = _db.Projects.Any(p => p.Id == projId);
                            if (!projectExists)
                                continue; // Skip this notification!
                        }
                    }
                }
                filtered.Add(n);
            }

            return filtered.Select(n => new
            {
                n.Id,
                type = (int)n.Type,
                status = (int)n.Status,
                n.CreatedUtc,
                payload = JsonSerializer.Deserialize<object>(n.PayloadJson)
            });
        }


        [HttpPost("{projectId:guid}/invites/{decision:regex(accept|reject)}")]
        public async Task<IActionResult> Decide(Guid projectId, string decision)
        {
            var uid = User.GetUserId();
            var invite = await _db.ProjectInvitations.FindAsync(projectId, uid);

            // If invite is gone (e.g. project deleted), action notification anyway
            if (invite is null)
            {
                var notif = await _db.Notifications.FirstOrDefaultAsync(n =>
                    n.UserId == uid &&
                    n.Type == NotificationType.Invite &&
                    n.PayloadJson.Contains(projectId.ToString()));
                if (notif != null)
                {
                    notif.Status = NotificationStatus.Actioned;
                    await _db.SaveChangesAsync();
                }
                return NotFound();
            }

            if (invite.Status != ProjectInvitation.InvitationStatus.Pending)
                return NotFound();

            invite.Status = decision == "accept"
                ? ProjectInvitation.InvitationStatus.Accepted
                : ProjectInvitation.InvitationStatus.Rejected;

            // mark notification actioned
            var notification = await _db.Notifications.FirstAsync(n =>
                n.UserId == uid &&
                n.Type == NotificationType.Invite &&
                n.PayloadJson.Contains(projectId.ToString()));
            notification.Status = NotificationStatus.Actioned;

            if (decision == "accept")
            {
                _db.ProjectMembers.Add(new ProjectMember
                {
                    ProjectId = projectId,
                    UserId = uid,
                    Role = ProjectRole.Member
                });
            }

            await _db.SaveChangesAsync();

            // Try SignalR (optional, as before)
            if (decision == "accept" && _hub != null)
            {
                try
                {
                    await _hub.Clients.Group($"project-{projectId}").SendAsync("MemberAdded", new
                    {
                        userId = uid,
                        email = User.Identity!.Name,
                        role = ProjectRole.Member
                    });
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[SignalR] Error broadcasting member: {ex}");
                }
            }
            return NoContent();
        }

    }
}
