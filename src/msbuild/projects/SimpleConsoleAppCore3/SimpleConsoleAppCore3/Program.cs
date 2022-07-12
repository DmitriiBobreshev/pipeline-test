using System;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.IO;

namespace SimpleConsoleAppCore3
{
    class Program
    {
        const string filePath = @"json.txt";

        
        public static void Serialize(object obj)
        {
            var serializer = new JsonSerializer();        
            // serializer.MaxDepth = 32;

            using (var sw = new StreamWriter(filePath))
            using (JsonWriter writer = new JsonTextWriter(sw))
            {
                serializer.Serialize(writer, obj);           
            }
        }
    
        public static object Deserialize(string path)
        {
            var serializer = new JsonSerializer();         
            // serializer.MaxDepth = 32;
    
            using (var sw = new StreamReader(path))
            using (var reader = new JsonTextReader(sw))
            {
                return serializer.Deserialize(reader);
            }
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            var deserialized = Deserialize(@"example.json");
            Console.WriteLine(deserialized);
            
            Serialize(deserialized);
        }
    }
}
