using Newtonsoft.Json;
using Yeha.Api.TestSdk.Contracts;
using Yeha.Api.TestSdk.Models;
using Yeha.Api.TestSdk.RequestModels;

namespace Yeha.Api.TestSdk.RequestBuilders
{
    public class AddProductRequestBuilder : RequestBuilderBase<AddProductRequestBuilder>
    {
        private string _id;
        private string _description;

        public AddProductRequestBuilder()
        {
            _id = System.Guid.NewGuid().ToString();
            _description = "Description";
        }

        public AddProductRequestBuilder WithId(string id)
        {
            _id = id;
            return this;
        }

        public AddProductRequestBuilder WithDescription(string description)
        {
            _description = description;
            return this;
        }

        public override IRequest Build()
        {
            var request = new Request()
            {
                Method = RestSharp.Method.POST,
                RelativeUrl = "api/products",
                Body = JsonConvert.SerializeObject(new Product() { Id = _id, Description = _description })
            };

            return request;
        }
    }
}
