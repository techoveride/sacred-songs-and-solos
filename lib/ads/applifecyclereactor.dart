import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'appopenadmanager.dart';

/// Listens for app foreground/resume events and shows app open ads exclusively on app resume.
class AppLifecycleReactor with WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;
  bool _isBackgrounded = false;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _isBackgrounded = true;
      if (!appOpenAdManager.isAdAvailable) {
        appOpenAdManager.loadAd();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBackgrounded) {
        _isBackgrounded = false;
        if (kDebugMode) {
          debugPrint("App resumed from background: showing AppOpenAd");
        }
        appOpenAdManager.showAdIfAvailable();
      }
    }
  }

  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.background) {
      _isBackgrounded = true;
      if (!appOpenAdManager.isAdAvailable) {
        appOpenAdManager.loadAd();
      }
    } else if (appState == AppState.foreground) {
      if (_isBackgrounded) {
        _isBackgrounded = false;
        if (kDebugMode) {
          debugPrint("AdMob AppState.foreground: showing AppOpenAd");
        }
        appOpenAdManager.showAdIfAvailable();
      }
    }
  }
}
