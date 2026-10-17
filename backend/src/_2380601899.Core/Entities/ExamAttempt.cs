using System;
using System.Collections.Generic;

namespace _2380601899.Core.Entities
{
    public class ExamAttempt
    {
        public int Id { get; set; }
        public int ExamId { get; set; }
        public string? DeviceIdentifier { get; set; } // Khong can dang nhap
        public DateTime StartTime { get; set; } = DateTime.UtcNow;
        public DateTime SubmitTime { get; set; } = DateTime.UtcNow;
        public int DurationSeconds { get; set; } = 0;
        public int TotalQuestions { get; set; }
        public int AnsweredCount { get; set; } // Ho tro nop som 1-2 cau
        public int CorrectCount { get; set; }
        public int WrongCount { get; set; }
        public int SkippedCount { get; set; }
        public decimal Score { get; set; } // Thang 10 hoac TOEIC quy doi

        public Exam Exam { get; set; } = null!;
        public ICollection<AttemptAnswer> Answers { get; set; } = new List<AttemptAnswer>();
    }
}
