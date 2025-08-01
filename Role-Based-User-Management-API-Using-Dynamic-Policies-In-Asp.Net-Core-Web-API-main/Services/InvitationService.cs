using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Services.Interfaces;
using WebApiWithRoleAuthentication.Domain;
using System.Text.Json;


namespace WebApiWithRoleAuthentication.Services
{
    public class InvitationService : IInvitationService
    {
        private readonly AppDbContext _db;
        public InvitationService(AppDbContext db) => _db = db;

        // ──────────────────────────────────────────────────────────────────────────
        // Creates (or resets) a pending invitation and returns the INVITEE’s userId
        // ──────────────────────────────────────────────────────────────────────────
        public async Task<string> CreateInviteAsync(Guid projectId, string senderId, string email)
        {
            // 1) Find user by e-mail
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == email);
            if (user == null) throw new Exception("User not found");

            // 2) Already a member?
            var alreadyMember = await _db.ProjectMembers
                .AnyAsync(m => m.ProjectId == projectId && m.UserId == user.Id);
            if (alreadyMember) throw new Exception("User is already a project member");

            // 3) Existing invitation?
            var invite = await _db.ProjectInvitations
                .SingleOrDefaultAsync(i => i.ProjectId == projectId && i.UserId == user.Id);

            if (invite != null)
            {
                if (invite.Status == ProjectInvitation.InvitationStatus.Pending)
                    throw new Exception("User already invited and pending");

                // Re-invite previously rejected / accepted user
                invite.Status     = ProjectInvitation.InvitationStatus.Pending;
                invite.CreatedUtc = DateTime.UtcNow;
            }
            else
            {
                invite = new ProjectInvitation
                {
                    ProjectId  = projectId,
                    UserId     = user.Id,
                    Status     = ProjectInvitation.InvitationStatus.Pending,
                    CreatedUtc = DateTime.UtcNow
                };
                _db.ProjectInvitations.Add(invite);
            }

            await _db.SaveChangesAsync();
            return user.Id;   // ← controller uses this to build the notification
        }

        // ──────────────────────────────────────────────────────────────────────────
        // Accept / decline a pending invite (uses userId + project lookup)
        // ──────────────────────────────────────────────────────────────────────────
        public async Task HandleDecisionAsync(Guid notificationId, string userId, bool accept)
        {
            // Find the pending invite for THIS user
               // Get the projectId from the notification payload
                var notif = await _db.Notifications.FindAsync(notificationId)
                        ?? throw new Exception("Notification not found");
                var projectId = JsonDocument.Parse(notif.PayloadJson)
                                .RootElement.GetProperty("projectId").GetGuid();

                var invite = await _db.ProjectInvitations
                    .SingleOrDefaultAsync(i =>
                        i.ProjectId == projectId &&
                        i.UserId   == userId   &&
                        i.Status   == ProjectInvitation.InvitationStatus.Pending);

            if (invite == null) throw new Exception("No pending invitation found");

            if (accept)
            {
                var isMember = await _db.ProjectMembers
                    .AnyAsync(m => m.ProjectId == invite.ProjectId && m.UserId == userId);

                if (!isMember)
                {
                    _db.ProjectMembers.Add(new ProjectMember
                    {
                        ProjectId = invite.ProjectId,
                        UserId    = userId,
                        Role      = ProjectRole.Member
                    });
                }
                invite.Status = ProjectInvitation.InvitationStatus.Accepted;
            }
            else
            {
                invite.Status = ProjectInvitation.InvitationStatus.Rejected;
            }

            await _db.SaveChangesAsync();
        }
    }
}
