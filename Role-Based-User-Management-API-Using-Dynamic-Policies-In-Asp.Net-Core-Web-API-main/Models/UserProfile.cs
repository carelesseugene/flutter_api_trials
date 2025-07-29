using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations.Schema;
namespace WebApiWithRoleAuthentication.Models
{
    public class UserProfile
    {

        [Key, ForeignKey(nameof(User))]
        public string UserId { get; set; }=default!;
        public IdentityUser User { get; set; }=default!;

        [Required]public string FullName { get; set; }="";
        [Required]public string PhoneNumber { get; set; }="";
        [Required]public string Title { get; set; }="";       
        [Required]public string Position { get; set; }="";
        [Required]public string Email { get; set; }="";
    }
}
