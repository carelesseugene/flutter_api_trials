namespace WebApiWithRoleAuthentication.DTOs;

public record AssignedCardDto(
    Guid Id,
    string Title,
    string? Description,
    int ProgressPercent,
    DateTime? DueUtc,
    Guid ProjectId,
    string ProjectName,
    Guid ColumnId,
    string ColumnTitle,
    IList<AssignedUserDto> AssignedUsers
);
