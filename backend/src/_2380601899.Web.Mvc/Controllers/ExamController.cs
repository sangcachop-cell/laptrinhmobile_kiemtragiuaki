using System;
using System.IO;
using System.Threading.Tasks;
using _2380601899.Application.Services;
using _2380601899.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace _2380601899.Web.Mvc.Controllers
{
    public class ExamController : Controller
    {
        private readonly IExamAppService _examAppService;
        private readonly IDocxExamParserService _parserService;
        private readonly _2380601899DbContext _dbContext;
        private readonly IWebHostEnvironment _env;

        public ExamController(
            IExamAppService examAppService,
            IDocxExamParserService parserService,
            _2380601899DbContext dbContext,
            IWebHostEnvironment env)
        {
            _examAppService = examAppService;
            _parserService = parserService;
            _dbContext = dbContext;
            _env = env;
        }

        // GET: /Exam (Admin Exams List)
        public async Task<IActionResult> Index()
        {
            var exams = await _examAppService.GetAllExamsAsync();
            return View(exams);
        }

        // POST: /Exam/Upload
        [HttpPost]
        public async Task<IActionResult> Upload(IFormFile? docxFile)
        {
            if (docxFile == null || docxFile.Length == 0)
            {
                TempData["ErrorMessage"] = "Vui lòng chọn tệp tin Word (.docx) để tải lên.";
                return RedirectToAction(nameof(Index));
            }

            if (!docxFile.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase))
            {
                TempData["ErrorMessage"] = "Định dạng tệp không hợp lệ! Hệ thống chỉ chấp nhận tệp Word .docx chuẩn.";
                return RedirectToAction(nameof(Index));
            }

            using var stream = docxFile.OpenReadStream();
            var parseResult = _parserService.ParseAndSaveExam(stream, docxFile.FileName, _env.WebRootPath);

            if (!parseResult.IsSuccess)
            {
                ViewBag.ValidationErrors = parseResult.Errors;
                ViewBag.FileName = docxFile.FileName;
                var exams = await _examAppService.GetAllExamsAsync();
                return View("Index", exams);
            }

            TempData["SuccessMessage"] = $"Tải lên và xử lý đề thi '{parseResult.Exam?.Title}' thành công ({parseResult.Exam?.TotalQuestions} câu hỏi)!";
            return RedirectToAction(nameof(Index));
        }

        // GET: /Exam/Preview/{id}
        public async Task<IActionResult> Preview(int id)
        {
            var exam = await _examAppService.GetExamDetailAsync(id);
            if (exam == null)
            {
                return NotFound();
            }
            return View(exam);
        }

        // POST: /Exam/UpdateQuestion
        [HttpPost]
        public async Task<IActionResult> UpdateQuestion(
            int questionId,
            string questionText,
            string hint,
            string optA,
            string optB,
            string optC,
            string optD,
            string correctLabel)
        {
            var question = await _dbContext.Questions
                .Include(q => q.Options)
                .FirstOrDefaultAsync(q => q.Id == questionId);

            if (question == null) return NotFound();

            question.QuestionText = questionText;
            question.Hint = hint;

            foreach (var opt in question.Options)
            {
                if (opt.OptionLabel == "A") opt.OptionText = optA;
                if (opt.OptionLabel == "B") opt.OptionText = optB;
                if (opt.OptionLabel == "C") opt.OptionText = optC;
                if (opt.OptionLabel == "D") opt.OptionText = optD;
                opt.IsCorrect = opt.OptionLabel.Equals(correctLabel, StringComparison.OrdinalIgnoreCase);
            }

            await _dbContext.SaveChangesAsync();
            TempData["SuccessMessage"] = $"Đã cập nhật câu hỏi số {question.QuestionNumber} thành công!";
            return RedirectToAction(nameof(Preview), new { id = question.ExamId });
        }

        // POST: /Exam/TogglePublish/{id}
        [HttpPost]
        public async Task<IActionResult> TogglePublish(int id)
        {
            var exam = await _dbContext.Exams.FindAsync(id);
            if (exam == null) return NotFound();

            bool newStatus = !exam.IsPublished;
            await _examAppService.PublishExamAsync(id, newStatus);
            TempData["SuccessMessage"] = newStatus 
                ? $"Đã xuất bản đề thi '{exam.Title}'. Ứng dụng Flutter hiện đã có thể truy cập đề này!"
                : $"Đã chuyển đề thi '{exam.Title}' về trạng thái Nháp (Draft).";

            return RedirectToAction(nameof(Index));
        }

        // POST: /Exam/Delete/{id}
        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            var exam = await _dbContext.Exams.FindAsync(id);
            if (exam != null)
            {
                await _examAppService.DeleteExamAsync(id);
                TempData["SuccessMessage"] = $"Đã xóa đề thi '{exam.Title}' thành công.";
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: /Exam/Analytics/{id}
        public async Task<IActionResult> Analytics(int id)
        {
            var analytics = await _examAppService.GetExamAnalyticsAsync(id);
            if (analytics == null) return NotFound();

            return View(analytics);
        }
    }
}
