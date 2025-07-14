namespace WebApiWithRoleAuthentication.DTOs;


public record CreateColumnDto(string Title);
public record ColumnDto(Guid Id, string Title, int Position);


public record CreateCardDto(string Title, string? Description);
public record MoveCardDto(Guid TargetColumnId, int NewPosition);
public record CardDto(
    Guid Id,
    string Title,
    string? Description,
    string? AssignedUserId,
    int Position,
    DateTime? DueUtc);
