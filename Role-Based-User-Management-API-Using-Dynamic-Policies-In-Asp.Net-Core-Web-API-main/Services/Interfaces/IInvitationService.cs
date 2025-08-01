namespace WebApiWithRoleAuthentication.Services.Interfaces
{
    public interface IInvitationService
    {
        // Return INVITEE's userId (string) – matches existing DB schema
        Task<string> CreateInviteAsync(Guid projectId, string senderId, string email);

        // notificationId is fine to keep as Guid
        Task HandleDecisionAsync(Guid notificationId, string userId, bool accept);
    }
}
