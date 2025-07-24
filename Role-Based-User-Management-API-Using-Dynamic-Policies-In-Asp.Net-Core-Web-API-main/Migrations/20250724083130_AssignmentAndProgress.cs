using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class AssignmentAndProgress : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards");

            migrationBuilder.DropIndex(
                name: "IX_TaskCards_ColumnId_Position",
                table: "TaskCards");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "dcf37961-976c-42ea-96df-ed3d8a9211ef" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "dcf37961-976c-42ea-96df-ed3d8a9211ef");

            migrationBuilder.AddColumn<int>(
                name: "ProgressPercent",
                table: "TaskCards",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "11b24105-cfbd-4366-8a0f-4675f67cf55e", 0, "35efce6d-8747-46ec-aee1-0c2af76eee46", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEAkfVvHH6ZD8x/OSeVwWV8pzv+aEDE5VnFsahhFXrX//M8WxHh5Pch+fTh5K5w+FSg==", "1234567890", true, "d7d9d604-db64-454c-81b5-8e5ae9764241", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "11b24105-cfbd-4366-8a0f-4675f67cf55e" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCards_ColumnId",
                table: "TaskCards",
                column: "ColumnId");

            migrationBuilder.AddForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards",
                column: "AssignedUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards");

            migrationBuilder.DropIndex(
                name: "IX_TaskCards_ColumnId",
                table: "TaskCards");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "11b24105-cfbd-4366-8a0f-4675f67cf55e" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "11b24105-cfbd-4366-8a0f-4675f67cf55e");

            migrationBuilder.DropColumn(
                name: "ProgressPercent",
                table: "TaskCards");

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "dcf37961-976c-42ea-96df-ed3d8a9211ef", 0, "47498062-c5e1-4876-8beb-801743ceaeae", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEJkcB6+MUJruYDLXaUNNIoKeczSKF4fxxPvxb0iRlwwRrO78b2aunBpRqCJh1oFuAA==", "1234567890", true, "5f93874f-11d3-49de-919d-5e0da5bc0e95", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "dcf37961-976c-42ea-96df-ed3d8a9211ef" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCards_ColumnId_Position",
                table: "TaskCards",
                columns: new[] { "ColumnId", "Position" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                table: "TaskCards",
                column: "AssignedUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");
        }
    }
}
