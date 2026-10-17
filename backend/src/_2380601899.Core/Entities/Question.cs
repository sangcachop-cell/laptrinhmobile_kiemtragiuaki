using System.Collections.Generic;

namespace _2380601899.Core.Entities
{
    public class Question
    {
        public int Id { get; set; }
        public int ExamId { get; set; }
        public int? PassageId { get; set; }
        public int PartNumber { get; set; } // 5, 6, 7
        public int QuestionNumber { get; set; } // 101 -> 200
        public string? QuestionText { get; set; }
        public string? Hint { get; set; }
        public bool AllowShuffleQuestion { get; set; } = false;
        public bool AllowShuffleOptions { get; set; } = false;

        public Exam Exam { get; set; } = null!;
        public Passage? Passage { get; set; }
        public ICollection<QuestionOption> Options { get; set; } = new List<QuestionOption>();
        public ICollection<AttemptAnswer> AttemptAnswers { get; set; } = new List<AttemptAnswer>();
    }
}
