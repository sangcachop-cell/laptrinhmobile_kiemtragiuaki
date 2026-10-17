namespace _2380601899.Core.Entities
{
    public class QuestionOption
    {
        public int Id { get; set; }
        public int QuestionId { get; set; }
        public string OptionLabel { get; set; } = string.Empty; // 'A', 'B', 'C', 'D'
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; } = false;

        public Question Question { get; set; } = null!;
    }
}
