using _2380601899.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace _2380601899.EntityFrameworkCore
{
    public class _2380601899DbContext : DbContext
    {
        public _2380601899DbContext(DbContextOptions<_2380601899DbContext> options) : base(options)
        {
        }

        public DbSet<Exam> Exams => Set<Exam>();
        public DbSet<Passage> Passages => Set<Passage>();
        public DbSet<Question> Questions => Set<Question>();
        public DbSet<QuestionOption> QuestionOptions => Set<QuestionOption>();
        public DbSet<ExamAttempt> ExamAttempts => Set<ExamAttempt>();
        public DbSet<AttemptAnswer> AttemptAnswers => Set<AttemptAnswer>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 1. Exams
            modelBuilder.Entity<Exam>(entity =>
            {
                entity.ToTable("Exams");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Title).HasMaxLength(255).IsRequired();
                entity.Property(e => e.Description).HasMaxLength(500);
                entity.Property(e => e.DurationMinutes).HasDefaultValue(75);
                entity.Property(e => e.TotalQuestions).HasDefaultValue(100);
                entity.Property(e => e.IsPublished).HasDefaultValue(false);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETDATE()");
            });

            // 2. Passages
            modelBuilder.Entity<Passage>(entity =>
            {
                entity.ToTable("Passages");
                entity.HasKey(p => p.Id);
                entity.Property(p => p.ImageUrl).HasMaxLength(500);

                entity.HasOne(p => p.Exam)
                      .WithMany(e => e.Passages)
                      .HasForeignKey(p => p.ExamId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // 3. Questions
            modelBuilder.Entity<Question>(entity =>
            {
                entity.ToTable("Questions");
                entity.HasKey(q => q.Id);
                entity.Property(q => q.AllowShuffleQuestion).HasDefaultValue(false);
                entity.Property(q => q.AllowShuffleOptions).HasDefaultValue(false);

                entity.HasOne(q => q.Exam)
                      .WithMany(e => e.Questions)
                      .HasForeignKey(q => q.ExamId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(q => q.Passage)
                      .WithMany(p => p.Questions)
                      .HasForeignKey(q => q.PassageId)
                      .OnDelete(DeleteBehavior.Restrict)
                      .IsRequired(false);
            });

            // 4. QuestionOptions
            modelBuilder.Entity<QuestionOption>(entity =>
            {
                entity.ToTable("QuestionOptions");
                entity.HasKey(o => o.Id);
                entity.Property(o => o.OptionLabel).HasMaxLength(1).IsRequired();
                entity.Property(o => o.OptionText).IsRequired();
                entity.Property(o => o.IsCorrect).HasDefaultValue(false);

                entity.HasOne(o => o.Question)
                      .WithMany(q => q.Options)
                      .HasForeignKey(o => o.QuestionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // 5. ExamAttempts
            modelBuilder.Entity<ExamAttempt>(entity =>
            {
                entity.ToTable("ExamAttempts");
                entity.HasKey(a => a.Id);
                entity.Property(a => a.DeviceIdentifier).HasMaxLength(100);
                entity.Property(a => a.StartTime).HasDefaultValueSql("GETDATE()");
                entity.Property(a => a.SubmitTime).HasDefaultValueSql("GETDATE()");
                entity.Property(a => a.Score).HasPrecision(5, 2);

                entity.HasOne(a => a.Exam)
                      .WithMany(e => e.ExamAttempts)
                      .HasForeignKey(a => a.ExamId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // 6. AttemptAnswers
            modelBuilder.Entity<AttemptAnswer>(entity =>
            {
                entity.ToTable("AttemptAnswers");
                entity.HasKey(ans => ans.Id);

                entity.HasOne(ans => ans.Attempt)
                      .WithMany(a => a.Answers)
                      .HasForeignKey(ans => ans.AttemptId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(ans => ans.Question)
                      .WithMany(q => q.AttemptAnswers)
                      .HasForeignKey(ans => ans.QuestionId)
                      .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(ans => ans.SelectedOption)
                      .WithMany()
                      .HasForeignKey(ans => ans.SelectedOptionId)
                      .OnDelete(DeleteBehavior.Restrict)
                      .IsRequired(false);
            });
        }
    }
}
