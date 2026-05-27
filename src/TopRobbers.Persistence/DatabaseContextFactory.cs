using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace TopRobbers.Persistence;

public class DatabaseContextFactory : IDesignTimeDbContextFactory<DatabaseContext>
{
    public DatabaseContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<DatabaseContext>();

        var configuration = new ConfigurationBuilder()
           .SetBasePath(Directory.GetCurrentDirectory())
           .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
           .Build();

        optionsBuilder.UseNpgsql(configuration.GetConnectionString("Default"), o => o.MigrationsHistoryTable("migrations", "public"));

        return new DatabaseContext(optionsBuilder.Options);
    }
}
