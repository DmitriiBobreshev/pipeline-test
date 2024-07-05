using System;
using System.Threading.Tasks;

using EncryptionDecryptionUsingSymmetricKey;
using StringGenerator;

var tcs = new TaskCompletionSource();
var sigintReceived = false;

Console.WriteLine("Waiting for SIGINT/SIGTERM");

var lists = new List<Task>();
var messages = new List<string>();

Console.CancelKeyPress += async (_, ea) =>
{
    // Tell .NET to not terminate the process
    ea.Cancel = true;
    Console.WriteLine("Received SIGINT (Ctrl+C)");
    tcs.SetResult();
    sigintReceived = true;
    await Task.WhenAll(lists);
};

AppDomain.CurrentDomain.ProcessExit += async(_, _) =>
{
    if (!sigintReceived)
    {
        Console.WriteLine("Received SIGTERM");
        tcs.SetResult();
    }
    else
    {
        Console.WriteLine("Received SIGTERM, ignoring it because already processed SIGINT");
    }
    await Task.WhenAll(lists);
};


while (true)
{
    lists.Add(Task.Run(() => {
        while (true) {
            var str = StringGen.GenerateString(1024);
            var key = StringGen.GenerateString(32);
            messages.Add(str);

            var encrMess = AesOperation.EncryptString(key, str);
            messages.Add(encrMess);
            
            var decrMess = AesOperation.DecryptString(key, encrMess);
            messages.Add(decrMess);
        }
    }));
}