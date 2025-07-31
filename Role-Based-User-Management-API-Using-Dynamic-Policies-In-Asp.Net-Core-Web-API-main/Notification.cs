using Microsoft.AspNetCore.Identity;
using WebApiWithRoleAuthentication.Domain.Enums;
namespace WebApiWithRoleAuthentication.Domain;



public class Notification
{
    public Guid Id { get; set; } = Guid.NewGuid();

    // receiver
    public string UserId { get; set; } = default!;
    public IdentityUser User { get; set; } = default!;

    public NotificationType Type { get; set; }
    public NotificationStatus Status { get; set; } = NotificationStatus.Unread;

    // JSON blob – flexible for every notification kind
    // for Invite we’ll store { projectId, projectName }
    public string PayloadJson { get; set; } = default!;

    public DateTime CreatedUtc { get; set; } = DateTime.UtcNow;
}
