using System;
using System.Threading.Tasks;
using _2380601899.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace _2380601899.Web.Mvc.Controllers
{
    [ApiController]
    [Route("api/mobile/exams")]
    [AllowAnonymous] // KHONG CAN DANG NHAP / DANG KY
    public class MobileExamApiController : ControllerBase
    {
        private readonly IExamAppService _examAppService;

        public MobileExamApiController(IExamAppService examAppService)
        {
            _examAppService = examAppService;
        }

        // 1. GET /api/mobile/exams
        // Lay danh sach de thi da xuat ban (IsPublished = true)
        [HttpGet]
        public async Task<IActionResult> GetPublishedExams()
        {
            var exams = await _examAppService.GetPublishedExamsAsync();
            return Ok(exams);
        }

        // 2. GET /api/mobile/exams/{id}/start
        // Lay toan bo cau truc de thi de vao thi ngay
        [HttpGet("{id}/start")]
        public async Task<IActionResult> StartExam(int id)
        {
            var quizData = await _examAppService.GetExamForQuizAsync(id);
            if (quizData == null)
            {
                return NotFound(new { message = "Đề thi không tồn tại hoặc chưa được xuất bản." });
            }
            return Ok(quizData);
        }

        // 3. POST /api/mobile/exams/{id}/submit
        // Nop bai cham diem (ho tro nop som chi sau 1-2 cau)
        [HttpPost("{id}/submit")]
        public async Task<IActionResult> SubmitExam(int id, [FromBody] SubmitAttemptDto dto)
        {
            if (dto == null)
            {
                return BadRequest(new { message = "Dữ liệu bài thi không hợp lệ." });
            }

            try
            {
                var result = await _examAppService.SubmitExamAttemptAsync(id, dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
