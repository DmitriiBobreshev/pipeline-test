using System.Collections.Generic;
using Yeha.Api.Models;

namespace Yeha.Api.Contracts
{
    public interface IProductRepository
    {
        void Add(IProduct product);
        IEnumerable<Product> GetAll();
        void RemoveAll();
    }
}
