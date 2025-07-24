using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class AssignmentAndProgressV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "11b24105-cfbd-4366-8a0f-4675f67cf55e" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "11b24105-cfbd-4366-8a0f-4675f67cf55e");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "32ab4f5e-3cbe-4fe3-9f10-de52188607a4", 0, "49f79f54-eda2-47de-ba50-cd5bb6931885", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEJ4IR5uaTB3d/KxvtDdHQcsJFA977PaH7Nmfnqz2SKMjr7a93Juws+DGKoBcJsoU7A==", "1234567890", true, "b7e6c7c4-4b5c-43fe-8613-6df9d72b7b26", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "32ab4f5e-3cbe-4fe3-9f10-de52188607a4" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "32ab4f5e-3cbe-4fe3-9f10-de52188607a4" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "32ab4f5e-3cbe-4fe3-9f10-de52188607a4");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "11b24105-cfbd-4366-8a0f-4675f67cf55e", 0, "35efce6d-8747-46ec-aee1-0c2af76eee46", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEAkfVvHH6ZD8x/OSeVwWV8pzv+aEDE5VnFsahhFXrX//M8WxHh5Pch+fTh5K5w+FSg==", "1234567890", true, "d7d9d604-db64-454c-81b5-8e5ae9764241", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "11b24105-cfbd-4366-8a0f-4675f67cf55e" });
        }
    }
}
