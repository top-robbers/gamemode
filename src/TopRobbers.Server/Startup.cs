using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace TopRobbers.Server;

public class Startup : IEcsStartup
{
    public void Initialize(IStartupContext context)
    {
        context
            .UseEntities()
            .UseCommands();
    }

    public void ConfigureServices(IServiceCollection services, IConfiguration configuration)
    {

    }

    public void Configure(IEcsBuilder builder)
    {

    }
}