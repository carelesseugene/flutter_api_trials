using System;
using System.Collections.Generic;
using ProjectManagement.Domain;
public class Project
{
    public Guid Id              { get; set; } = Guid.NewGuid();
    public string Name          { get; set; } = default!;
    public string? Description  { get; set; }
    public DateTime CreatedUtc  { get; set; } = DateTime.UtcNow;

    public ICollection<ProjectMember> Members { get; set; } = new List<ProjectMember>();
    public ICollection<BoardColumn>   Columns { get; set; } = new List<BoardColumn>();
}
