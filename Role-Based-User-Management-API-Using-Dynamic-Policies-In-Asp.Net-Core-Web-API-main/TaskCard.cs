using Microsoft.AspNetCore.Identity;
namespace ProjectManagement.Domain;
public class TaskCard
{
    public Guid Id        { get; set; } = Guid.NewGuid();
    public Guid ColumnId  { get; set; }
    public BoardColumn Column { get; set; } = default!;

    public string Title   { get; set; } = default!;
    public string? Description { get; set; }
    public string? AssignedUserId { get; set; }      
    public IdentityUser? AssignedUser { get; set; }

    public int    Position { get; set; }             
    public DateTime CreatedUtc { get; set; } = DateTime.UtcNow;
    public DateTime? DueUtc    { get; set; }
}