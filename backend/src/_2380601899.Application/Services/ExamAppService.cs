using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using _2380601899.Core.Entities;
using _2380601899.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace _2380601899.Application.Services
{
    // DTOs for Lecturer
    public class ExamSummaryDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public bool IsPublished { get; set; }
        public DateTime CreatedAt { get; set; }
        public int AttemptCount { get; set; }
        public decimal? AverageScore { get; set; }
    }

    public class ExamAnalyticsDto
    {
        public int ExamId { get; set; }
        public string Title { get; set; } = string.Empty;
        public int TotalAttempts { get; set; }
        public decimal AverageScore { get; set; }
        public double AverageCorrectCount { get; set; }
        public List<MissedQuestionDto> Top10MissedQuestions { get; set; } = new List<MissedQuestionDto>();
    }

    public class MissedQuestionDto
    {
        public int QuestionId { get; set; }
        public int QuestionNumber { get; set; }
        public int PartNumber { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public int WrongCount { get; set; }
        public double WrongPercentage { get; set; }
        public string? Hint { get; set; }
    }

    // DTOs for Mobile
    public class MobileExamDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public int AttemptCount { get; set; }
    }

    public class QuizExamDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public List<QuizQuestionDto> Part5Questions { get; set; } = new List<QuizQuestionDto>();
        public List<QuizPassageGroupDto> Part6Groups { get; set; } = new List<QuizPassageGroupDto>();
        public List<QuizPassageGroupDto> Part7Groups { get; set; } = new List<QuizPassageGroupDto>();
    }

    public class QuizPassageGroupDto
    {
        public int PassageId { get; set; }
        public int PartNumber { get; set; }
        public string? ContentHtml { get; set; }
        public string? ImageUrl { get; set; }
        public List<QuizQuestionDto> Questions { get; set; } = new List<QuizQuestionDto>();
    }

    public class QuizQuestionDto
    {
        public int Id { get; set; }
        public int PartNumber { get; set; }
        public int QuestionNumber { get; set; }
        public string? QuestionText { get; set; }
        public List<QuizOptionDto> Options { get; set; } = new List<QuizOptionDto>();
    }

    public class QuizOptionDto
    {
        public int Id { get; set; }
        public string OptionLabel { get; set; } = string.Empty; // 'A', 'B', 'C', 'D'
        public string OptionText { get; set; } = string.Empty;
    }

    public class SubmitAttemptDto
    {
        public string? DeviceIdentifier { get; set; }
        public int DurationSeconds { get; set; }
        public List<UserAnswerDto> Answers { get; set; } = new List<UserAnswerDto>();
    }

    public class UserAnswerDto
    {
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; }
    }

    public class SubmitResultDto
    {
        public int AttemptId { get; set; }
        public decimal Score { get; set; } // Thang 10
        public int ToeicReadingScore { get; set; } // Quy doi thang 495
        public int TotalQuestions { get; set; }
        public int AnsweredCount { get; set; }
        public int CorrectCount { get; set; }
        public int WrongCount { get; set; }
        public int SkippedCount { get; set; }
        public List<QuestionReviewDto> Details { get; set; } = new List<QuestionReviewDto>();
    }

    public class QuestionReviewDto
    {
        public int QuestionId { get; set; }
        public int QuestionNumber { get; set; }
        public int PartNumber { get; set; }
        public string? QuestionText { get; set; }
        public int? SelectedOptionId { get; set; }
        public string? SelectedLabel { get; set; }
        public int CorrectOptionId { get; set; }
        public string CorrectLabel { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
        public string? Hint { get; set; }
        public List<OptionReviewDto> Options { get; set; } = new List<OptionReviewDto>();
    }

    public class OptionReviewDto
    {
        public int Id { get; set; }
        public string OptionLabel { get; set; } = string.Empty;
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
    }

    public interface IExamAppService
    {
        Task<List<ExamSummaryDto>> GetAllExamsAsync();
        Task<Exam?> GetExamDetailAsync(int id);
        Task<bool> PublishExamAsync(int examId, bool isPublished);
        Task<bool> DeleteExamAsync(int examId);
        Task<ExamAnalyticsDto?> GetExamAnalyticsAsync(int examId);
        Task<List<MobileExamDto>> GetPublishedExamsAsync();
        Task<QuizExamDto?> GetExamForQuizAsync(int id);
        Task<SubmitResultDto> SubmitExamAttemptAsync(int examId, SubmitAttemptDto dto);
    }

    public class ExamAppService : IExamAppService
    {
        private readonly _2380601899DbContext _dbContext;

        public ExamAppService(_2380601899DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<ExamSummaryDto>> GetAllExamsAsync()
        {
            var exams = await _dbContext.Exams
                .Include(e => e.ExamAttempts)
                .OrderByDescending(e => e.CreatedAt)
                .ToListAsync();

            return exams.Select(e => new ExamSummaryDto
            {
                Id = e.Id,
                Title = e.Title,
                DurationMinutes = e.DurationMinutes,
                TotalQuestions = e.TotalQuestions,
                IsPublished = e.IsPublished,
                CreatedAt = e.CreatedAt,
                AttemptCount = e.ExamAttempts.Count,
                AverageScore = e.ExamAttempts.Any() ? Math.Round(e.ExamAttempts.Average(a => a.Score), 2) : null
            }).ToList();
        }

        public async Task<Exam?> GetExamDetailAsync(int id)
        {
            return await _dbContext.Exams
                .Include(e => e.Passages)
                .Include(e => e.Questions)
                    .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == id);
        }

        public async Task<bool> PublishExamAsync(int examId, bool isPublished)
        {
            var exam = await _dbContext.Exams.FindAsync(examId);
            if (exam == null) return false;

            exam.IsPublished = isPublished;
            exam.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteExamAsync(int examId)
        {
            var exam = await _dbContext.Exams.FindAsync(examId);
            if (exam == null) return false;

            _dbContext.Exams.Remove(exam);
            await _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<ExamAnalyticsDto?> GetExamAnalyticsAsync(int examId)
        {
            var exam = await _dbContext.Exams
                .Include(e => e.ExamAttempts)
                .FirstOrDefaultAsync(e => e.Id == examId);

            if (exam == null) return null;

            var attempts = exam.ExamAttempts.ToList();
            int totalAttempts = attempts.Count;
            decimal avgScore = totalAttempts > 0 ? Math.Round(attempts.Average(a => a.Score), 2) : 0;
            double avgCorrect = totalAttempts > 0 ? Math.Round(attempts.Average(a => a.CorrectCount), 1) : 0;

            // Top 10 missed questions from AttemptAnswers
            var missedQuestions = await _dbContext.AttemptAnswers
                .Where(ans => ans.Attempt.ExamId == examId && !ans.IsCorrect)
                .GroupBy(ans => ans.QuestionId)
                .Select(g => new
                {
                    QuestionId = g.Key,
                    WrongCount = g.Count()
                })
                .OrderByDescending(x => x.WrongCount)
                .Take(10)
                .ToListAsync();

            var top10 = new List<MissedQuestionDto>();
            foreach (var m in missedQuestions)
            {
                var q = await _dbContext.Questions.FindAsync(m.QuestionId);
                if (q != null)
                {
                    top10.Add(new MissedQuestionDto
                    {
                        QuestionId = q.Id,
                        QuestionNumber = q.QuestionNumber,
                        PartNumber = q.PartNumber,
                        QuestionText = q.QuestionText ?? "",
                        WrongCount = m.WrongCount,
                        WrongPercentage = totalAttempts > 0 ? Math.Round((double)m.WrongCount / totalAttempts * 100, 1) : 0,
                        Hint = q.Hint
                    });
                }
            }

            return new ExamAnalyticsDto
            {
                ExamId = exam.Id,
                Title = exam.Title,
                TotalAttempts = totalAttempts,
                AverageScore = avgScore,
                AverageCorrectCount = avgCorrect,
                Top10MissedQuestions = top10
            };
        }

        public async Task<List<MobileExamDto>> GetPublishedExamsAsync()
        {
            return await _dbContext.Exams
                .Where(e => e.IsPublished)
                .OrderByDescending(e => e.CreatedAt)
                .Select(e => new MobileExamDto
                {
                    Id = e.Id,
                    Title = e.Title,
                    DurationMinutes = e.DurationMinutes,
                    TotalQuestions = e.TotalQuestions,
                    AttemptCount = e.ExamAttempts.Count
                })
                .ToListAsync();
        }

        public async Task<QuizExamDto?> GetExamForQuizAsync(int id)
        {
            var exam = await _dbContext.Exams
                .Include(e => e.Passages)
                .Include(e => e.Questions)
                    .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == id && e.IsPublished);

            if (exam == null) return null;

            var rng = new Random();

            var result = new QuizExamDto
            {
                Id = exam.Id,
                Title = exam.Title,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions
            };

            // Part 5 Questions
            var p5Questions = exam.Questions
                .Where(q => q.PartNumber == 5)
                .OrderBy(q => q.QuestionNumber)
                .ToList();

            if (p5Questions.Any(q => q.AllowShuffleQuestion))
            {
                p5Questions = p5Questions.OrderBy(_ => rng.Next()).ToList();
            }

            result.Part5Questions = p5Questions.Select(q => MapToQuizQuestion(q, rng)).ToList();

            // Part 6 Passage Groups
            result.Part6Groups = MapPassageGroups(exam.Passages.Where(p => p.PartNumber == 6).OrderBy(p => p.OrderIndex).ToList(), exam.Questions, rng);

            // Part 7 Passage Groups
            result.Part7Groups = MapPassageGroups(exam.Passages.Where(p => p.PartNumber == 7).OrderBy(p => p.OrderIndex).ToList(), exam.Questions, rng);

            return result;
        }

        private List<QuizPassageGroupDto> MapPassageGroups(List<Passage> passages, ICollection<Question> allQuestions, Random rng)
        {
            var list = new List<QuizPassageGroupDto>();
            foreach (var passage in passages)
            {
                var qList = allQuestions.Where(q => q.PassageId == passage.Id).OrderBy(q => q.QuestionNumber).ToList();
                if (qList.Any(q => q.AllowShuffleQuestion))
                {
                    qList = qList.OrderBy(_ => rng.Next()).ToList();
                }

                list.Add(new QuizPassageGroupDto
                {
                    PassageId = passage.Id,
                    PartNumber = passage.PartNumber,
                    ContentHtml = passage.ContentHtml,
                    ImageUrl = passage.ImageUrl,
                    Questions = qList.Select(q => MapToQuizQuestion(q, rng)).ToList()
                });
            }
            return list;
        }

        private QuizQuestionDto MapToQuizQuestion(Question q, Random rng)
        {
            var options = q.Options.OrderBy(o => o.OptionLabel).ToList();
            if (q.AllowShuffleOptions)
            {
                options = options.OrderBy(_ => rng.Next()).ToList();
            }

            return new QuizQuestionDto
            {
                Id = q.Id,
                PartNumber = q.PartNumber,
                QuestionNumber = q.QuestionNumber,
                QuestionText = q.QuestionText,
                Options = options.Select(o => new QuizOptionDto
                {
                    Id = o.Id,
                    OptionLabel = o.OptionLabel,
                    OptionText = o.OptionText
                }).ToList()
            };
        }

        public async Task<SubmitResultDto> SubmitExamAttemptAsync(int examId, SubmitAttemptDto dto)
        {
            var exam = await _dbContext.Exams
                .Include(e => e.Questions)
                    .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == examId);

            if (exam == null)
            {
                throw new ArgumentException("Đề thi không tồn tại.");
            }

            var userAnswersMap = dto.Answers
                .Where(a => a.SelectedOptionId.HasValue)
                .ToDictionary(a => a.QuestionId, a => a.SelectedOptionId!.Value);

            int correctCount = 0;
            int wrongCount = 0;
            var details = new List<QuestionReviewDto>();
            var attemptAnswersToSave = new List<AttemptAnswer>();

            var allQuestions = exam.Questions.OrderBy(q => q.QuestionNumber).ToList();

            foreach (var q in allQuestions)
            {
                var correctOpt = q.Options.FirstOrDefault(o => o.IsCorrect) ?? q.Options.First();
                int? userSelectedOptId = userAnswersMap.ContainsKey(q.Id) ? userAnswersMap[q.Id] : null;

                bool isCorrect = false;
                string? selectedLabel = null;

                if (userSelectedOptId.HasValue)
                {
                    var selectedOpt = q.Options.FirstOrDefault(o => o.Id == userSelectedOptId.Value);
                    if (selectedOpt != null)
                    {
                        selectedLabel = selectedOpt.OptionLabel;
                        isCorrect = selectedOpt.IsCorrect;
                    }
                    if (isCorrect) correctCount++;
                    else wrongCount++;
                }

                details.Add(new QuestionReviewDto
                {
                    QuestionId = q.Id,
                    QuestionNumber = q.QuestionNumber,
                    PartNumber = q.PartNumber,
                    QuestionText = q.QuestionText,
                    SelectedOptionId = userSelectedOptId,
                    SelectedLabel = selectedLabel,
                    CorrectOptionId = correctOpt.Id,
                    CorrectLabel = correctOpt.OptionLabel,
                    IsCorrect = isCorrect,
                    Hint = q.Hint,
                    Options = q.Options.OrderBy(o => o.OptionLabel).Select(o => new OptionReviewDto
                    {
                        Id = o.Id,
                        OptionLabel = o.OptionLabel,
                        OptionText = o.OptionText,
                        IsCorrect = o.IsCorrect
                    }).ToList()
                });

                attemptAnswersToSave.Add(new AttemptAnswer
                {
                    QuestionId = q.Id,
                    SelectedOptionId = userSelectedOptId,
                    IsCorrect = isCorrect
                });
            }

            int totalQuestions = exam.TotalQuestions > 0 ? exam.TotalQuestions : allQuestions.Count;
            int answeredCount = userAnswersMap.Count;
            int skippedCount = Math.Max(0, totalQuestions - (correctCount + wrongCount));

            // Thang điểm 10
            decimal score10 = totalQuestions > 0 ? Math.Round((decimal)correctCount / totalQuestions * 10, 2) : 0;
            // Điểm quy đổi TOEIC Reading (tối đa 495)
            int toeicScore = Math.Min(495, correctCount * 5);

            var attempt = new ExamAttempt
            {
                ExamId = exam.Id,
                DeviceIdentifier = string.IsNullOrEmpty(dto.DeviceIdentifier) ? "Khách (No-Auth)" : dto.DeviceIdentifier,
                StartTime = DateTime.UtcNow.AddSeconds(-dto.DurationSeconds),
                SubmitTime = DateTime.UtcNow,
                DurationSeconds = dto.DurationSeconds,
                TotalQuestions = totalQuestions,
                AnsweredCount = answeredCount,
                CorrectCount = correctCount,
                WrongCount = wrongCount,
                SkippedCount = skippedCount,
                Score = score10,
                Answers = attemptAnswersToSave
            };

            _dbContext.ExamAttempts.Add(attempt);
            await _dbContext.SaveChangesAsync();

            return new SubmitResultDto
            {
                AttemptId = attempt.Id,
                Score = score10,
                ToeicReadingScore = toeicScore,
                TotalQuestions = totalQuestions,
                AnsweredCount = answeredCount,
                CorrectCount = correctCount,
                WrongCount = wrongCount,
                SkippedCount = skippedCount,
                Details = details
            };
        }
    }
}
