using System;
namespace ProjectManagement.Domain;
public class BoardColumn
{
    public Guid Id        { get; set; } = Guid.NewGuid();
    public Guid ProjectId { get; set; }
    public Project Project{ get; set; } = default!;

    public string Title   { get; set; } = default!;
    public int    Position{ get; set; }
}
