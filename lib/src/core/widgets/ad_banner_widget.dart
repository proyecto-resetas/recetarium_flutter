import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:recetarium/src/core/services/admob_service.dart';
import 'package:recetarium/src/core/widgets/web_adsense_banner.dart';

class AdBannerWidget extends StatefulWidget {
  final String placementLabel;
  final EdgeInsetsGeometry margin;

  const AdBannerWidget({
    super.key,
    this.placementLabel = 'Espacio publicitario • Recetas Gratuitas',
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Widget? _webAdSenseWidget;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (AdMobService.hasWebAdSenseConfig) {
      _webAdSenseWidget = buildWebAdSenseBanner(
        clientId: AdMobService.adsenseClientId,
        slotId: AdMobService.adsenseBannerSlotId,
      );
      return;
    }

    if (!AdMobService.isNativeMobileAdsSupported) return;
    final unitId = AdMobService.bannerAdUnitId;
    if (unitId.isEmpty) return;

    final banner = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $error');
        },
      ),
    );
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_webAdSenseWidget != null) {
      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        child: _webAdSenseWidget,
      );
    }

    if (AdMobService.isNativeMobileAdsSupported &&
        _isLoaded &&
        _bannerAd != null) {
      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Contenedor visual elegante de respaldo (para Web sin IDs configurados o mientras carga en móvil)
    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E2DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFD166)),
            ),
            child: const Text(
              kIsWeb ? 'AdSense' : 'AdMob',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF856404),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.placementLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2332),
                  ),
                ),
                const Text(
                  'Descubre utensilios, ingredientes y recetas patrocinadas en Recetarium',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6E7685),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.open_in_new_rounded,
            size: 16,
            color: Color(0xFFE66838),
          ),
        ],
      ),
    );
  }
}
