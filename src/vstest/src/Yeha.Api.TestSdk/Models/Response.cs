using Newtonsoft.Json;
using RestSharp;
using System.Net;
using Yeha.Api.TestSdk.Contracts;

namespace Yeha.Api.TestSdk.Models
{
    public class Response : IResponse
    {
        private readonly IRestResponse _response;

        public Response(IRestResponse response)
        {
            _response = response;
        }

        public HttpStatusCode StatusCode => _response.StatusCode;

        public string Content => _response.Content;

        public T As<T>() where T: class
        {
            return JsonConvert.DeserializeObject<T>(_response.Content);
        }
    }
}
