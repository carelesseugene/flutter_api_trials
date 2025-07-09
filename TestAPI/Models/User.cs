public class User
{
    public int Id { get; set; }

    [EmailAddress, Required]
    public string Email { get; set; } = default!;

    [Required, MinLength(8)]
    public string PasswordHash { get; set; } = default!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
