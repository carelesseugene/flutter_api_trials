using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity;
using WebApiWithRoleAuthentication.Domain;
using WebApiWithRoleAuthentication.Services.Interfaces;
using WebApiWithRoleAuthentication.Services;
using WebApiWithRoleAuthentication.Workers;
using WebApiWithRoleAuthentication.Domain.Enums;
public class Project
{
    public Guid Id              { get; set; } = Guid.NewGuid();
    public string Name          { get; set; } = default!;
    public string? Description  { get; set; }
    public DateTime CreatedUtc  { get; set; } = DateTime.UtcNow;

 
    public string CreatedByUserId { get; set; } = default!;
    public IdentityUser CreatedBy { get; set; } = default!;

    public ICollection<ProjectMember> Members { get; set; } = new List<ProjectMember>();
    public ICollection<BoardColumn>   Columns { get; set; } = new List<BoardColumn>();
    public ICollection<ProjectInvitation> Invitations { get; set; } = [];

}
