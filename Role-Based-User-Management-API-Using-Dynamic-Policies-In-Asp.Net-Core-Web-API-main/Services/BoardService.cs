using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using WebApiWithRoleAuthentication.Hubs;
using WebApiWithRoleAuthentication.DTOs;

namespace WebApiWithRoleAuthentication.Services;

public class BoardEventsService
{
    private readonly IHubContext<BoardHub> _hub;
    public BoardEventsService(IHubContext<BoardHub> hub) => _hub = hub;

    public Task CardMoved(Guid projectId, CardDto dto) =>
        _hub.Clients.Group(projectId.ToString()).SendAsync("CardMoved", dto);

    public Task CardCreated(Guid projectId, CardDto dto) =>
        _hub.Clients.Group(projectId.ToString()).SendAsync("CardCreated", dto);

    public Task ColumnCreated(Guid projectId, ColumnBoardDto dto) =>
        _hub.Clients.Group(projectId.ToString()).SendAsync("ColumnCreated", dto);
}
