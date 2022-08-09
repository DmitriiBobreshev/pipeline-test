using System;
using System.Collections.Generic;
using System.Linq;

using Foundation;
using UIKit;

using Microsoft.Extensions.Caching.Memory;

namespace UsingUITest.iOS
{
	public class Application
	{
		// This is the main entry point of the application.
		static void Main(string[] args)
		{
			// if you want to use a different Application Delegate class from "AppDelegate"
			// you can specify it here.
			IMemoryCache cache = new MemoryCache(new MemoryCacheOptions());
			object result = cache.Set("Key", new object());
			bool found = cache.TryGetValue("Key", out result);
			UIApplication.Main(args, null, "AppDelegate");
		}
	}
}

