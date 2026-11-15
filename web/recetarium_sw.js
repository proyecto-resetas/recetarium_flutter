'use strict';

// Service worker de la PWA Recetarium.
// Estrategia "network-first": siempre intenta la red (para obtener la última
// versión desplegada) y usa la caché solo cuando no hay conexión.
// Solo gestiona peticiones GET del mismo origen; las llamadas a la API
// (otro dominio) pasan directo a la red.

const CACHE_NAME = 'recetarium-cache-v1';
const APP_SHELL = [
  './',
  'index.html',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)),
      );
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      try {
        const response = await fetch(request);
        if (response && response.ok) {
          cache.put(request, response.clone());
        }
        return response;
      } catch (_) {
        const cached = await cache.match(request);
        if (cached) return cached;
        // Navegación sin conexión: devolver el shell de la app
        if (request.mode === 'navigate') {
          const shell = await cache.match('index.html');
          if (shell) return shell;
        }
        throw _;
      }
    })(),
  );
});
