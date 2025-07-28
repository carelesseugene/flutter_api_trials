using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApiWithRoleAuthentication.DTOs;
using ProjectManagement.Domain;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Services;
using WebApiWithRoleAuthentication.Extensions;

namespace WebApiWithRoleAuthentication.Controllers;

[ApiController]
[Route("api/projects/{projectId:guid}")]
[Authorize]
public class BoardController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly BoardEventsService _events;
    public BoardController(AppDbContext db, BoardEventsService events)
        => (_db, _events) = (db, events);

    // POST /api/projects/{projectId}/columns
    [HttpPost("columns")]
    public async Task<ActionResult<ColumnDto>> AddColumn(
        Guid projectId, CreateColumnDto dto)
    {
        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId &&
                                      m.UserId == User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        if (member == null) return Forbid();

        var pos = await _db.BoardColumns
            .Where(c => c.ProjectId == projectId)
            .MaxAsync(c => (int?)c.Position) ?? -1;

        var col = new BoardColumn
        {
            ProjectId = projectId,
            Title = dto.Title,
            Position = pos + 1
        };
        _db.BoardColumns.Add(col);
        await _db.SaveChangesAsync();

        return Created("", new ColumnDto(col.Id, col.Title, col.Position));
    }

    // PUT /api/projects/{projectId}/columns/{colId}
    [HttpPut("columns/{colId:guid}")]
    public async Task<IActionResult> RenameColumn(Guid projectId, Guid colId, CreateColumnDto dto)
    {
        var col = await _db.BoardColumns
            .FirstOrDefaultAsync(c => c.Id == colId && c.ProjectId == projectId);
        if (col == null) return NotFound();
        col.Title = dto.Title;
        await _db.SaveChangesAsync();
        return NoContent();
    }

    // DELETE /api/projects/{projectId}/columns/{colId}
    [HttpDelete("columns/{colId:guid}")]
    public async Task<IActionResult> DeleteColumn(Guid projectId, Guid colId)
    {
        var col = await _db.BoardColumns
            .Include(c => c.Cards)
            .FirstOrDefaultAsync(c => c.Id == colId && c.ProjectId == projectId);
        if (col == null) return NotFound();
        _db.Remove(col);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    // POST /api/projects/{projectId}/columns/{colId}/cards
    [HttpPost("columns/{colId:guid}/cards")]
    public async Task<ActionResult<CardDto>> AddCard(
        Guid projectId, Guid colId, CreateCardDto dto)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == uid);
        if (member == null) return Forbid();

        var pos = await _db.TaskCards
            .Where(c => c.ColumnId == colId)
            .MaxAsync(c => (int?)c.Position) ?? -1;

        var card = new TaskCard
        {
            ColumnId = colId,
            Title = dto.Title,
            Description = dto.Description,
            Position = pos + 1
        };
        _db.TaskCards.Add(card);
        await _db.SaveChangesAsync();

        // For CardDto, show empty assignment list for new card
        var cardDto = new CardDto(
            card.Id,
            card.ColumnId,
            card.Title,
            card.Description,
            new List<AssignedUserDto>(),
            card.Position,
            card.ProgressPercent,
            card.DueUtc
        );

        await _events.CardCreated(projectId, cardDto);

        return Created("", cardDto);
    }

    // PATCH /api/projects/{projectId}/cards/{cardId}/move
    [HttpPatch("cards/{cardId:guid}/move")]
    public async Task<IActionResult> MoveCard(Guid projectId, Guid cardId, MoveCardDto dto)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == uid);
        if (member == null) return Forbid();

        var card = await _db.TaskCards.Include(c => c.Column)
            .Include(c => c.Assignments).ThenInclude(a => a.User)
            .FirstOrDefaultAsync(c => c.Id == cardId && c.Column.ProjectId == projectId);
        if (card == null) return NotFound();

        // simple reordering: shift positions in target column
        var targetCards = _db.TaskCards
            .Where(c => c.ColumnId == dto.TargetColumnId)
            .OrderBy(c => c.Position)
            .ToList();

        for (int i = 0; i < targetCards.Count; i++)
            if (targetCards[i].Position >= dto.NewPosition)
                targetCards[i].Position++;

        card.ColumnId = dto.TargetColumnId;
        card.Position = dto.NewPosition;

        await _db.SaveChangesAsync();

        var cardDto = new CardDto(
            card.Id,
            card.ColumnId,
            card.Title,
            card.Description,
            card.Assignments.Select(a => new AssignedUserDto(a.UserId, a.User.Email!)).ToList(),
            card.Position,
            card.ProgressPercent,
            card.DueUtc
        );

        await _events.CardMoved(projectId, cardDto);
        return NoContent();
    }

    // GET /api/projects/{projectId}/board
    [HttpGet("board")]
    public async Task<ActionResult<IList<ColumnBoardDto>>> GetBoard(Guid projectId)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var member = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == uid);
        if (member == null) return Forbid();

        var cols = await _db.BoardColumns
            .Where(c => c.ProjectId == projectId)
            .OrderBy(c => c.Position)
            .Include(c => c.Cards)
                .ThenInclude(card => card.Assignments)
                    .ThenInclude(a => a.User)
            .ToListAsync();

        var dto = cols.Select(col => new ColumnBoardDto(
            col.Id,
            col.Title,
            col.Position,
            col.Cards
                .OrderBy(card => card.Position)
                .Select(card => new CardDto(
                    card.Id,
                    card.ColumnId,
                    card.Title,
                    card.Description,
                    card.Assignments.Select(a => new AssignedUserDto(a.UserId, a.User.Email!)).ToList(),
                    card.Position,
                    card.ProgressPercent,
                    card.DueUtc))
                .ToList()
        )).ToList();

        return dto;
    }

    // DELETE /api/projects/{projectId}/cards/{cardId}
    [HttpDelete("cards/{cardId:guid}")]
    public async Task<IActionResult> DeleteCard(Guid projectId, Guid cardId)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        // user must be member of the project
        var member = await _db.ProjectMembers
            .AnyAsync(m => m.ProjectId == projectId && m.UserId == uid);
        if (!member) return Forbid();

        // find card that belongs to the same project
        var card = await _db.TaskCards
            .Include(c => c.Column)
            .FirstOrDefaultAsync(c => c.Id == cardId &&
                                    c.Column.ProjectId == projectId);
        if (card == null) return NotFound();

        _db.TaskCards.Remove(card);
        await _db.SaveChangesAsync();
        return NoContent();             // 204
    }

    // Assign users (lead only)
    public record AssignUsersRequest(IList<string> UserIds);

    [HttpPost("cards/{cardId:guid}/assign")]
    public async Task<IActionResult> AssignUsersToCard(Guid projectId, Guid cardId, [FromBody] AssignUsersRequest req)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        // Only lead can assign
        var lead = await _db.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == uid && m.Role == ProjectRole.Lead);
        if (lead == null) return Forbid();

        var card = await _db.TaskCards
            .Include(c => c.Column)
            .Include(c => c.Assignments)
            .FirstOrDefaultAsync(c => c.Id == cardId && c.Column.ProjectId == projectId);
        if (card == null) return NotFound();

        card.Assignments.Clear();

        // Only assign project members
        var validUserIds = await _db.ProjectMembers
            .Where(m => m.ProjectId == projectId && req.UserIds.Contains(m.UserId))
            .Select(m => m.UserId)
            .ToListAsync();

        foreach (var userId in validUserIds)
        {
            card.Assignments.Add(new TaskCardAssignment { UserId = userId });
        }

        await _db.SaveChangesAsync();
        return NoContent();
    }

    // Update progress (only assigned members)
    public record UpdateCardProgressRequest(int Progress);

    [HttpPatch("cards/{cardId:guid}/progress")]
    public async Task<IActionResult> UpdateCardProgress(Guid projectId, Guid cardId, [FromBody] UpdateCardProgressRequest req)
    {
        var uid = User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        var card = await _db.TaskCards
            .Include(c => c.Column)
            .Include(c => c.Assignments)
            .FirstOrDefaultAsync(c => c.Id == cardId && c.Column.ProjectId == projectId);

        if (card == null) return NotFound();

        // Only assigned user can update
        var isAssigned = card.Assignments.Any(a => a.UserId == uid);
        if (!isAssigned)
            return Forbid();

        card.ProgressPercent = Math.Max(0, Math.Min(100, req.Progress));
        await _db.SaveChangesAsync();

        return NoContent();
    }
}
