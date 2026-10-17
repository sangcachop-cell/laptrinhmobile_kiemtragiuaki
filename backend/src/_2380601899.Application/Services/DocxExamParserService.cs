using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using _2380601899.Core.Entities;
using _2380601899.EntityFrameworkCore;

namespace _2380601899.Application.Services
{
    public class DocxParseResult
    {
        public bool IsSuccess => Errors.Count == 0 && Exam != null;
        public Exam? Exam { get; set; }
        public List<string> Errors { get; set; } = new List<string>();
    }

    public interface IDocxExamParserService
    {
        DocxParseResult ParseAndSaveExam(Stream docxStream, string fileName, string? webRootPath = null);
        DocxParseResult ValidateOnly(Stream docxStream);
    }

    public class DocxExamParserService : IDocxExamParserService
    {
        private readonly _2380601899DbContext _dbContext;

        public DocxExamParserService(_2380601899DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public DocxParseResult ValidateOnly(Stream docxStream)
        {
            var rawLines = ExtractTextLines(docxStream);
            return ParseLines(rawLines, persist: false, null);
        }

        public DocxParseResult ParseAndSaveExam(Stream docxStream, string fileName, string? webRootPath = null)
        {
            var rawLines = ExtractTextLines(docxStream);
            return ParseLines(rawLines, persist: true, webRootPath);
        }

        private List<string> ExtractTextLines(Stream stream)
        {
            var lines = new List<string>();
            using var doc = WordprocessingDocument.Open(stream, false);
            var body = doc.MainDocumentPart?.Document?.Body;
            if (body == null) return lines;

            foreach (var element in body.Elements())
            {
                if (element is Paragraph p)
                {
                    var text = p.InnerText.Trim();
                    if (!string.IsNullOrEmpty(text))
                    {
                        lines.Add(text);
                    }
                }
                else if (element is Table t)
                {
                    foreach (var row in t.Elements<TableRow>())
                    {
                        var cellTexts = row.Elements<TableCell>().Select(c => c.InnerText.Trim()).Where(s => !string.IsNullOrEmpty(s));
                        var combined = string.Join(" | ", cellTexts);
                        if (!string.IsNullOrEmpty(combined))
                        {
                            lines.Add(combined);
                        }
                    }
                }
            }
            return lines;
        }

        private DocxParseResult ParseLines(List<string> lines, bool persist, string? webRootPath)
        {
            var result = new DocxParseResult();
            var errors = new List<string>();

            string examTitle = "Đề thi TOEIC Reading";
            int examDuration = 75;

            var exam = new Exam
            {
                Title = examTitle,
                DurationMinutes = examDuration,
                IsPublished = false,
                CreatedAt = DateTime.UtcNow
            };

            int currentPart = 5;
            bool insidePassage = false;
            var currentPassageLines = new List<string>();
            Passage? currentPassage = null;
            int passageOrderIndex = 1;

            bool insideQuestion = false;
            int currentQNum = 0;
            string currentQText = "";
            bool currentShuffleQ = false;
            bool currentShuffleA = false;
            string? currentHint = null;
            string? currentCorrectAns = null;
            var currentOptions = new Dictionary<string, string>(); // A, B, C, D

            var parsedQuestions = new List<(Question q, Dictionary<string, string> opts, string ans)>();
            var parsedPassages = new List<Passage>();

            for (int i = 0; i < lines.Count; i++)
            {
                var line = lines[i].Trim();
                if (string.IsNullOrWhiteSpace(line)) continue;

                // 1. Exam Title
                var titleMatch = Regex.Match(line, @"^\[EXAM_TITLE:\s*(.*?)\]$", RegexOptions.IgnoreCase);
                if (titleMatch.Success)
                {
                    exam.Title = titleMatch.Groups[1].Value.Trim();
                    continue;
                }

                // 2. Exam Duration
                var durMatch = Regex.Match(line, @"^\[EXAM_DURATION:\s*(\d+)\]$", RegexOptions.IgnoreCase);
                if (durMatch.Success)
                {
                    if (int.TryParse(durMatch.Groups[1].Value, out int dur))
                    {
                        exam.DurationMinutes = dur;
                    }
                    continue;
                }

                // 3. Part
                var partMatch = Regex.Match(line, @"^\[PART:\s*([567])\]$", RegexOptions.IgnoreCase);
                if (partMatch.Success)
                {
                    currentPart = int.Parse(partMatch.Groups[1].Value);
                    currentPassage = null;
                    continue;
                }

                // 4. Passage Start
                if (line.Equals("[PASSAGE_START]", StringComparison.OrdinalIgnoreCase))
                {
                    if (insidePassage)
                    {
                        errors.Add($"Dòng {i + 1}: Phát hiện thẻ [PASSAGE_START] mới khi đoạn văn trước chưa được đóng bằng [PASSAGE_END].");
                    }
                    insidePassage = true;
                    currentPassageLines.Clear();
                    continue;
                }

                // 5. Passage End
                if (line.Equals("[PASSAGE_END]", StringComparison.OrdinalIgnoreCase))
                {
                    if (!insidePassage)
                    {
                        errors.Add($"Dòng {i + 1}: Phát hiện thẻ [PASSAGE_END] nhưng không có [PASSAGE_START] mở trước đó.");
                    }
                    insidePassage = false;

                    var passageContent = string.Join("\n", currentPassageLines).Trim();
                    currentPassage = new Passage
                    {
                        PartNumber = currentPart,
                        ContentHtml = passageContent.Replace("\n", "<br/>"),
                        OrderIndex = passageOrderIndex++
                    };
                    parsedPassages.Add(currentPassage);
                    continue;
                }

                if (insidePassage)
                {
                    currentPassageLines.Add(line);
                    continue;
                }

                // 6. Question Start: [Q: 101] <text>
                var qMatch = Regex.Match(line, @"^\[Q:\s*(\d+)\]\s*(.*)$", RegexOptions.IgnoreCase);
                if (qMatch.Success)
                {
                    if (insideQuestion)
                    {
                        errors.Add($"Dòng {i + 1}: Câu hỏi [Q: {currentQNum}] chưa có thẻ đóng [Q_END] trước khi bắt đầu câu mới.");
                    }
                    insideQuestion = true;
                    currentQNum = int.Parse(qMatch.Groups[1].Value);
                    currentQText = qMatch.Groups[2].Value.Trim();
                    currentShuffleQ = false;
                    currentShuffleA = false;
                    currentHint = null;
                    currentCorrectAns = null;
                    currentOptions.Clear();
                    continue;
                }

                // Inside Question processing
                if (insideQuestion)
                {
                    // Shuffle Q
                    var sqMatch = Regex.Match(line, @"^\[SHUFFLE_Q:\s*(TRUE|FALSE)\]$", RegexOptions.IgnoreCase);
                    if (sqMatch.Success)
                    {
                        currentShuffleQ = sqMatch.Groups[1].Value.Equals("TRUE", StringComparison.OrdinalIgnoreCase);
                        continue;
                    }

                    // Shuffle A
                    var saMatch = Regex.Match(line, @"^\[SHUFFLE_A:\s*(TRUE|FALSE)\]$", RegexOptions.IgnoreCase);
                    if (saMatch.Success)
                    {
                        currentShuffleA = saMatch.Groups[1].Value.Equals("TRUE", StringComparison.OrdinalIgnoreCase);
                        continue;
                    }

                    // Options [A], [B], [C], [D]
                    var optMatch = Regex.Match(line, @"^\[([ABCD])\]\s*(.*)$", RegexOptions.IgnoreCase);
                    if (optMatch.Success)
                    {
                        string label = optMatch.Groups[1].Value.ToUpper();
                        string optText = optMatch.Groups[2].Value.Trim();
                        currentOptions[label] = optText;
                        continue;
                    }

                    // Answer [ANS: A]
                    var ansMatch = Regex.Match(line, @"^\[ANS:\s*([ABCD])\]$", RegexOptions.IgnoreCase);
                    if (ansMatch.Success)
                    {
                        currentCorrectAns = ansMatch.Groups[1].Value.ToUpper();
                        continue;
                    }

                    // Hint [HINT: ...]
                    var hintMatch = Regex.Match(line, @"^\[HINT:\s*(.*?)\]$", RegexOptions.IgnoreCase);
                    if (hintMatch.Success)
                    {
                        currentHint = hintMatch.Groups[1].Value.Trim();
                        continue;
                    }

                    // Question End: [Q_END]
                    if (line.Equals("[Q_END]", StringComparison.OrdinalIgnoreCase))
                    {
                        insideQuestion = false;

                        // Validation for this question
                        if (currentPart != 5 && currentPassage == null)
                        {
                            errors.Add($"Câu hỏi {currentQNum} (Part {currentPart}) bắt buộc phải nằm sau một đoạn văn [PASSAGE_START]...[PASSAGE_END].");
                        }

                        // Must have all 4 options A, B, C, D
                        foreach (var label in new[] { "A", "B", "C", "D" })
                        {
                            if (!currentOptions.ContainsKey(label) || string.IsNullOrEmpty(currentOptions[label]))
                            {
                                errors.Add($"Câu hỏi {currentQNum}: Thiếu phương án lựa chọn [{label}].");
                            }
                        }

                        // Must have correct answer
                        if (string.IsNullOrEmpty(currentCorrectAns) || !new[] { "A", "B", "C", "D" }.Contains(currentCorrectAns))
                        {
                            errors.Add($"Câu hỏi {currentQNum}: Thiếu hoặc sai định dạng thẻ đáp án đúng [ANS: A|B|C|D].");
                        }

                        var qEntity = new Question
                        {
                            PartNumber = currentPart,
                            QuestionNumber = currentQNum,
                            QuestionText = string.IsNullOrEmpty(currentQText) ? $"Câu hỏi {currentQNum}" : currentQText,
                            Hint = currentHint,
                            AllowShuffleQuestion = currentShuffleQ,
                            AllowShuffleOptions = currentShuffleA,
                            Passage = currentPart == 5 ? null : currentPassage
                        };

                        parsedQuestions.Add((qEntity, new Dictionary<string, string>(currentOptions), currentCorrectAns ?? "A"));
                        continue;
                    }
                }
            }

            if (insidePassage)
            {
                errors.Add("Tệp tin kết thúc nhưng có đoạn văn chưa được đóng bằng [PASSAGE_END].");
            }
            if (insideQuestion)
            {
                errors.Add($"Tệp tin kết thúc nhưng câu hỏi [Q: {currentQNum}] chưa được đóng bằng [Q_END].");
            }

            if (parsedQuestions.Count == 0)
            {
                errors.Add("Không tìm thấy bất kỳ câu hỏi hợp lệ nào trong tệp tin Word.");
            }

            // Check duplicate question numbers
            var duplicateNums = parsedQuestions.GroupBy(x => x.q.QuestionNumber).Where(g => g.Count() > 1).Select(g => g.Key).ToList();
            if (duplicateNums.Any())
            {
                errors.Add($"Phát hiện số thứ tự câu hỏi bị trùng lặp: {string.Join(", ", duplicateNums)}.");
            }

            result.Errors = errors;
            if (errors.Count > 0 || !persist)
            {
                result.Exam = null;
                return result; // All-or-Nothing Rollback
            }

            // ==========================================
            // ALL-OR-NOTHING DATABASE TRANSACTION
            // ==========================================
            using var transaction = _dbContext.Database.BeginTransaction();
            try
            {
                exam.TotalQuestions = parsedQuestions.Count;
                _dbContext.Exams.Add(exam);
                _dbContext.SaveChanges();

                // Save passages
                foreach (var passage in parsedPassages)
                {
                    passage.ExamId = exam.Id;
                    _dbContext.Passages.Add(passage);
                }
                _dbContext.SaveChanges();

                // Save questions and options
                foreach (var item in parsedQuestions)
                {
                    var question = item.q;
                    question.ExamId = exam.Id;
                    if (question.Passage != null)
                    {
                        question.PassageId = question.Passage.Id;
                    }
                    _dbContext.Questions.Add(question);
                    _dbContext.SaveChanges();

                    foreach (var kvp in item.opts)
                    {
                        var opt = new QuestionOption
                        {
                            QuestionId = question.Id,
                            OptionLabel = kvp.Key,
                            OptionText = kvp.Value,
                            IsCorrect = kvp.Key.Equals(item.ans, StringComparison.OrdinalIgnoreCase)
                        };
                        _dbContext.QuestionOptions.Add(opt);
                    }
                }
                _dbContext.SaveChanges();

                transaction.Commit();
                result.Exam = exam;
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                result.Exam = null;
                result.Errors.Add($"Lỗi khi ghi dữ liệu vào CSDL: {ex.Message}");
            }

            return result;
        }
    }
}
