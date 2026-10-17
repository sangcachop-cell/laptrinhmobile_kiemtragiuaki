using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace _2380601899.EntityFrameworkCore
{
    public class _2380601899DbContextFactory : IDesignTimeDbContextFactory<_2380601899DbContext>
    {
        public _2380601899DbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<_2380601899DbContext>();
            // Default connection string for migration / design time
            var connectionString = "Server=(localdb)\\mssqllocaldb;Database=2380601899Db;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;";
            optionsBuilder.UseSqlServer(connectionString);

            return new _2380601899DbContext(optionsBuilder.Options);
        }
    }
}
