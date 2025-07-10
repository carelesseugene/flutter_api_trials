namespace AspNetCoreWebApiWithRolesBasedAuthorization.Models
{
    public class ChangeRole
    {
        public string UserEmail { get; set; }
        public string NewRole { get; set; }
    }
}