using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectOwner : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "4e8b23b8-5b0b-4ab2-8409-3d842b07a472" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "4e8b23b8-5b0b-4ab2-8409-3d842b07a472");

            migrationBuilder.AddColumn<string>(
                name: "CreatedByUserId",
                table: "Projects",
                type: "nvarchar(450)",
                nullable: true);
            
            migrationBuilder.Sql(@"
            DECLARE @admin NVARCHAR(450) = (SELECT TOP 1 Id FROM AspNetUsers);
            UPDATE Projects SET CreatedByUserId = @admin WHERE CreatedByUserId IS NULL;
            ");
            migrationBuilder.AlterColumn<string>(
                name: "CreatedByUserId",
                table: "Projects",
                type: "nvarchar(450)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)",
                oldNullable: true);


            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "72e80218-645a-47a8-a602-8bf506743863", 0, "dfcc0f67-1355-4e7d-ae31-806cb1007c78", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEGHg0vw28to5uY1znpMo2Tg3ctvcPoRoTUu98GwQlyhLir/QsKzAfWyR21m2XXPqXg==", "1234567890", true, "ea9e8719-9196-4f44-9edb-e1c6acbad9a0", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "72e80218-645a-47a8-a602-8bf506743863" });

            migrationBuilder.CreateIndex(
                name: "IX_Projects_CreatedByUserId",
                table: "Projects",
                column: "CreatedByUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Projects_AspNetUsers_CreatedByUserId",
                table: "Projects",
                column: "CreatedByUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Projects_AspNetUsers_CreatedByUserId",
                table: "Projects");

            migrationBuilder.DropIndex(
                name: "IX_Projects_CreatedByUserId",
                table: "Projects");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "72e80218-645a-47a8-a602-8bf506743863" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "72e80218-645a-47a8-a602-8bf506743863");

            migrationBuilder.DropColumn(
                name: "CreatedByUserId",
                table: "Projects");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "4e8b23b8-5b0b-4ab2-8409-3d842b07a472", 0, "54d581cb-c65a-401b-b63a-bba6c0613f06", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEOknU+KJBH3EQD+vGTSrgHJljI2rBnepDbPXb7Kx1pW72j/vGCZNHYI8bIyjrc/8hg==", "1234567890", true, "b3c75245-3daf-4a03-ae18-13a8766c1ce6", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "4e8b23b8-5b0b-4ab2-8409-3d842b07a472" });
        }
    }
}
