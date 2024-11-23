'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "f393d3c16b631f36852323de8e583132",
"CNAME": "3c5b330906fe0382c692f52f4d90477c",
"main.dart.wasm": "ef94aa9d3a74045012132a82078f0607",
"main.dart.js": "8657cb9071323440bb2bf745ab75eb04",
"main.dart.mjs": "4f3f45cad73f95c801ed73a91d7f35c8",
"assets/FontManifest.json": "b575fc56f51ada19bae272d1e4146bde",
"assets/AssetManifest.bin": "126f0f717f0144486881caecc9c53506",
"assets/fonts/MaterialIcons-Regular.otf": "c0c0d34020406787bbc42050087c4631",
"assets/packages/iconsax_flutter/fonts/FlutterIconsax.ttf": "83c878235f9c448928034fe5bcba1c8a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/share_plus_dialog/lib/fonts/SocialsIcons.ttf": "1c6067ea0aefee73fcbb673eab99c60d",
"assets/packages/flutter_soloud/web/worker.dart.js": "c658509d2c513c94a25d5a3fbdf35cd3",
"assets/packages/flutter_soloud/web/libflutter_soloud_plugin.js": "d3bde06cb51d9c04cb66d8c3f09de2aa",
"assets/packages/flutter_soloud/web/libflutter_soloud_plugin.wasm": "59ef6dfded51a61d89a8cbfcccb631c8",
"assets/assets/fonts/Chewy-Regular.ttf": "53ee0977b5f9f3afc1d18b4419264c8b",
"assets/assets/images/pipe.png": "ccbadae55474e53cc16f5268f3a809d5",
"assets/assets/images/background/layer4-clouds.png": "39f85052dd79e18ff8c5f5229b0936de",
"assets/assets/images/background/layer3-clouds.png": "3db7a5a18357d9a99d77651f7212886c",
"assets/assets/images/background/layer5-huge-clouds.png": "1c8fc9133672d14d3fce14d608c4701c",
"assets/assets/images/background/layer7-bushes.png": "49cfa7c605a0f0a0faacab7f3e5cda6c",
"assets/assets/images/background/layer6-bushes.png": "5123c114769ed9dd086aaa50e9fa025f",
"assets/assets/images/background/layer1-sky.png": "eaca695464b3b8a9ce918075c26acd11",
"assets/assets/images/background/layer2-clouds.png": "2d298c3ccbc53cbefaaa0390900b6485",
"assets/assets/images/dash.png": "56931f95d9062ce735dc0d92f8e03428",
"assets/assets/images/dashes/peachy_dash.svg": "fa80e0493be7fc1107eaf0712b7f5ecc",
"assets/assets/images/dashes/rose_dash.png": "670c447e2ebc016581b70975050c5b92",
"assets/assets/images/dashes/peachy_dash.png": "79d02fdd1f456bdc0c7e8f8d1d6bb10d",
"assets/assets/images/dashes/lime_dash.png": "92b67d94298e414f36cecdfb34adca2e",
"assets/assets/images/dashes/violet_dash.svg": "5931b89a446e9d033bbf7f22099c9da3",
"assets/assets/images/dashes/rose_dash.svg": "ed5d217e8f4a6ca01d373b40a9ba9bc5",
"assets/assets/images/dashes/sunny_dash.png": "24fbac84d2add52a6e5fd955c06b9a50",
"assets/assets/images/dashes/sky_dash.png": "b902cd9f51181d497c0e49d0e4e2c7e2",
"assets/assets/images/dashes/sand_dash.svg": "fb8d4480168cdd19bebb09d16753e20e",
"assets/assets/images/dashes/minty_dash.png": "c150dce7ee4d6bf603f28a43e2724c72",
"assets/assets/images/dashes/lime_dash.svg": "95a754cb57d669ec19d5eab126fded22",
"assets/assets/images/dashes/sunny_dash.svg": "8c4dab3d92651f0a92200b5830c17100",
"assets/assets/images/dashes/flutter_dash.png": "72b9fdf7bf5562b08c106f1ceaee68aa",
"assets/assets/images/dashes/scarlet_dash.png": "d5c3aecd235fb7e4f7b88e94b16052f1",
"assets/assets/images/dashes/minty_dash.svg": "19c48cf6876cd4dda449ac2a1eef0209",
"assets/assets/images/dashes/violet_dash.png": "82378d302cca033083e58bc7ae456b7f",
"assets/assets/images/dashes/sky_dash.svg": "cc8de1d6d476b06c097cc00925369e2c",
"assets/assets/images/dashes/scarlet_dash.svg": "3aef89da948511af4da90a331958f534",
"assets/assets/images/dashes/flutter_dash.svg": "9ddce3ffed2a02abf0a792ed82135054",
"assets/assets/images/dashes/sand_dash.png": "646c3e70c5fa60f6803ba2022696803d",
"assets/assets/images/trophies/trophy3.svg": "eda4dbf380c068696935a13d6b686225",
"assets/assets/images/trophies/trophy2.svg": "8d1534822682f0446c9d07e4f67b566a",
"assets/assets/images/trophies/trophy1.svg": "1cda26afacc40835982162ffd5c63feb",
"assets/assets/images/multi_dash.svg": "0693839b246c67c0d389f525e2135a34",
"assets/assets/images/logo.png": "276a3da0529b5f057928cfa90ee5a753",
"assets/assets/images/blurred_background.png": "538676c07a0e09523778815af2f76e8a",
"assets/assets/images/portal.png": "f2f64637dda305f0f4a8eab4b3a1f52a",
"assets/assets/icons/ic_back.svg": "83e40138f06f8163af486505bc9188fc",
"assets/assets/icons/ic_share.svg": "cb5d32bf25018f759d6cdbc484eeb059",
"assets/assets/icons/ic_qr.svg": "0c949e7ec7cdc32137c784502b458066",
"assets/assets/icons/ic_home.svg": "83a4b484c2766ec3a052d3fa4ed4ada2",
"assets/assets/icons/ic_menu.svg": "ba05c07cf42de65584dfa04b9c6fe66f",
"assets/assets/icons/ic_close.svg": "63bda2f6191ad9b92d72e0d6e5fb2ce9",
"assets/assets/icons/ic_github.svg": "8dcc6b5262f3b6138b1566b357ba89a9",
"assets/assets/icons/ic_profile.svg": "db8773511fbb30df65dde72712699e62",
"assets/assets/icons/ic_trophy.svg": "70e00ec9619fef0830e74631b86005b2",
"assets/assets/icons/ic_youtube.svg": "81efb2f1086f3519e04833f5f0f95953",
"assets/assets/audio/score.mp3": "fd7f3ff3f2c802d1fd238a4378fcb8fb",
"assets/assets/audio/background.mp3": "3431c779f2b5ed847fde5e16c408fb69",
"assets/NOTICES": "cc0024c79988b4545d9d1ff103ca1dd2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/social-preview.png": "4ca7a5ab6c8c1ab23e1e68faf8165d1b",
"assets/AssetManifest.json": "0401be9ccdf47b92b30443e50fd70078",
"assets/AssetManifest.bin.json": "bb0dc1570b7eac7bc93b56392191920c",
"index.html": "675789773e85a6c5e8a3af9d7d26a3e0",
"/": "675789773e85a6c5e8a3af9d7d26a3e0",
"manifest.json": "7fdc3631400d263bc71c17a0d4ddfc5a",
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
"icons/Icon-maskable-192.png": "7e19c3f935c05a4e6cdb056a3a0c3443",
"icons/Icon-192.png": "7e19c3f935c05a4e6cdb056a3a0c3443",
"icons/Icon-512.png": "b9ee0af6358d9ee032b9de65c831da46",
"icons/Icon-maskable-512.png": "b9ee0af6358d9ee032b9de65c831da46",
"favicon.png": "cb36c7f9077eb3358b6dc8a6239b5685",
"version.json": "131c45fc0e34b60e8a93b5aaecbfd5fc",
"flutter_bootstrap.js": "8b53cb1623a2ea259f3a5ed9001383d0"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
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
