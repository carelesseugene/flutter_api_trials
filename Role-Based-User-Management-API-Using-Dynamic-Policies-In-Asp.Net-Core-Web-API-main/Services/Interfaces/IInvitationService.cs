namespace WebApiWithRoleAuthentication.Services.Interfaces;

public interface IInvitationService
{
    Task<string> CreateInviteAsync(Guid projectId, string senderId, string email);
    Task HandleDecisionAsync(Guid notificationId, string userId, bool accept);
}
