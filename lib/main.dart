import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/util/main_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'ads/applifecyclereactor.dart';
import 'ads/appopenadmanager.dart';
import 'firebase_options.dart';

import 'model/db_helper.dart';
import 'service/hymn_sync_service.dart';
import 'state/hymns_notifier.dart';
import 'state/purchase_notifier.dart';
import 'state/reading_settings_notifier.dart';

// local variables
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile ads are supported on Android and iOS only
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (isMobile) {
    try {
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: [
          'A1D024014755730901F48A2A06933E1F',
          '0D7F74813DAA8CF871287A05BE47FDE7'
        ],
      ));

      // Global App Open Ad lifecycle management
      AppOpenAdManager.instance.loadAd();
      AppLifecycleReactor(appOpenAdManager: AppOpenAdManager.instance)
          .listenToAppStateChanges();
    } catch (e) {
      debugPrint("MobileAds initialization error: $e");
    }
  }

  // Safe Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase not initialized for platform: $e");
  }

  // Initialize SQLite database and load hymns
  final dbHelper = DatabaseHelper();
  await dbHelper.initDB();
  globals.defaultHymn = await dbHelper.getHymnsList();

  // Non-blocking background sync check
  HymnSyncService().syncRemoteHymns().then((result) {
    if (result.updatedCount > 0) {
      debugPrint("Background sync: ${result.message}");
      HymnsNotifier.instance.notifyHymnsChanged();
    }
  }).catchError((e) {
    debugPrint("Background sync skipped: $e");
  });

  // Load theme and preferences
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? savedTheme = preferences.getString("appTheme");
  if (savedTheme != null) {
    globals.currentThemeKey = savedTheme;
  }

  bool? status = preferences.getBool("nightMode");
  globals.nightMode = status ?? false;

  // Initialize active theme
  globals.appThemeNotifier.value = globals.getActiveTheme();

  // Load Keep Screen Awake setting
  bool? wakeLockEnabled = preferences.getBool("wakelock");
  try {
    if (wakeLockEnabled == true) {
      await WakelockPlus.enable();
      debugPrint("Screen awake enabled on boot");
    } else {
      await WakelockPlus.disable();
    }
  } catch (e) {
    debugPrint("Boot wakelock setup error: $e");
  }

  // Load hymn Details reading preferences via ReadingSettingsNotifier
  await ReadingSettingsNotifier.instance.init(preferences);

  // Initialize In-App Purchases & Pro status
  await PurchaseNotifier.instance.init();

  // Listen for legacy nightMode stream events from drawer
  isLightTheme.stream.listen((isDark) {
    globals.setNightMode(isDark);
  });

  runApp(const MyApp());
}

final StreamController<bool> isLightTheme = StreamController<bool>.broadcast();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: globals.appThemeNotifier,
      builder: (context, activeTheme, _) {
        return MaterialApp(
          theme: activeTheme,
          debugShowCheckedModeBanner: false,
          home: const MasterDetailsScreen(),
        );
      },
    );
  }
}
