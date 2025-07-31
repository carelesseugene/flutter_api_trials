using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Security.Cryptography;
using System.Text;
using WebApiWithRoleAuthentication.Authorization;
using WebApiWithRoleAuthentication.Data;
using WebApiWithRoleAuthentication.Hubs;
using WebApiWithRoleAuthentication.Models;
using WebApiWithRoleAuthentication.Services;
using WebApiWithRoleAuthentication.Requirements;      // ← NEW  (namespace for OwnerOrLead*)
using Microsoft.AspNetCore.SignalR;
using WebApiWithRoleAuthentication.Services.Interfaces;
using WebApiWithRoleAuthentication.Services;
using WebApiWithRoleAuthentication.Workers;


const string AllowAll = "AllowAll";

var builder = WebApplication.CreateBuilder(args);

/*───────────────── MVC & Swagger ─────────────────*/
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "RBAC API", Version = "v1" });

    var jwtScheme = new OpenApiSecurityScheme
    {
        Scheme = "bearer",
        BearerFormat = "JWT",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Description = "Paste **only** your JWT token here",
        Reference = new OpenApiReference
        {
            Id   = JwtBearerDefaults.AuthenticationScheme,
            Type = ReferenceType.SecurityScheme
        }
    };
    c.AddSecurityDefinition(jwtScheme.Reference.Id, jwtScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement { { jwtScheme, Array.Empty<string>() } });
});

/*───────────────── SignalR & custom board events ─────────────────*/
builder.Services.AddSignalR();
builder.Services.AddSingleton<BoardEventsService>();

/*───────────────── EF Core + Identity ─────────────────*/
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlServer(builder.Configuration.GetConnectionString("Default"))
    .EnableSensitiveDataLogging()
    .EnableDetailedErrors());

builder.Services.AddIdentity<IdentityUser, IdentityRole>(opt =>
{
    opt.Password.RequiredLength         = 6;
    opt.Password.RequireNonAlphanumeric = false;
    opt.Password.RequireDigit           = false;
    opt.Password.RequireUppercase       = false;
    opt.Password.RequireLowercase       = false;
    opt.User.RequireUniqueEmail         = true;
    opt.SignIn.RequireConfirmedAccount  = false;
})
.AddEntityFrameworkStores<AppDbContext>()
.AddDefaultTokenProviders();

/*───────────────── JWT auth ─────────────────*/
builder.Services.AddAuthentication(opt =>
{
    opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultChallengeScheme    = JwtBearerDefaults.AuthenticationScheme;
    opt.DefaultScheme             = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(opt =>
{
    opt.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer           = true,
        ValidateAudience         = false,
        ValidateLifetime         = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer              = builder.Configuration["Jwt:Issuer"],
        IssuerSigningKey         = new SymmetricSecurityKey(
                                        Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
    };
});

/*───────────────── Authorization ─────────────────*/
builder.Services.AddAuthorization(opts =>
{
    // dynamic policies you already had
    // (DynamicPolicyProvider + DynamicRoleHandler handle [Authorize(Roles=…)])
    opts.AddPolicy("CanManageProject", policy =>                         // ← NEW
        policy.RequireAuthenticatedUser()
              .AddRequirements(new OwnerOrLeadRequirement()));           // ← NEW
});

builder.Services.AddSingleton<IAuthorizationPolicyProvider, DynamicPolicyProvider>();
builder.Services.AddSingleton<IAuthorizationHandler, DynamicRoleHanlder>();
builder.Services.AddScoped<IAuthorizationHandler, OwnerOrLeadHandler>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddHostedService<DueDateReminderWorker>();
builder.Services.AddScoped<IInvitationService, InvitationService>();

 // ← NEW

/*───────────────── Misc ─────────────────*/
builder.Logging.ClearProviders();
builder.Logging.AddConsole();

builder.Services.AddCors(opt =>
    opt.AddPolicy(AllowAll, p => p.AllowAnyOrigin()
                                  .AllowAnyMethod()
                                  .AllowAnyHeader()));

var app = builder.Build();

/*───────────────── HTTP pipeline ─────────────────*/
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors(AllowAll);
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<BoardHub>("/hubs/board");

app.Run();
