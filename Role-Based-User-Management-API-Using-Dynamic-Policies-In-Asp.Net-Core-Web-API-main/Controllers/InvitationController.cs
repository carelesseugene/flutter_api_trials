using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
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
        _invites = inv;
        _notifs = n;
    }

    [HttpPost] // send invite
    public async Task<IActionResult> Send(Guid projectId, [FromBody] InviteDto dto)
    {
        // Use NameIdentifier claim (the user ID)
        var senderId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? throw new Exception("UserId claim missing in token");

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
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? throw new Exception("UserId claim missing in token");

        await _invites.HandleDecisionAsync(notificationId, userId, dto.Accept);

        await _notifs.MarkActionedAsync(notificationId);
        return NoContent();
    }
}
