using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Extensions;

namespace WebApiWithRoleAuthentication.Hubs;

public class BoardHub : Hub
{

    private readonly AppDbContext _db;
    public BoardHub(AppDbContext db) => _db = db;
    /// <summary>Front‑end calls JoinProject(projectId) right after connect.</summary>
    public Task JoinProject(Guid projectId) =>
        Groups.AddToGroupAsync(Context.ConnectionId, $"project-{projectId}");




    public override async Task OnConnectedAsync()
{
    var uid = Context.User!.GetUserId();
    var projectIds = await _db.ProjectMembers
                              .Where(m => m.UserId == uid)
                              .Select(m => m.ProjectId)
                              .ToListAsync();

    foreach (var pid in projectIds)
        await Groups.AddToGroupAsync(Context.ConnectionId, $"project-{pid}");

    await base.OnConnectedAsync();
}

}
