using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class ExpandNotificationTypes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "45a51d5c-57cd-4bcd-a5e6-bcffb97fb011" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "45a51d5c-57cd-4bcd-a5e6-bcffb97fb011");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "4177363e-e6ce-4b13-b296-294a3e350960", 0, "6319f42a-3042-43b0-85c8-ec6776cad6c3", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEJ3LMagnDA7ZEpJf47xxqsgNV8ihX6bzHL53YuYpkdw9OEHmA7T7m96tgIOmcduASA==", "1234567890", true, "62cae16b-94cc-4653-a85c-149a2085be75", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "4177363e-e6ce-4b13-b296-294a3e350960" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "4177363e-e6ce-4b13-b296-294a3e350960" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "4177363e-e6ce-4b13-b296-294a3e350960");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "45a51d5c-57cd-4bcd-a5e6-bcffb97fb011", 0, "5638a640-5ad1-42c5-9f15-8da4b2a062cd", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEIMy1rX/B7Yze4g3PF9x92qY7Cw8jxUabg8A7wawbp3Z10XaPfaoEDdBcunVxWpgTQ==", "1234567890", true, "ad4053bf-b3af-4e48-ac19-b7ef66d243d0", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "45a51d5c-57cd-4bcd-a5e6-bcffb97fb011" });
        }
    }
}
