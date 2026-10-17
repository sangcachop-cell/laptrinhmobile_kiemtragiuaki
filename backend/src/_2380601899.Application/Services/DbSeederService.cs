using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using _2380601899.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace _2380601899.Application.Services
{
    public interface IDbSeederService
    {
        Task SeedInitialExamsAsync(string baseDirectory);
    }

    public class DbSeederService : IDbSeederService
    {
        private readonly _2380601899DbContext _dbContext;
        private readonly IDocxExamParserService _parserService;

        public DbSeederService(_2380601899DbContext dbContext, IDocxExamParserService parserService)
        {
            _dbContext = dbContext;
            _parserService = parserService;
        }

        public async Task SeedInitialExamsAsync(string baseDirectory)
        {
            if (await _dbContext.Exams.AnyAsync())
            {
                return; // Da co de thi, khong can seed
            }

            // Path to sample_exams
            var possiblePaths = new[]
            {
                Path.Combine(baseDirectory, "sample_exams"),
                Path.Combine(baseDirectory, "..", "sample_exams"),
                Path.Combine(baseDirectory, "..", "..", "sample_exams"),
                Path.Combine(baseDirectory, "..", "..", "..", "sample_exams")
            };

            string? sampleFolder = possiblePaths.FirstOrDefault(Directory.Exists);
            if (sampleFolder == null) return;

            var englishTestPath = Path.Combine(sampleFolder, "EnglishTest_Part5_Full_Tagged.docx");
            if (File.Exists(englishTestPath))
            {
                using var stream = File.OpenRead(englishTestPath);
                var result = _parserService.ParseAndSaveExam(stream, Path.GetFileName(englishTestPath));
                if (result.IsSuccess && result.Exam != null)
                {
                    result.Exam.IsPublished = true;
                    await _dbContext.SaveChangesAsync();
                }
            }

            var etsTestPath = Path.Combine(sampleFolder, "ETS_Reading_Test09_Full_Tagged.docx");
            if (File.Exists(etsTestPath))
            {
                using var stream = File.OpenRead(etsTestPath);
                var result = _parserService.ParseAndSaveExam(stream, Path.GetFileName(etsTestPath));
                if (result.IsSuccess && result.Exam != null)
                {
                    result.Exam.IsPublished = true;
                    await _dbContext.SaveChangesAsync();
                }
            }
        }
    }
}
