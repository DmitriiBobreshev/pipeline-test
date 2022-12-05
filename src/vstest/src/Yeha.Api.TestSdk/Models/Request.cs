using Yeha.Api.TestSdk.Contracts;

namespace Yeha.Api.TestSdk.Models
{
    public class Request : IRequest
    {
        public Request()
        {
        }

        public string Body { get; set; }
        public RestSharp.Method Method { get; set; }
        public string RelativeUrl { get; set; }

    }
}
