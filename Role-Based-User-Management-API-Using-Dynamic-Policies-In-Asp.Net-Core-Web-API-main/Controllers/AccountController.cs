using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WebApiWithRoleAuthentication.Models;

namespace WebApiWithRoleAuthentication.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly IConfiguration _configuration;

        public AccountController(UserManager<IdentityUser> userManager, RoleManager<IdentityRole> roleManager, IConfiguration configuration)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] Register model)
        {
            if (!isValidEmail(model.Email))
            {
                return BadRequest(new { message = "Invalid email format." });
            }
            var existingUser = await _userManager.FindByEmailAsync(model.Email);
            if (existingUser != null)
            {
                return BadRequest(new { message = "Email already exists." });
            }

            var user = new IdentityUser { UserName = model.Email, Email = model.Email, PhoneNumber = model.phoneNumber };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (result.Succeeded)
            {
                if (!await _roleManager.RoleExistsAsync("User"))
                {
                    var roleResult = await _roleManager.CreateAsync(new IdentityRole("User"));
                    if (!roleResult.Succeeded)
                    {
                        await _userManager.DeleteAsync(user);
                        return StatusCode(500, new { message = "User role creation failed.", errors = roleResult.Errors });
                    }
                }

                await _userManager.AddToRoleAsync(user, "User");

                return Ok(new { message = "User registered successfully" });
            }

            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { message = "Registration Failed.", errors });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Login model)
{
        // 1. find user & validate password
        var user = await _userManager.FindByNameAsync(model.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, model.Password))
            return Unauthorized();

        // 2. roles
        var roles = await _userManager.GetRolesAsync(user);

        // 3. build claims  ───────────────────────────────────────────────
        var claims = new List<Claim>
        {
            // **critical**: NameIdentifier → user.Id
            new(ClaimTypes.NameIdentifier, user.Id),

            // (the others you already had)
            new(JwtRegisteredClaimNames.Name,  user.UserName!),
            new(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email!)
        };

        // add role claims
        claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

        // 4. create token
        var key     = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
        var creds   = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expires = DateTime.UtcNow.AddMinutes(double.Parse(_configuration["Jwt:ExpiryMinutes"]!));

        var token = new JwtSecurityToken(
            issuer:  _configuration["Jwt:Issuer"],
            audience: null,                 // audience validation disabled in TokenValidationParameters
            claims:  claims,
            expires: expires,
            signingCredentials: creds);

        // 5. return JWT
        return Ok(new { token = new JwtSecurityTokenHandler().WriteToken(token) });
}

        private bool isValidEmail(string email)
        {
            try
            {
                var address = new System.Net.Mail.MailAddress(email);
                return address.Address == email;
            }
            catch
            {
                return false;
            }
        }
    }
}
