using System.Collections.Generic;

namespace _2380601899.Core.Entities
{
    public class Passage
    {
        public int Id { get; set; }
        public int ExamId { get; set; }
        public int PartNumber { get; set; } // 6 hoac 7
        public string? ContentHtml { get; set; }
        public string? ImageUrl { get; set; }
        public int OrderIndex { get; set; }

        public Exam Exam { get; set; } = null!;
        public ICollection<Question> Questions { get; set; } = new List<Question>();
    }
}
