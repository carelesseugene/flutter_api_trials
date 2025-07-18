
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApiWithRoleAuthentication.Data;
using ProjectManagement.Domain;
namespace WebApiWithRoleAuthentication.Requirements;
public class OwnerOrLeadRequirement : IAuthorizationRequirement { }

public class OwnerOrLeadHandler : AuthorizationHandler<OwnerOrLeadRequirement>
{
    private readonly AppDbContext _db;
    private readonly LinkGenerator _links;

    public OwnerOrLeadHandler(AppDbContext db, LinkGenerator links)
        => (_db, _links) = (db, links);

    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext ctx, OwnerOrLeadRequirement req)
    {
        if (!ctx.User.Identity?.IsAuthenticated ?? true) return;

        // Get projectId from route values
        if (ctx.Resource is not HttpContext http) return;
        var projectIdObj = http.GetRouteValue("projectId");
        if (projectIdObj is null || !Guid.TryParse(projectIdObj.ToString(), out var projectId))
            return;

        var uid = ctx.User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        var me = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == uid);

        if (me != null && me.Role == ProjectRole.Lead)
            ctx.Succeed(req);
    }
}
