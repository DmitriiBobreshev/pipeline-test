using Microsoft.Extensions.Logging;
using Yeha.Api.TestSdk.Contracts;
using Yeha.Api.TestSdk.Models;

namespace Yeha.Api.TestSdk.RequestBuilders
{
    public class GetAllProductsRequestBuilder : RequestBuilderBase<GetAllProductsRequestBuilder>
    {
        public GetAllProductsRequestBuilder()
        {
        }

        public override IRequest Build()
        {
            var request = new Request()
            {
                RelativeUrl = "api/products"
            };

            return request;
        }
    }
}
