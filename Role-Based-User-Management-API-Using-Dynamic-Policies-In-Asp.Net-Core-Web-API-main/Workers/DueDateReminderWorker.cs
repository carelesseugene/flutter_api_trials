using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Domain.Enums;
using WebApiWithRoleAuthentication.Services.Interfaces;

namespace WebApiWithRoleAuthentication.Workers;

public class DueDateReminderWorker : BackgroundService
{
    private readonly IServiceProvider _sp;
    public DueDateReminderWorker(IServiceProvider sp) => _sp = sp;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _sp.CreateScope();
            var db  = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var ns  = scope.ServiceProvider.GetRequiredService<INotificationService>();

            var threshold = DateTime.UtcNow.AddHours(24);

            var cards = await db.TaskCards
                .Include(c => c.Assignments)
                .Where(c => c.DueUtc <= threshold && c.DueUtc >= DateTime.UtcNow)
                .ToListAsync(stoppingToken);

            foreach (var card in cards)
            {
                foreach (var assignment in card.Assignments)
                {
                    await ns.AddAsync(
                        assignment.UserId, // If you have only User, use assignment.User.Id
                        NotificationType.DueReminder,
                        new { card.Id, card.Title, DueUtc = card.DueUtc },
                        stoppingToken);
                }
            }

            await Task.Delay(TimeSpan.FromMinutes(15), stoppingToken);
        }
    }
}
