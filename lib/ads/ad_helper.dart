import 'dart:io';

import 'package:flutter/foundation.dart';
import '../state/purchase_notifier.dart';

/// Centralized manager for AdMob App IDs and Ad Unit IDs.
/// Uses official Google Test IDs during development (kDebugMode) to protect
/// against invalid traffic penalties, and switches to live production IDs in release mode.
class AdHelper {
  // Real AdMob App IDs
  static const String androidAppId = 'ca-app-pub-2165165254805026~3278444117';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458602516'; // Replace with live iOS App ID when registered in AdMob

  // Live Production Ad Unit IDs
  static const String _liveAndroidBannerId = 'ca-app-pub-2165165254805026/8683500374';
  static const String _liveAndroidAppOpenId = 'ca-app-pub-2165165254805026/6522356999';

  // Google Official Test Ad Unit IDs
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static const String _testAndroidAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testIosAppOpenId = 'ca-app-pub-3940256099942544/5575463023';

  /// Whether current platform supports Google Mobile Ads (Android & iOS only)
  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether ads should be displayed (disabled for Pro users and non-mobile platforms)
  static bool get shouldShowAds =>
      isSupportedPlatform && !PurchaseNotifier.instance.isPro;

  /// Returns the adaptive banner ad unit ID based on platform and build mode
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testAndroidBannerId : _testIosBannerId;
    }
    return Platform.isAndroid ? _liveAndroidBannerId : _testIosBannerId;
  }

  /// Returns the app open ad unit ID based on platform and build mode
  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testAndroidAppOpenId : _testIosAppOpenId;
    }
    return Platform.isAndroid ? _liveAndroidAppOpenId : _testIosAppOpenId;
  }
}
