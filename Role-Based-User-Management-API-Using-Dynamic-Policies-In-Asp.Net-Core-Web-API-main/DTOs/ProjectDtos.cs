using ProjectManagement.Domain;
namespace WebApiWithRoleAuthentication.DTOs;
public record CreateProjectDto(string Name, string? Description);
public record MemberDto(string UserId, string Email, ProjectRole Role);

public record ProjectSummaryDto(
    Guid Id,
    string Name,
    string OwnerEmail,                 // NEW
    int MemberCount);                  // NEW

public record ProjectDetailsDto(
    Guid Id,
    string Name,
    string? Description,
    string OwnerEmail,                 // NEW
    IList<MemberDto> Members,
    IList<ColumnDto> Columns);
