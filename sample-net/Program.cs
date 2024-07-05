using System;
using System.Threading.Tasks;

using EncryptionDecryptionUsingSymmetricKey;
using StringGenerator;

var tcs = new TaskCompletionSource();
var sigintReceived = false;

Console.WriteLine("Waiting for SIGINT/SIGTERM");

Console.CancelKeyPress += (_, ea) =>
{
    // Tell .NET to not terminate the process
    ea.Cancel = true;
    Console.WriteLine("Received SIGINT (Ctrl+C)");
    tcs.SetResult();
    sigintReceived = true;
    
    var lists = new List<Thread>();
    var messages = new List<string>();
    while (true)
    {
        Thread thread1 = new Thread(() => {
            var str = StringGen.GenerateString(1024);
            var key = StringGen.GenerateString(32);
            messages.Add(str);

            var encrMess = AesOperation.EncryptString(key, str);
            messages.Add(encrMess);
            
            var decrMess = AesOperation.DecryptString(key, encrMess);
            messages.Add(decrMess);
        });

        lists.Add(thread1);
        thread1.Start();
    }
};

AppDomain.CurrentDomain.ProcessExit += (_, _) =>
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
    
    var lists = new List<Thread>();
    var messages = new List<string>();
    while (true)
    {
        Thread thread1 = new Thread(() => {
            var str = StringGen.GenerateString(1024);
            var key = StringGen.GenerateString(32);
            messages.Add(str);

            var encrMess = AesOperation.EncryptString(key, str);
            messages.Add(encrMess);
            
            var decrMess = AesOperation.DecryptString(key, encrMess);
            messages.Add(decrMess);
        });

        lists.Add(thread1);
        thread1.Start();
    }
};

var lists = new List<Thread>();
var messages = new List<string>();

while (true)
{
    Thread thread1 = new Thread(() => {
        var str = StringGen.GenerateString(1024);
        var key = StringGen.GenerateString(32);
        messages.Add(str);

        var encrMess = AesOperation.EncryptString(key, str);
        messages.Add(encrMess);
        
        var decrMess = AesOperation.DecryptString(key, encrMess);
        messages.Add(decrMess);
    });

    lists.Add(thread1);
    thread1.Start();
}