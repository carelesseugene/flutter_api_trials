using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApiWithRoleAuthentication.Services.Interfaces;
using WebApiWithRoleAuthentication.Domain.Enums;
using WebApiWithRoleAuthentication.Domain.Dtos;

namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("api/projects/{projectId:guid}/invitations")]
[Authorize]
public class InvitationsController : ControllerBase
{
    private readonly IInvitationService _invites;
    private readonly INotificationService _notifs;

    public InvitationsController(IInvitationService inv, INotificationService n)
    {
        _invites = inv; _notifs = n;
    }

    [HttpPost] // send invite
    public async Task<IActionResult> Send(Guid projectId, [FromBody] InviteDto dto)
    {
        var senderId = User.FindFirst("sub")!.Value;

        var targetUserId = await _invites.CreateInviteAsync(projectId, senderId, dto.Email);

        await _notifs.AddAsync(
            targetUserId,
            NotificationType.Invite,
            new { projectId, projectName = dto.ProjectName });

        return Ok();
    }

    // accept / decline by acting on the *notification* row
    [HttpPost("~/api/invitations/{notificationId:guid}/decision")]
    public async Task<IActionResult> Decide(Guid notificationId, [FromBody] DecisionDto dto)
    {
        var userId = User.FindFirst("sub")!.Value;
        await _invites.HandleDecisionAsync(notificationId, userId, dto.Accept);

        await _notifs.MarkActionedAsync(notificationId);
        return NoContent();
    }
}
