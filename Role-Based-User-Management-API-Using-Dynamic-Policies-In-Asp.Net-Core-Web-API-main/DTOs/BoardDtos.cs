namespace WebApiWithRoleAuthentication.DTOs;


public record CreateColumnDto(string Title);
public record ColumnDto(Guid Id, string Title, int Position);
public record AssignedUserDto(string UserId, string Email);

public record CreateCardDto(string Title, string? Description, DateTime? DueUtc);
public record MoveCardDto(Guid TargetColumnId, int NewPosition);
public record CardDto(
    Guid Id,
    Guid ColumnId,
    string Title,
    string? Description,
    IList<AssignedUserDto> AssignedUsers,
    int Position,
    int ProgressPercent,
    DateTime? DueUtc);
public record ColumnBoardDto(
    Guid Id,
    string Title,
    int Position,
    IList<CardDto> Cards);

