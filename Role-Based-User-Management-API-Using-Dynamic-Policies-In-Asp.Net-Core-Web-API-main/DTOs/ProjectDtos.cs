using System;
using System.Collections.Generic;
using ProjectManagement.Domain;

namespace WebApiWithRoleAuthentication.DTOs;

public record CreateProjectDto(string Name, string? Description);


public record ProjectSummaryDto(Guid Id, string Name);

public record ColumnDto(Guid Id, string Title, int Position);

public record MemberDto(string UserId, string Email, ProjectRole Role);

public record ProjectDetailsDto(
    Guid Id,
    string Name,
    string? Description,
    IList<ColumnDto> Columns,
    IList<MemberDto> Members);