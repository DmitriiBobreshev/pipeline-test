using Microsoft.Extensions.Logging;
using Yeha.Api.TestSdk.Contracts;
using Yeha.Api.TestSdk.Models;

namespace Yeha.Api.TestSdk.RequestBuilders
{
    public class GetPingAuthorizedByMiddlewareBuilder  : RequestBuilderBase<GetAllProductsRequestBuilder>
    {
        public GetPingAuthorizedByMiddlewareBuilder()
        {
        }

        public override IRequest Build()
        {
            var request = new Request()
            {
                RelativeUrl = "api/pingAuthorizedByMiddleware"
            };

            return request;
        }
    }
}
