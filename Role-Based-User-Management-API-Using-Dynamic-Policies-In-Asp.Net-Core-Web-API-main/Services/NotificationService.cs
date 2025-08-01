using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Domain;
using WebApiWithRoleAuthentication.Domain.Enums;
using WebApiWithRoleAuthentication.Services.Interfaces;

namespace WebApiWithRoleAuthentication.Services;

public class NotificationService : INotificationService
{
    private readonly AppDbContext _db;
    public NotificationService(AppDbContext db) => _db = db;

    public async Task AddAsync(string userId, NotificationType type, object payload,
                               CancellationToken ct = default)
    {
        var n = new Notification
        {
            UserId = userId,
            Type   = type,
            PayloadJson = JsonSerializer.Serialize(payload)
        };
        _db.Notifications.Add(n);
        await _db.SaveChangesAsync(ct);
    }

    public async Task MarkReadAsync(Guid id, CancellationToken ct = default)
    {
        await _db.Notifications
                 .Where(n => n.Id == id)
                 .ExecuteUpdateAsync(s => s
                     .SetProperty(n => n.Status, NotificationStatus.Read), ct);
    }

    public async Task MarkActionedAsync(Guid id, CancellationToken ct = default)
    {
        await _db.Notifications
                 .Where(n => n.Id == id)
                 .ExecuteUpdateAsync(s => s
                     .SetProperty(n => n.Status, NotificationStatus.Actioned), ct);
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct = default)
    {
        await _db.Notifications
                 .Where(n => n.Id == id)
                 .ExecuteDeleteAsync(ct);
    }
}
