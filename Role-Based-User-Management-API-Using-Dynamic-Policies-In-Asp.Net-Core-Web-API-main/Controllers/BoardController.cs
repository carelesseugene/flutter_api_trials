using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebApiWithRoleAuthentication.DTOs;
using ProjectManagement.Domain;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Services;
namespace ProjectManagement.Controllers;

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

    /* ========== CARD endpoints ========== */

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
        await _events.CardCreated(projectId, new CardDto(
            card.Id,card.ColumnId, card.Title, card.Description,
            card.AssignedUserId, card.Position, card.DueUtc));

        return Created("", new CardDto(
            card.Id,card.ColumnId, card.Title, card.Description,
            card.AssignedUserId, card.Position, card.DueUtc));
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
        await _events.CardMoved(projectId, new CardDto(
            card.Id,card.ColumnId, card.Title, card.Description,
            card.AssignedUserId, card.Position, card.DueUtc));
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
                    card.AssignedUserId,
                    card.Position,
                    card.DueUtc))
                .ToList()
        )).ToList();

        return dto;
    }

    // Controllers/BoardController.cs  (inside class, BEFORE the final brace)
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


}
