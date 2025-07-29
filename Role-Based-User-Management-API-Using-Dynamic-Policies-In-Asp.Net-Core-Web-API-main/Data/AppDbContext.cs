using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Models;
using ProjectManagement.Domain;
namespace WebApiWithRoleAuthentication.Data
{
    public class AppDbContext : IdentityDbContext<IdentityUser>
    {
        public DbSet<Project> Projects => Set<Project>();
        public DbSet<ProjectMember> ProjectMembers => Set<ProjectMember>();
        public DbSet<BoardColumn> BoardColumns => Set<BoardColumn>();
        public DbSet<TaskCard>     TaskCards      => Set<TaskCard>();
        public DbSet<Notification> Notifications  => Set<Notification>();
        public DbSet<ProjectInvitation> ProjectInvitations => Set<ProjectInvitation>();
        public DbSet<UserProfile> UserProfiles { get; set; }


        public AppDbContext(DbContextOptions options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<ProjectMember>().HasKey(pm => new { pm.ProjectId, pm.UserId });

            builder.Entity<Project>()
                .HasMany(p => p.Members)
                .WithOne(m => m.Project)
                .HasForeignKey(m => m.ProjectId);

            builder.Entity<Project>()
                .HasMany(p => p.Columns)
                .WithOne(c => c.Project)
                .HasForeignKey(c => c.ProjectId);
            
            builder.Entity<Project>()
                .HasOne(p => p.CreatedBy)
                .WithMany()   // No back-collection needed
                .HasForeignKey(p => p.CreatedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<BoardColumn>()
                .HasIndex(c => new { c.ProjectId, c.Position })
                .IsUnique();
            builder.Entity<TaskCardAssignment>()
                .HasKey(a => new { a.TaskCardId, a.UserId });

            builder.Entity<TaskCardAssignment>()
                .HasOne(a => a.TaskCard)
                .WithMany(t => t.Assignments)
                .HasForeignKey(a => a.TaskCardId);

            builder.Entity<TaskCardAssignment>()
                .HasOne(a => a.User)
                .WithMany() // No need for back navigation
                .HasForeignKey(a => a.UserId);

            builder.Entity<IdentityRole>().HasData(
                new IdentityRole { Id = "1", Name = "Admin", NormalizedName = "ADMIN" },
                new IdentityRole { Id = "2", Name = "User", NormalizedName = "USER" }
            );

            // Seed Admin Data
            var hasher = new PasswordHasher<IdentityUser>();
            var adminUser = new IdentityUser
            {
                UserName = "freetrained@freetrained.com",
                NormalizedUserName = "FREETRAINED@FREETRAINED.COM",
                Email = "freetrained@freetrained.com",
                NormalizedEmail = "FREETRAINED@FREETRAINED.COM",
                PhoneNumber = "1234567890",
                EmailConfirmed = true,
                PhoneNumberConfirmed = true,
                LockoutEnabled = false,
            };

            adminUser.PasswordHash = hasher.HashPassword(adminUser, "freetrained123");

            builder.Entity<IdentityUser>().HasData(adminUser);

            // Assign Role To Admin
            builder.Entity<IdentityUserRole<string>>().HasData(
                new IdentityUserRole<string>
                {
                    RoleId = "1",
                    UserId = adminUser.Id
                }
            );
            // ---------- INVITATIONS ----------
            builder.Entity<ProjectInvitation>()
            .HasKey(i => new { i.ProjectId, i.UserId });

            builder.Entity<ProjectInvitation>()
            .HasOne(i => i.Project)
            .WithMany(p => p.Invitations)
            .HasForeignKey(i => i.ProjectId);

            builder.Entity<ProjectInvitation>()
            .HasOne(i => i.User)
            .WithMany()
            .HasForeignKey(i => i.UserId)
            .OnDelete(DeleteBehavior.Restrict);

            // ---------- NOTIFICATIONS ----------
            builder.Entity<Notification>()
            .HasIndex(n => n.UserId);
                }
    }
}