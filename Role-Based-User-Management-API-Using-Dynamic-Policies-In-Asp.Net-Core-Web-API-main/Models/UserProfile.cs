using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace WebApiWithRoleAuthentication.Models
{
    public class UserProfile
    {

        [Key]
        public string UserId { get; set; }
        public IdentityUser User { get; set; }

        public string FullName { get; set; }
        public string PhoneNumber { get; set; }
        public string Title { get; set; }       // Ünvan
        public string Position { get; set; }
        public string Email { get; set; }
    }
}
