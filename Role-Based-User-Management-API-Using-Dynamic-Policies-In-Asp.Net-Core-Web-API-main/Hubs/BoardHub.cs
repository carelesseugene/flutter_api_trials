using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;

namespace WebApiWithRoleAuthentication.Hubs;

public class BoardHub : Hub
{
    /// <summary>Front‑end calls JoinProject(projectId) right after connect.</summary>
    public Task JoinProject(Guid projectId) =>
        Groups.AddToGroupAsync(Context.ConnectionId, projectId.ToString());
}
