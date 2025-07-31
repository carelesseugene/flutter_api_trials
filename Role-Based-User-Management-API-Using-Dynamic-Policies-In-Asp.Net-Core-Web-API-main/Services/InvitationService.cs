using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Services.Interfaces;

namespace WebApiWithRoleAuthentication.Services
{
    public class InvitationService : IInvitationService
    {
        private readonly AppDbContext _db;

        public InvitationService(AppDbContext db)
        {
            _db = db;
        }

        // Create an invitation and return the invited user's ID
        public async Task<string> CreateInviteAsync(Guid projectId, string senderId, string email)
        {
            // Find the user by email
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null)
                throw new Exception("User with given email not found");

            // Optionally, create a ProjectInvitation or similar row here if you track pending invites

            // (You might add the user as a pending member, or just send a notification)
            // For now, just return the user's Id
            return user.Id;
        }

        // Handle invite decision (accept/decline)
        public async Task HandleDecisionAsync(Guid notificationId, string userId, bool accept)
        {
            // Optionally, fetch notification to validate

            if (accept)
            {
                // Add user as a project member if not already present
                // (Assume you have a ProjectMembers table/entity)

                // Example:
                // var notification = await _db.Notifications.FindAsync(notificationId);
                // if (notification == null) throw new Exception("Notification not found");
                // var projectId = ... (deserialize notification.PayloadJson)
                // var exists = await _db.ProjectMembers.AnyAsync(m => m.ProjectId == projectId && m.UserId == userId);
                // if (!exists)
                // {
                //     _db.ProjectMembers.Add(new ProjectMember { ProjectId = projectId, UserId = userId });
                //     await _db.SaveChangesAsync();
                // }

                // For now, just simulate
                await Task.CompletedTask;
            }
            else
            {
                // Decline: optionally set a flag, send a notification, etc.
                await Task.CompletedTask;
            }
        }
    }
}
