using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;

public class ProjectInvitation
{
    public Guid ProjectId { get; set; }
    public Project Project { get; set; } = default!;

    public string UserId { get; set; } = default!;
    public IdentityUser User { get; set; } = default!;

    public InvitationStatus Status { get; set; } = InvitationStatus.Pending;
    public DateTime CreatedUtc { get; set; } = DateTime.UtcNow;

    public enum InvitationStatus { Pending = 0, Accepted = 1, Rejected = 2 }
}
