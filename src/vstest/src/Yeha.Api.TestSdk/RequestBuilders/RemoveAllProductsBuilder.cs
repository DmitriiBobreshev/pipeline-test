using Microsoft.Extensions.Logging;
using Yeha.Api.TestSdk.Contracts;
using Yeha.Api.TestSdk.Models;

namespace Yeha.Api.TestSdk.RequestBuilders
{
    public class RemoveAllProductsBuilder : RequestBuilderBase<GetAllProductsRequestBuilder>
    {
        public RemoveAllProductsBuilder()
        {
        }

        public override IRequest Build()
        {
            var request = new Request()
            {
                Method = RestSharp.Method.DELETE,
                RelativeUrl = "api/products"
            };

            return request;
        }
    }
}
