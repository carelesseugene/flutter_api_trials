using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WebApiWithRoleAuthentication.Models;

namespace WebApiWithRoleAuthentication.Data
{
    public class AppDbContext : IdentityDbContext<IdentityUser>
    {
        public AppDbContext(DbContextOptions options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<IdentityRole>(
                new IdentityRole{Id="1", Name="Admin", NormalizedName="ADMIN"}
                new IdentityRole{Id="2", Name="User", NormalizedName="USER"}
            );

            var hasher = new PasswordHasher<IdentityUser>();
            var adminUser= new IdentityUser
            {
                UserName= "admin@administraitor.com"
                NormalizedUserName="ADMIN@ADMINISTRAITOR.COM"
                Email="admin@administraitor.com"
                NormalizedEmail="ADMIN@ADMINISTRAITOR.com"
                PhoneNumber="1234567890"
                EmailConfirmed=true;
                PhoneNumberConfirmed=true;
                LockOutEnable=false;

            };

            adminUser.PasswordHash=hasher.HashPassword(adminUser, "Admin@123");

            modelBuilder.Entity<IdentityUser>().HasData(
                new IdentityRole
                {
                    RoleId= "1",
                    Id = adminUser.Id,
                 
                },

            );
        }
    }
}
