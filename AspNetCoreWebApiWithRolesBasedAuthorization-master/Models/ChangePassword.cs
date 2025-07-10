namespace AspNetCoreWebApiWithRolesBasedAuthorization.Models;
{
    public class ChangePassword
    {
        public string OldPassword { get; set; }
        public string NewPassword { get; set; }
        public string Email { get; set; }
    }
}