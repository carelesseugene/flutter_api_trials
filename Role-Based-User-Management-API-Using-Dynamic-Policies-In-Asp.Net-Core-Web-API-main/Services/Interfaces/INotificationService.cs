using WebApiWithRoleAuthentication.Domain.Enums;

namespace WebApiWithRoleAuthentication.Services.Interfaces;

public interface INotificationService
{
    Task AddAsync(string userId, NotificationType type, object payload,
                  CancellationToken ct = default);

    Task MarkReadAsync(Guid id, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
    Task MarkActionedAsync(Guid id, CancellationToken ct = default);
}
