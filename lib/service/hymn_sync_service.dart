import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/hymn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncResult {
  final bool success;
  final int updatedCount;
  final int currentVersion;
  final String message;

  SyncResult({
    required this.success,
    required this.updatedCount,
    required this.currentVersion,
    required this.message,
  });
}

class HymnSyncService {
  static const String prefLastSyncTime = "hymn_last_sync_timestamp";
  static const String prefSyncVersion = "hymn_data_sync_version";

  // Remote Config parameter keys
  static const String rcHymnVersionKey = "hymn_catalog_version";
  static const String rcHymnUpdatesUrlKey = "hymn_updates_url";

  // Default fallback URL if Remote Config key is empty
  static const String fallbackSyncEndpoint =
      "https://raw.githubusercontent.com/hymnestry/hymns-manifest/main/hymn_updates.json";

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Gets the local synced version from SharedPreferences (defaults to 1)
  Future<int> getLocalSyncVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefSyncVersion) ?? 1;
  }

  /// Checks for and applies remote hymn updates via Firebase Remote Config
  Future<SyncResult> syncRemoteHymns({bool forceSync = false, String? directUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final int localVersion = prefs.getInt(prefSyncVersion) ?? 1;

    int targetVersion = localVersion;
    String targetUrl = directUrl ?? fallbackSyncEndpoint;

    // 1. Fetch parameters from Firebase Remote Config if not using a direct URL
    if (directUrl == null) {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ));
        await remoteConfig.fetchAndActivate();

        final int rcVersion = remoteConfig.getInt(rcHymnVersionKey);
        final String rcUrl = remoteConfig.getString(rcHymnUpdatesUrlKey).trim();
        debugPrint("Remote Config fetch result: $rcHymnVersionKey = $rcVersion, $rcHymnUpdatesUrlKey = '$rcUrl'");

        if (rcVersion > 0) {
          targetVersion = rcVersion;
        }
        if (rcUrl.isNotEmpty) {
          targetUrl = rcUrl;
        }
      } catch (e) {
        debugPrint("Remote Config fetch error: $e");
      }
    }

    // 2. Check if an update is actually needed (skip network download if already on latest version)
    if (!forceSync && targetVersion <= localVersion) {
      return SyncResult(
        success: true,
        updatedCount: 0,
        currentVersion: localVersion,
        message: "Hymns are up to date (Version $localVersion).",
      );
    }

    // 3. Fetch the update manifest JSON
    try {
      final uri = Uri.parse(targetUrl);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 12),
        onTimeout: () => http.Response('{"error": "timeout"}', 408),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        List<dynamic> hymnListJson = [];
        int? incomingManifestVersion;

        if (decoded is List) {
          hymnListJson = decoded;
        } else if (decoded is Map<String, dynamic>) {
          incomingManifestVersion = decoded['manifest_version'] is int ? decoded['manifest_version'] : null;
          if (decoded['hymns'] is List) {
            hymnListJson = decoded['hymns'];
          }
        }

        if (hymnListJson.isEmpty) {
          return SyncResult(
            success: true,
            updatedCount: 0,
            currentVersion: localVersion,
            message: "No new hymns found in update manifest.",
          );
        }

        final List<Hymns> incomingHymns = hymnListJson.map((item) {
          if (item is Map<String, dynamic>) {
            return Hymns.fromJson(item);
          } else {
            return Hymns.fromJson(Map<String, dynamic>.from(item));
          }
        }).toList();

        // 4. Batch upsert into SQLite safely
        final count = await _dbHelper.batchUpsertOfficialHymns(incomingHymns);

        final newVersion = incomingManifestVersion ?? targetVersion;
        await prefs.setInt(prefLastSyncTime, DateTime.now().millisecondsSinceEpoch);
        await prefs.setInt(prefSyncVersion, newVersion);

        return SyncResult(
          success: true,
          updatedCount: count,
          currentVersion: newVersion,
          message: count > 0
              ? "Successfully updated $count hymns (Catalog Version $newVersion)!"
              : "Hymns verified. All hymns are up to date.",
        );
      } else {
        return SyncResult(
          success: false,
          updatedCount: 0,
          currentVersion: localVersion,
          message: "Update server responded with HTTP status ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Remote hymn sync error: $e");
      return SyncResult(
        success: false,
        updatedCount: 0,
        currentVersion: localVersion,
        message: "Unable to check for hymn updates: Network unavailable",
      );
    }
  }

  /// Returns the last sync timestamp
  Future<DateTime?> getLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(prefLastSyncTime);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
