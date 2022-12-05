using System.Net;

namespace Yeha.Api.TestSdk.Contracts
{
    public interface IResponse
    {
        HttpStatusCode StatusCode { get; }
        string Content { get; }
        T As<T>() where T : class;
    }
}
