import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hymn.dart';
import 'hymn_list.dart';

// Backward compatibility class for legacy code referencing AudioPlayerState
class AudioPlayerState {
  static const PlayerState PLAYING = PlayerState.playing;
  static const PlayerState PAUSED = PlayerState.paused;
  static const PlayerState STOPPED = PlayerState.stopped;
  static const PlayerState COMPLETED = PlayerState.completed;
}

// Global variables
double fontSize = 18.0;
Color bgColor = Colors.transparent;
Color txtColor = Colors.black;
double lineSp = 1.2;
bool nightMode = false;
IconData tuneIcon = play;
IconData play = Icons.play_circle_outline;
IconData pause = Icons.pause_circle_outline;
IconData stop = Icons.stop;
ThemeData themeMode = defaultTheme();

// WebView State
bool isLoaded = false;

// Remote config variables
String app_update = "";
String app_version = "";
String more_apps = 'https://hymnestry.techoveride.com/';
String share_app = 'https://hymnestry.techoveride.com/';
String APP_STORE_URL =
    'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=com.hymnestry.hymn_book&mt=8';
String PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.hymnestry.hymn_book';
String PREMIUM_APP_STORE_URL =
    'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=com.hymnestry.hymn_book_pro&mt=8';
String PREMIUM_PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.hymnestry.hymn_book_pro';

late List<Hymns> defaultHymn;
const fileName = "HymnLyricsEnglish_v1.json";

double _subheadFont = 16.0;
double _titleFontSize = 30.0;

class AppThemeOption {
  final String key;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final ThemeData themeData;

  const AppThemeOption({
    required this.key,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.themeData,
  });
}

ThemeData _buildAppTheme({
  required MaterialColor primarySwatch,
  required Color splash,
  required Color accent,
  required Color secondary,
}) {
  return ThemeData(
    useMaterial3: false,
    primarySwatch: primarySwatch,
    splashColor: splash,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: primarySwatch,
      accentColor: accent,
    ).copyWith(
      secondary: secondary,
      primaryContainer: primarySwatch.shade50,
      onPrimaryContainer: primarySwatch.shade900,
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: splash),
    appBarTheme: AppBarTheme(
      backgroundColor: primarySwatch,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
  );
}

final List<AppThemeOption> availableThemes = [
  AppThemeOption(
    key: 'classic',
    name: 'Sunset Warmth',
    description: 'Classic amber & deep orange warmth',
    primaryColor: Colors.deepOrange,
    accentColor: Colors.orangeAccent,
    themeData: _buildAppTheme(
      primarySwatch: Colors.deepOrange,
      splash: Colors.deepOrangeAccent,
      accent: Colors.orangeAccent,
      secondary: Colors.orange,
    ),
  ),
  AppThemeOption(
    key: 'blue',
    name: 'Heavenly Blue',
    description: 'Peaceful deep sanctuary blue & sky',
    primaryColor: Colors.indigo,
    accentColor: Colors.lightBlueAccent,
    themeData: _buildAppTheme(
      primarySwatch: Colors.indigo,
      splash: Colors.indigoAccent,
      accent: Colors.lightBlueAccent,
      secondary: Colors.blueAccent,
    ),
  ),
  AppThemeOption(
    key: 'emerald',
    name: 'Emerald Grace',
    description: 'Serene garden teal & forest green',
    primaryColor: Colors.teal,
    accentColor: Colors.tealAccent,
    themeData: _buildAppTheme(
      primarySwatch: Colors.teal,
      splash: Colors.tealAccent,
      accent: Colors.tealAccent,
      secondary: Colors.teal,
    ),
  ),
  AppThemeOption(
    key: 'purple',
    name: 'Royal Majesty',
    description: 'Regal liturgical purple & violet',
    primaryColor: Colors.deepPurple,
    accentColor: Colors.purpleAccent,
    themeData: _buildAppTheme(
      primarySwatch: Colors.deepPurple,
      splash: Colors.purpleAccent,
      accent: Colors.purpleAccent,
      secondary: Colors.deepPurpleAccent,
    ),
  ),
];

String currentThemeKey = 'classic';

ThemeData getActiveTheme({String? key, bool? isDark}) {
  final targetKey = key ?? currentThemeKey;
  final dark = isDark ?? nightMode;
  if (dark) {
    Color accent = Colors.orangeAccent;
    if (targetKey == 'blue') accent = Colors.lightBlueAccent;
    if (targetKey == 'emerald') accent = Colors.tealAccent;
    if (targetKey == 'purple') accent = Colors.purpleAccent;

    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        primaryContainer: Colors.grey.shade900,
        onPrimaryContainer: Colors.white70,
      ),
      tabBarTheme: TabBarThemeData(indicatorColor: accent),
    );
  }

  final match = availableThemes.firstWhere(
    (t) => t.key == targetKey,
    orElse: () => availableThemes.first,
  );
  return match.themeData;
}

final ValueNotifier<ThemeData> appThemeNotifier = ValueNotifier<ThemeData>(
  getActiveTheme(),
);

Future<void> setAppTheme(String key) async {
  currentThemeKey = key;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("appTheme", key);
  appThemeNotifier.value = getActiveTheme();
}

Future<void> setNightMode(bool dark) async {
  nightMode = dark;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool("nightMode", dark);
  appThemeNotifier.value = getActiveTheme();
}

// Default theme backwards compatibility
ThemeData defaultTheme() => getActiveTheme(key: 'classic', isDark: false);

TextStyle titleStyle() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: _titleFontSize,
    color: nightMode == false ? txtColor : Colors.white,
  );
}

TextStyle subheadStyle() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: _subheadFont,
    color: nightMode == false ? txtColor : Colors.white,
  );
}

TextStyle lyricStyle() {
  return TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: fontSize,
    height: lineSp,
    color: nightMode == false ? txtColor : Colors.white,
  );
}

AudioPlayer player = AudioPlayer();
PlayerState playerState = PlayerState.stopped;

bool get isPlaying => playerState == PlayerState.playing;
bool get isPaused => playerState == PlayerState.paused;

String mp3Uri = "";
bool fileExists = false;
bool isRemoteTune = false;
bool isTuneCached = false;
int currentHymnIdForTune = 0;

/// Loads tune for playback. Supports:
/// 1. Remote HTTP/HTTPS audio URLs with smart progressive download & caching.
/// 2. Built-in bundled assets (tunes/...)
Future<void> load(String song, {String? tuneSource, int? hymnId}) async {
  currentHymnIdForTune = hymnId ?? int.tryParse(song) ?? 0;
  final cleanTune = tuneSource?.trim() ?? '';

  // 1. Check if tune is already downloaded and cached locally
  try {
    final dir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${dir.path}/tunes_cache/tune_$currentHymnIdForTune.mp3');
    if (cacheFile.existsSync() && cacheFile.lengthSync() > 1024) {
      isRemoteTune = true;
      isTuneCached = true;
      mp3Uri = cacheFile.path;
      fileExists = true;
      debugPrint("Tune for hymn #$currentHymnIdForTune found in offline cache: ${cacheFile.path}");
      return;
    }
  } catch (e) {
    debugPrint("Offline cache directory check error: $e");
  }

  // 2. Check if tune is an HTTP or HTTPS web URL (Stream First, Cache Once)
  if (cleanTune.startsWith('http://') || cleanTune.startsWith('https://')) {
    isRemoteTune = true;
    isTuneCached = false;
    mp3Uri = cleanTune;
    fileExists = false;
    debugPrint("Tune for hymn #$currentHymnIdForTune will stream from URL: $cleanTune");
    return;
  }

  // 3. Local / Bundled Asset Tune
  isRemoteTune = false;
  isTuneCached = true;

  String output = 'default.mp3';
  for (final val in tunes) {
    final startIdx = val.indexOf('a');
    final endIdx = val.indexOf('.');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      final r = val.substring(startIdx + 1, endIdx).trim();
      if (int.tryParse(song) == int.tryParse(r)) {
        output = val;
        break;
      }
    }
  }

  // Ensure local asset tune is extracted to documents directory
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$output');
  fileExists = file.existsSync();
  if (fileExists) {
    debugPrint("Local Tune Already Loaded: ${file.path}");
    mp3Uri = file.path;
  } else {
    try {
      final ByteData data = await rootBundle.load('tunes/$output');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      mp3Uri = file.path;
      debugPrint('Finished loading bundled tune, path=$mp3Uri');
    } catch (e) {
      debugPrint("Failed to load asset tune '$output': $e");
      output = 'default.mp3';
      final defaultFile = File('${dir.path}/$output');
      if (defaultFile.existsSync()) {
        mp3Uri = defaultFile.path;
      } else {
        try {
          final ByteData data = await rootBundle.load('tunes/$output');
          await defaultFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
          mp3Uri = defaultFile.path;
        } catch (err) {
          debugPrint("Failed to load default tune: $err");
          mp3Uri = '';
        }
      }
    }
  }
}

/// Plays the loaded tune.
/// If it's a remote URL and not cached yet, streams over network and caches to disk in background.
/// If offline and not cached, invokes [onOfflineNotification].
Future<void> playSound({
  VoidCallback? onStreamingStarted,
  Function(String message)? onOfflineNotification,
}) async {
  if (mp3Uri.isEmpty) return;

  if (isRemoteTune && !isTuneCached) {
    try {
      // Stream directly over network
      await player.play(UrlSource(mp3Uri));
      onStreamingStarted?.call();

      // Concurrently download and cache for 100% offline future plays!
      _cacheRemoteTuneInBackground(mp3Uri, currentHymnIdForTune);
    } catch (e) {
      debugPrint("Remote playback failed: $e");
      onOfflineNotification?.call(
        "Internet connection required to play and save this tune for offline use.",
      );
      rethrow;
    }
  } else {
    // Play from local device storage (zero data used)
    await player.play(DeviceFileSource(mp3Uri));
  }
}

/// Downloads and stores remote audio file to local storage in background
Future<void> _cacheRemoteTuneInBackground(String url, int hymnId) async {
  if (hymnId <= 0) return;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/tunes_cache');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    final targetFile = File('${cacheDir.path}/tune_$hymnId.mp3');

    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 45),
    );

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      await targetFile.writeAsBytes(response.bodyBytes, flush: true);
      isTuneCached = true;
      mp3Uri = targetFile.path;
      debugPrint("Successfully cached tune for hymn #$hymnId to ${targetFile.path} (${response.bodyBytes.length} bytes)");
    }
  } catch (err) {
    debugPrint("Background tune caching notice (will retry on next play): $err");
  }
}
