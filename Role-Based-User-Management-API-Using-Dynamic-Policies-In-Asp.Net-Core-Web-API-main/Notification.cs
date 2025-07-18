using Microsoft.AspNetCore.Identity;

namespace ProjectManagement.Domain;

public enum NotificationType { Invite = 0 /* future: Comment, CardMoved … */ }
public enum NotificationStatus { Unread = 0, Read = 1, Actioned = 2 }

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
