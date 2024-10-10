'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "f393d3c16b631f36852323de8e583132",
"CNAME": "3c5b330906fe0382c692f52f4d90477c",
"main.dart.js": "bc8a7329c8b2c28a38690b8aff0e55c6",
"assets/FontManifest.json": "ea489b15cb1e3312372838ae6ec740ef",
"assets/AssetManifest.bin": "8a2b379c6546ccbfe76bcd2c74097b7b",
"assets/fonts/MaterialIcons-Regular.otf": "0c4a456ef1becca7bba3d195197670a8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_soloud/web/worker.dart.js": "c658509d2c513c94a25d5a3fbdf35cd3",
"assets/packages/flutter_soloud/web/libflutter_soloud_plugin.js": "d3bde06cb51d9c04cb66d8c3f09de2aa",
"assets/packages/flutter_soloud/web/libflutter_soloud_plugin.wasm": "59ef6dfded51a61d89a8cbfcccb631c8",
"assets/assets/fonts/Chewy-Regular.ttf": "53ee0977b5f9f3afc1d18b4419264c8b",
"assets/assets/images/pipe.png": "ccbadae55474e53cc16f5268f3a809d5",
"assets/assets/images/background/layer4-clouds.png": "2b5a59fc5807fb764e4c6f34192b8e31",
"assets/assets/images/background/layer3-clouds.png": "c10ca64d4f2023bdd92570fe1ebc7e21",
"assets/assets/images/background/layer5-huge-clouds.png": "4b6724dab35bac39330b592e0483b365",
"assets/assets/images/background/layer7-bushes.png": "4a53ec7605f19a6fb177d8b9b1ee0ffb",
"assets/assets/images/background/layer6-bushes.png": "901377f0826d264105f2707bb1c3367c",
"assets/assets/images/background/layer1-sky.png": "a11d7a7438f401ca5160f51f5c5badbf",
"assets/assets/images/background/layer2-clouds.png": "27824b3fc4099e68b1999c4399fd76f8",
"assets/assets/images/dash.svg": "9ddce3ffed2a02abf0a792ed82135054",
"assets/assets/images/dash.png": "56931f95d9062ce735dc0d92f8e03428",
"assets/assets/images/multi_dash.svg": "0693839b246c67c0d389f525e2135a34",
"assets/assets/images/blurred_background.png": "538676c07a0e09523778815af2f76e8a",
"assets/assets/icons/ic_back.svg": "83e40138f06f8163af486505bc9188fc",
"assets/assets/icons/ic_close.svg": "63bda2f6191ad9b92d72e0d6e5fb2ce9",
"assets/assets/icons/ic_github.svg": "8dcc6b5262f3b6138b1566b357ba89a9",
"assets/assets/icons/ic_profile.svg": "db8773511fbb30df65dde72712699e62",
"assets/assets/icons/ic_trophy.svg": "70e00ec9619fef0830e74631b86005b2",
"assets/assets/icons/ic_youtube.svg": "81efb2f1086f3519e04833f5f0f95953",
"assets/assets/audio/score.mp3": "fd7f3ff3f2c802d1fd238a4378fcb8fb",
"assets/assets/audio/background.mp3": "8cf92b060538044e62ae1b8e40670283",
"assets/NOTICES": "a68ef548ba88c3a1c704835b11173a00",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "4547b4316dc0d5275522ccad4d664191",
"assets/AssetManifest.bin.json": "0022aa2a6bf408ba2cc84c6ab8f1118e",
"index.html": "cdc6835f63e6aba34159d3ca0dffe21f",
"/": "cdc6835f63e6aba34159d3ca0dffe21f",
"manifest.json": "a036124569ebb87280196701e93df03f",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "88941b4c3688ff0aef3dc7ff41415f0a",
"flutter_bootstrap.js": "bb408d946213f78b342200ddedcc75b5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
