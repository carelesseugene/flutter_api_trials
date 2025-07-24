namespace WebApiWithRoleAuthentication.DTOs;


public record CreateColumnDto(string Title);
public record ColumnDto(Guid Id, string Title, int Position);


public record CreateCardDto(string Title, string? Description);
public record MoveCardDto(Guid TargetColumnId, int NewPosition);
public record CardDto(
    Guid Id,
    Guid ColumnId,
    string Title,
    string? Description,
    string? AssignedUserId,
    string? AssignedUserEmail,     // ← NEW
    int Position,
    int ProgressPercent,           // ← NEW
    DateTime? DueUtc);
public record ColumnBoardDto(
    Guid Id,
    string Title,
    int Position,
    IList<CardDto> Cards);

