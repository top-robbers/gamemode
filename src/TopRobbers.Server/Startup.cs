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

    public void ConfigureServices(IServiceCollection services)
    {

    }

    public void Configure(IEcsBuilder builder)
    {

    }
}