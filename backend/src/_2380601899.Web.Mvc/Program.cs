using _2380601899.Application.Services;
using _2380601899.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });

// Configure SQL Server DbContext
var connectionString = builder.Configuration.GetConnectionString("Default") 
    ?? "Server=.\\MSSQLSERVER08;Database=2380601899Db;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;";

builder.Services.AddDbContext<_2380601899DbContext>(options =>
    options.UseSqlServer(connectionString));

// Register Application Services
builder.Services.AddScoped<IDocxExamParserService, DocxExamParserService>();
builder.Services.AddScoped<IExamAppService, ExamAppService>();
builder.Services.AddScoped<IDbSeederService, DbSeederService>();

// Add CORS for mobile Flutter access
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Auto seed initial exams on startup
using (var scope = app.Services.CreateScope())
{
    try
    {
        var seeder = scope.ServiceProvider.GetRequiredService<IDbSeederService>();
        await seeder.SeedInitialExamsAsync(app.Environment.ContentRootPath);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[Seeder Error]: {ex.Message}");
    }
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");
app.UseStaticFiles();
app.UseRouting();
app.UseCors("AllowAll");

app.UseAuthorization();

// Default route goes to ExamController
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Exam}/{action=Index}/{id?}");

app.Run();
