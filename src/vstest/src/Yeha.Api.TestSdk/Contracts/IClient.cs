using System.Net;

namespace Yeha.Api.TestSdk.Contracts
{
    public interface IClient
    {
        IResponse Execute(IRequest request, HttpStatusCode andExpect);
    }
}
