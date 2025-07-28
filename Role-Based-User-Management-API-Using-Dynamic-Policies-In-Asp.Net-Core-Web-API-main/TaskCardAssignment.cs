using Microsoft.AspNetCore.Identity;

namespace ProjectManagement.Domain;

public class TaskCardAssignment
{
    public Guid TaskCardId { get; set; }
    public TaskCard TaskCard { get; set; } = default!;

    public string UserId { get; set; } = default!;
    public IdentityUser User { get; set; } = default!;
}
