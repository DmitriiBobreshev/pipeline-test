using Microsoft.Extensions.DependencyInjection;
using Yeha.Api.TestSdk.Contracts;
using Yeha.Api.TestSdk.RequestBuilders;
using Yeha.Api.TestSdk.Services;

namespace Yeha.Api.TestSdk.Infrastructure
{
    public static class Container
    {
        public static void Populate(IServiceCollection container, TestSettings testSettings)
        {
            container.AddScoped<GetAllProductsRequestBuilder>();
            container.AddScoped<AddProductRequestBuilder>();
            container.AddScoped<GetPingAuthorizedByMiddlewareBuilder>();
            container.AddScoped<RemoveAllProductsBuilder>();
            container.AddScoped<IClient, Client>();
        }
    }
}
