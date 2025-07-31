using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Domain.Enums;
using WebApiWithRoleAuthentication.Services.Interfaces;

namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly INotificationService _service;
    public NotificationsController(AppDbContext db, INotificationService svc)
    {
        _db = db; _service = svc;
    }

    // GET /api/notifications?unreadOnly=true&page=1&pageSize=30
    [HttpGet]
    public async Task<IActionResult> List(bool unreadOnly = false,
                                          int page = 1,
                                          int pageSize = 30)
    {
        var uid = User.FindFirst("sub")!.Value;

        var q = _db.Notifications.Where(n => n.UserId == uid);
        if (unreadOnly)
            q = q.Where(n => n.Status == NotificationStatus.Unread);

        var list = await q.OrderByDescending(n => n.CreatedUtc)
                          .Skip((page - 1) * pageSize)
                          .Take(pageSize)
                          .Select(n => new
                          {
                              n.Id,
                              n.Type,
                              n.Status,
                              n.PayloadJson,
                              n.CreatedUtc
                          })
                          .ToListAsync();

        return Ok(list);
    }

    [HttpPatch("{id:guid}/read")]
    public async Task<IActionResult> MarkRead(Guid id)
    {
        await _service.MarkReadAsync(id);
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _service.DeleteAsync(id);
        return NoContent();
    }
}
