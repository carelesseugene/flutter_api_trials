using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using WebApiWithRoleAuthentication.Models;
using WebApiWithRoleAuthentication.Data;

namespace WebApiWithRoleAuthentication.Controllers



{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Policy = "RoleUser")]
    public class UserController : ControllerBase
    {

        private readonly UserManager<IdentityUser> userManager;
        private readonly AppDbContext db;

        public UserController(UserManager<IdentityUser> userManager, AppDbContext db)
        {
            this.userManager = userManager;
            this.db = db;
        }


        [HttpPost("user-info")]
        public async Task<IActionResult> GetUserInfo([FromBody] string email)
        {
            var user = await userManager.FindByEmailAsync(email);
            if (user == null) return NotFound();

            var profile = await db.UserProfiles.FindAsync(user.Id);

            return Ok(new
            {
                id = user.Id,
                email = user.Email,
                phoneNumber = user.PhoneNumber,
                fullName = profile?.FullName ?? "",
                title = profile?.Title ?? "",
                position = profile?.Position ?? ""
            });
        }


        [HttpPut("user-info")]
        public async Task<IActionResult> UpdateUserInfo([FromBody] UpdateUserInfo model)
        {
            var user = await userManager.FindByEmailAsync(model.Email);
            if (user == null) return NotFound();

            user.PhoneNumber = model.PhoneNumber;
            await userManager.UpdateAsync(user);

   
            var profile = await db.UserProfiles.FindAsync(user.Id);
            if (profile != null)
            {
                profile.FullName = model.FullName;
                profile.Title = model.Title;
                profile.Position = model.Position;
                profile.PhoneNumber = model.PhoneNumber;
                await db.SaveChangesAsync();
            }

            return Ok();
        }

        [HttpDelete("delete-user")]
        public async Task<IActionResult> DeleteUserAccount([FromBody] string email)
        {
            var user = await userManager.FindByEmailAsync(email);
            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            var result = await userManager.DeleteAsync(user);
            if (result.Succeeded)
            {
                return Ok(new { message = "User deleted successfully." });
            }

            return BadRequest(result.Errors);
        }

        [HttpPut("change-password")]
        public async Task<IActionResult> ChangeUserPassword([FromBody] ChangePassword model)
        {
            var user = await userManager.FindByEmailAsync(model.Email);
            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            var result = await userManager.ChangePasswordAsync(user, model.CurrentPassword, model.NewPassword);

            if (result.Succeeded)
            {
                return Ok(new { message = "Password changed successfully." });
            }

            return BadRequest(result.Errors);
        }
    }
}
