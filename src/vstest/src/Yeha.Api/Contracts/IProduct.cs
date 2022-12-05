using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Yeha.Api.Contracts
{
    public interface IProduct
    {
        string Id { get; set; }
        string Description { get; set; }
    }
}
