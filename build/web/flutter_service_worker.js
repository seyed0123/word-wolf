'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"apple-touch-icon.png": "5e49593624f57d09fde2fb34de0e0d16",
"assets/AssetManifest.json": "f55db809e3bb75103e5da02d42e6ad39",
"assets/AssetManifest.smcbin": "f11f27145d2be45902860a565c92bd30",
"assets/assets/Absolute%2520Chad.jpg": "d47d16c156c38eef7d4f41f8c7bcd830",
"assets/assets/Absolute%2520Giga%2520Chad.jpg": "9a823d2a38b8467ad105222a1c4c75ed",
"assets/assets/Average.jpg": "297ea656ca68ad58bd327055f0466086",
"assets/assets/Chad.jpg": "ee2d3c8b5deb37e7ee5186391145677a",
"assets/assets/Clown.jpg": "2e8160f52aa9465a45c141947a6d4905",
"assets/assets/env.txt": "6c3ca1eedee2df0b2d0c7bbf49e75c35",
"assets/assets/favicon.png": "9f3b2b0e408d76ee957193cce8cbc35f",
"assets/assets/flag_of_Any.png": "d5ed4f48eee617ad08ceba231325c34d",
"assets/assets/flag_of_Arabic.png": "d1dd72dad5a901425242cda8b6861642",
"assets/assets/flag_of_English.png": "03c3d4d3a8e8950af518ed1f64bf8d9a",
"assets/assets/flag_of_French.png": "2eae9ede26e81477e8d96f605ee37283",
"assets/assets/flag_of_German.png": "9181b436a8db762bdacacca530218247",
"assets/assets/flag_of_Persian.png": "dc3f4924dda1b5b96542cd7b454bf177",
"assets/assets/flag_of_Spanish.png": "54f57045ce4ead1bb195b1d0681706e2",
"assets/assets/Giga%2520Chad.jpg": "2bd54e1dffa9f73a31ee345e1171e778",
"assets/assets/icon1.jpg": "07af8e5be4d863cf143af25551ff6c3e",
"assets/assets/icon2.jpg": "e68b6441a204f98291d7ac5f2cf1e75d",
"assets/assets/Noob.jpg": "8d88f0d921cc5d443cd1950b9494a0ef",
"assets/assets/Novice.jpg": "5a95e2d24fa71bce4d2bb471303963af",
"assets/assets/Sigma.jpg": "8e4290834d300885ad609b41f2a472ba",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "74bd8514a01f12fef6c450da8fc50a88",
"assets/NOTICES": "f0ccc29560f5c75c525010ad1cf26562",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.ico": "4d4ea9e860b35ab8a210ce8e496496ac",
"favicon.png": "9f3b2b0e408d76ee957193cce8cbc35f",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icon-192-maskable.png": "dbfe17d3a9917f15d0d3f62868b30157",
"icon-192.png": "bbdaa7ac3b5300055aeaa54c7e4e0704",
"icon-512-maskable.png": "cd3419fbd589f977a22605f0e29ba1b0",
"icon-512.png": "98dfe033c41ac4f7d268036f1d91940e",
"icons/Icon-192.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-512.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-maskable-192.png": "d41d8cd98f00b204e9800998ecf8427e",
"icons/Icon-maskable-512.png": "d41d8cd98f00b204e9800998ecf8427e",
"index.html": "2c6de5367f2753014493348ce58c7bc9",
"/": "2c6de5367f2753014493348ce58c7bc9",
"main.dart.js": "dca57b8766f55df399e15a62b3471993",
"manifest.json": "54f962537e9299fe990847ccbacf2181",
"README.txt": "75a4b40628d621e7140600213104e158",
"version.json": "2277a99b40a8278ed01d686f8b1f2094"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
