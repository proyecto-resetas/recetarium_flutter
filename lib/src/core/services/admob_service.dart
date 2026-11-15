import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  AdMobService._internal();
  static final AdMobService instance = AdMobService._internal();

  bool _isInitialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isLoadingRewarded = false;
  bool _isLoadingInterstitial = false;

  /// Determina si la plataforma actual soporta el SDK nativo de Google Mobile Ads
  static bool get isNativeMobileAdsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Configuración de Google AdSense para Flutter Web (inyectada por --dart-define).
  static String get adsenseClientId => const String.fromEnvironment(
        'ADSENSE_CLIENT_ID',
        defaultValue: '',
      );

  static String get adsenseBannerSlotId => const String.fromEnvironment(
        'ADSENSE_BANNER_SLOT',
        defaultValue: '',
      );

  static bool get hasWebAdSenseConfig =>
      kIsWeb && adsenseClientId.isNotEmpty && adsenseBannerSlotId.isNotEmpty;

  // ─── Ad Unit IDs (IDs oficiales de prueba de Google por defecto; configurables por dart-define) ─
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_IOS',
        defaultValue: 'ca-app-pub-3940256099942544/2934735716',
      );
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544/1033173712',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_IOS',
        defaultValue: 'ca-app-pub-3940256099942544/4411468910',
      );
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'ADMOB_REWARDED_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544/5224354917',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'ADMOB_REWARDED_IOS',
        defaultValue: 'ca-app-pub-3940256099942544/1712485313',
      );
    }
    return '';
  }

  Future<void> initialize() async {
    if (_isInitialized || !isNativeMobileAdsSupported) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadRewardedAd();
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  void preloadRewardedAd() {
    if (!isNativeMobileAdsSupported || _isLoadingRewarded || _rewardedAd != null) {
      return;
    }
    _isLoadingRewarded = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoadingRewarded = false;
        },
      ),
    );
  }

  void preloadInterstitialAd() {
    if (!isNativeMobileAdsSupported ||
        _isLoadingInterstitial ||
        _interstitialAd != null) {
      return;
    }
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  /// Muestra un anuncio recompensado para desbloquear una receta gratuita.
  /// En Android/iOS usa el RewardedAd nativo de Google AdMob; en Web (o si el SDK no tiene fill)
  /// muestra un modal patrocinado de 4 segundos para garantizar el flujo.
  Future<bool> showRewardedAdToUnlockRecipe(
    BuildContext context, {
    required String recipeName,
  }) async {
    if (isNativeMobileAdsSupported && _rewardedAd != null) {
      final completer = Completer<bool>();
      bool earned = false;
      final ad = _rewardedAd!;
      _rewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          preloadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(earned);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          preloadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          earned = true;
        },
      );

      return completer.future;
    }

    // Si aún no cargó en móvil, intentar recargar para la próxima y mostrar el diálogo patrocinado
    if (isNativeMobileAdsSupported) {
      preloadRewardedAd();
    }

    if (!context.mounted) return false;
    return await _showSponsoredCountdownDialog(
          context,
          recipeName: recipeName,
        ) ??
        false;
  }

  /// Muestra un anuncio intersticial al finalizar una receta gratuita.
  Future<void> showInterstitialAdIfAvailable() async {
    if (!isNativeMobileAdsSupported || _interstitialAd == null) {
      if (isNativeMobileAdsSupported) preloadInterstitialAd();
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadInterstitialAd();
      },
    );
    await ad.show();
  }

  Future<bool?> _showSponsoredCountdownDialog(
    BuildContext context, {
    required String recipeName,
  }) async {
    int secondsLeft = 3;
    Timer? timer;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (!ctx.mounted) {
                t.cancel();
                return;
              }
              if (secondsLeft > 1) {
                setDialogState(() => secondsLeft--);
              } else {
                setDialogState(() => secondsLeft = 0);
                t.cancel();
              }
            });

            return Dialog(
              backgroundColor: const Color(0xFF1B2332),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD166),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ANUNCIO • GOOGLE ADMOB',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B2332),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              secondsLeft > 0
                                  ? 'Recompensa en ${secondsLeft}s'
                                  : '¡Receta desbloqueada!',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE66838), Color(0xFFF39C12)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 46,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Recetarium Patrocinado',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Estás desbloqueando gratis el paso a paso de "$recipeName" gracias a nuestros patrocinadores.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              timer?.cancel();
                              Navigator.of(ctx).pop(false);
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: secondsLeft == 0
                                ? () {
                                    timer?.cancel();
                                    Navigator.of(ctx).pop(true);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D8A56),
                              disabledBackgroundColor:
                                  Colors.white.withValues(alpha: 0.14),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              secondsLeft == 0
                                  ? Icons.lock_open_rounded
                                  : Icons.hourglass_top_rounded,
                              size: 17,
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                secondsLeft == 0
                                    ? 'Ver Paso a Paso'
                                    : 'Espera ${secondsLeft}s…',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
