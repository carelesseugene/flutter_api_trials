using System;
using Microsoft.AspNetCore.Identity;

namespace WebApiWithRoleAuthentication.Domain;


public class ProjectMember
{
    public Guid         ProjectId { get; set; }
    public string       UserId    { get; set; } = default!;
    public ProjectRole  Role      { get; set; } = ProjectRole.Member;

    public Project          Project { get; set; } = default!;
    public IdentityUser     User    { get; set; } = default!;  
}
