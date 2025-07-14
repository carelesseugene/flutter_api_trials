using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebApiWithRoleAuthentication.Migrations
{
    /// <inheritdoc />
    public partial class AddTaskCardsDbSet : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaskCard");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "6d557da8-ad1c-4bdd-a774-206acfd823c2" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "6d557da8-ad1c-4bdd-a774-206acfd823c2");

            migrationBuilder.CreateTable(
                name: "TaskCards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ColumnId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AssignedUserId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    Position = table.Column<int>(type: "int", nullable: false),
                    CreatedUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DueUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskCards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TaskCards_AspNetUsers_AssignedUserId",
                        column: x => x.AssignedUserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TaskCards_BoardColumns_ColumnId",
                        column: x => x.ColumnId,
                        principalTable: "BoardColumns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "4e8b23b8-5b0b-4ab2-8409-3d842b07a472", 0, "54d581cb-c65a-401b-b63a-bba6c0613f06", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEOknU+KJBH3EQD+vGTSrgHJljI2rBnepDbPXb7Kx1pW72j/vGCZNHYI8bIyjrc/8hg==", "1234567890", true, "b3c75245-3daf-4a03-ae18-13a8766c1ce6", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "4e8b23b8-5b0b-4ab2-8409-3d842b07a472" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCards_AssignedUserId",
                table: "TaskCards",
                column: "AssignedUserId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskCards_ColumnId_Position",
                table: "TaskCards",
                columns: new[] { "ColumnId", "Position" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaskCards");

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { "1", "4e8b23b8-5b0b-4ab2-8409-3d842b07a472" });

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: "4e8b23b8-5b0b-4ab2-8409-3d842b07a472");

            migrationBuilder.CreateTable(
                name: "TaskCard",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AssignedUserId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    ColumnId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CreatedUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DueUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Position = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskCard", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TaskCard_AspNetUsers_AssignedUserId",
                        column: x => x.AssignedUserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TaskCard_BoardColumns_ColumnId",
                        column: x => x.ColumnId,
                        principalTable: "BoardColumns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { "6d557da8-ad1c-4bdd-a774-206acfd823c2", 0, "6582c1eb-cbb5-400b-b780-35e6901ae2ac", "freetrained@freetrained.com", true, false, null, "FREETRAINED@FREETRAINED.COM", "FREETRAINED@FREETRAINED.COM", "AQAAAAIAAYagAAAAEDu4qRapg3K6mVzgtTWm7VVDQf11CCdKUCl2TKfyzsDIo7FPSXIOUKv58EaY5DdhYA==", "1234567890", true, "68e6dead-2863-46a4-8b14-fad60c1780e8", false, "freetrained@freetrained.com" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId" },
                values: new object[] { "1", "6d557da8-ad1c-4bdd-a774-206acfd823c2" });

            migrationBuilder.CreateIndex(
                name: "IX_TaskCard_AssignedUserId",
                table: "TaskCard",
                column: "AssignedUserId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskCard_ColumnId_Position",
                table: "TaskCard",
                columns: new[] { "ColumnId", "Position" },
                unique: true);
        }
    }
}
