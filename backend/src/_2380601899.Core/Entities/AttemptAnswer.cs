namespace _2380601899.Core.Entities
{
    public class AttemptAnswer
    {
        public int Id { get; set; }
        public int AttemptId { get; set; }
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; } // NULL neu thi sinh bo qua cau nay
        public bool IsCorrect { get; set; } = false;

        public ExamAttempt Attempt { get; set; } = null!;
        public Question Question { get; set; } = null!;
        public QuestionOption? SelectedOption { get; set; }
    }
}
