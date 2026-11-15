import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

@JS('adsbygoogle')
external JSArray<JSAny>? get _adsByGoogle;

@JS('adsbygoogle')
external set _adsByGoogle(JSArray<JSAny>? value);

extension type _AdsArray(JSArray<JSAny> _) {
  external void push(JSAny item);
}

int _viewCounter = 0;
bool _scriptInjected = false;

void _ensureAdSenseScript(String clientId) {
  if (_scriptInjected) return;
  final existing = web.document.querySelector(
    'script[src*="pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]',
  );
  if (existing != null) {
    _scriptInjected = true;
    return;
  }

  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.async = true;
  script.crossOrigin = 'anonymous';
  script.src =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=$clientId';
  web.document.head?.appendChild(script);
  _scriptInjected = true;
}

/// Construye un banner real de Google AdSense en Flutter Web mediante HtmlElementView.
Widget? buildWebAdSenseBanner({
  required String clientId,
  required String slotId,
  double height = 60,
}) {
  if (clientId.isEmpty || slotId.isEmpty) return null;

  _ensureAdSenseScript(clientId);
  final viewType = 'recetarium-adsense-${++_viewCounter}';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final container = web.document.createElement('div') as web.HTMLDivElement;
    container.style.width = '100%';
    container.style.height = '${height.toInt()}px';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.justifyContent = 'center';
    container.style.overflow = 'hidden';

    final ins = web.document.createElement('ins') as web.HTMLElement;
    ins.className = 'adsbygoogle';
    ins.style.display = 'block';
    ins.style.width = '100%';
    ins.style.height = '${height.toInt()}px';
    ins.setAttribute('data-ad-client', clientId);
    ins.setAttribute('data-ad-slot', slotId);
    ins.setAttribute('data-ad-format', 'auto');
    ins.setAttribute('data-full-width-responsive', 'true');

    container.appendChild(ins);

    // Dispara la carga del slot cuando el DOM está listo.
    Future.microtask(() {
      try {
        final arr = _adsByGoogle ?? JSArray<JSAny>();
        _AdsArray(arr).push(JSObject());
        _adsByGoogle = arr;
      } catch (_) {}
    });

    return container;
  });

  return SizedBox(
    width: double.infinity,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
