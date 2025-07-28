using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class TaskCard_MultiAssignments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards");

            migrationBuilder.DropIndex(
                name: "IX_TaskCards_AssignedUserId",
                table: "TaskCards");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "32ab4f5e-3cbe-4fe3-9f10-de52188607a4" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "32ab4f5e-3cbe-4fe3-9f10-de52188607a4");

            migrationBuilder.DropColumn(
                name: "AssignedUserId",
                table: "TaskCards");

            migrationBuilder.CreateTable(
                name: "TaskCardAssignment",
                columns: table => new
                {
                    TaskCardId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskCardAssignment", x => new { x.TaskCardId, x.UserId });
                    table.ForeignKey(
                        name: "FK_TaskCardAssignment_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TaskCardAssignment_TaskCards_TaskCardId",
                        column: x => x.TaskCardId,
                        principalTable: "TaskCards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "f0779119-fa4d-425d-a3b0-110a979f65ec", 0, "eb7861ad-9d12-4132-a77e-4ab84ee765b8", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEBpN8ACAp1OZyXaALNHbOuXnIY37PJk89fbzufioHKjiCnCMkcPLS/2qqeMvn1jtcw==", "1234567890", true, "2ef6736a-68ba-4bdf-8313-650b2267f861", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "f0779119-fa4d-425d-a3b0-110a979f65ec" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCardAssignment_UserId",
                table: "TaskCardAssignment",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaskCardAssignment");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "f0779119-fa4d-425d-a3b0-110a979f65ec" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "f0779119-fa4d-425d-a3b0-110a979f65ec");

            migrationBuilder.AddColumn<string>(
                name: "AssignedUserId",
                table: "TaskCards",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "32ab4f5e-3cbe-4fe3-9f10-de52188607a4", 0, "49f79f54-eda2-47de-ba50-cd5bb6931885", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEJ4IR5uaTB3d/KxvtDdHQcsJFA977PaH7Nmfnqz2SKMjr7a93Juws+DGKoBcJsoU7A==", "1234567890", true, "b7e6c7c4-4b5c-43fe-8613-6df9d72b7b26", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "32ab4f5e-3cbe-4fe3-9f10-de52188607a4" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCards_AssignedUserId",
                table: "TaskCards",
                column: "AssignedUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards",
                column: "AssignedUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
