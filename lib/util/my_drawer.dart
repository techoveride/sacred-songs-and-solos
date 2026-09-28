import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/util/report_bug.dart';
import 'package:hymn_book/util/settings.dart';
import 'package:hymn_book/util/support_us.dart';
import 'app_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/hymn_sync_service.dart';
import 'about_us.dart';
import 'added_songs.dart';
import 'compose_song.dart';
import 'help_me.dart';
import 'hymn_listing.dart';
import '../state/hymns_notifier.dart';

class MyDrawer extends StatefulWidget {
  final bool? isTabletLayout;

  const MyDrawer({Key? key, this.isTabletLayout}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  loadRemoteConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      // Using default duration to force fetching from remote server.
      // await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.fetchAndActivate();
      String remoteVersion = remoteConfig.getString("app_version");
      String proStoreUrl = remoteConfig.getString("pro_store_url");
      String proPlayUrl = remoteConfig.getString("pro_play_url");
      String shareApp = remoteConfig.getString("share_app");
      String moreApps = remoteConfig.getString("more_apps");
      if (proStoreUrl.isNotEmpty) globals.PREMIUM_APP_STORE_URL = proStoreUrl;
      if (proPlayUrl.isNotEmpty) globals.PREMIUM_PLAY_STORE_URL = proPlayUrl;
      if (shareApp.isNotEmpty) globals.share_app = shareApp;
      if (moreApps.isNotEmpty) globals.more_apps = moreApps;
      if (remoteVersion.isNotEmpty) globals.app_update = remoteVersion;
    } catch (exception) {
      debugPrint(
          'Unable to fetch remote config. Cached or default values will be '
          'used\nException: $exception');
    }
  }

  // static const int tabletBreakpoint = 600;
  late double shortestSide;
  Orientation orientation = Orientation.portrait;

  @override
  Widget build(BuildContext context) {
    shortestSide = MediaQuery.of(context).size.shortestSide;
    orientation = MediaQuery.of(context).orientation;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  "images/main_logo.png",
                ),
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.black,
              Theme.of(context).colorScheme.secondary
            ], transform: const GradientRotation(0.0))),
            accountName: const Text(
              "Hymnestry",
            ),
            accountEmail: const Text(
              "hymnestryteam@outlook.com",
            ),
          ),
          ListTile(
              leading: ConstrainedBox(
                constraints: BoxConstraints.tight(const Size.square(34.0)),
                child: Image.asset(
                  'images/premium.png',
                  color: globals.nightMode ? Colors.white : Colors.black54,
                ),
              ),
              title: const Text(
                "Premium Upgrade(No Ads)",
              ),
              onTap: () async {
                await loadRemoteConfig();
                premiumAppUpdate();
              }),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text(
              "Compose Song",
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const ComposeSong();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_to_photos),
            title: const Text(
              "My added song(s)",
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddedSong()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text(
              "Check for Hymn Updates",
            ),
            onTap: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Checking for new hymn updates...")),
              );
              final result = await HymnSyncService().syncRemoteHymns(forceSync: true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
                if (result.updatedCount > 0) {
                  hymnGKey.currentState?.refreshList();
                  HymnsNotifier.instance.notifyHymnsChanged();
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              "Settings",
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Settings();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            trailing: Switch(
              value: globals.nightMode,
              onChanged: (val) async {
                await globals.setNightMode(val);
                setState(() {});
              },
            ),
            title: const Text(
              "Night Mode",
            ),
            onTap: () async {
              await globals.setNightMode(!globals.nightMode);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text(
              "Help",
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return HelpMe();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.live_help),
            title: const Text(
              "About",
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AboutUs();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text(
              "Share App",
            ),
            onTap: () {
              shareIntent();
            },
          ),
          const Divider(
            height: 2.0,
            thickness: 1.5,
          ),
          const ListTile(
            title: Text(
              "Communicate",
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text(
              "Support",
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return SupportUs();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.more),
            title: const Text(
              "More hymn apps",
            ),
            onTap: () async {
              _launchURL(globals.more_apps);
              //              var output = await setupRemoteConfig();
//              _launchURL("https://Hymnestry.com/apps");
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text(
              "Update App",
            ),
            onTap: () async {
              await loadRemoteConfig();
              versionUpdate();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text(
              "Report Bug",
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ReportBug();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Exit",
            ),
            onTap: () async {
              Navigator.of(context).pop();
              final shouldExit = await showExitConfirmationDialog(context);
              if (shouldExit) {
                await SystemNavigator.pop();
              }
            },
          ),
        ],
      ),
    );
  }


  _launchURL(String myUrl) async {
    Uri url = Uri.parse(myUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint("Drawer Opened");
    Future.delayed(const Duration(milliseconds: 500), () {});

    loadRemoteConfig();
//    versionCheck();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("Drawer Closed");
  }

  _showVersionDialog(context) async {
    await showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AppDialog(
        icon: Icons.system_update,
        title: "New Update Available",
        subtitle: "A newer version of the app is available. Please update for the latest hymns and fixes.",
        content: const SizedBox(height: 8),
        actions: [
          TextButton(
            child: const Text("Later"),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          FilledButton(
            child: const Text("Update Now"),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _launchURL(Platform.isIOS ? globals.PREMIUM_APP_STORE_URL : globals.PREMIUM_PLAY_STORE_URL);
            },
          ),
        ],
      ),
    );
  }

  _showVersionUpdatedDialog(context) async {
    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AppDialog(
        icon: Icons.check_circle_outline,
        title: "Up to Date!",
        subtitle: "You already have the latest version of Sacred Songs & Solos.",
        content: const SizedBox(height: 8),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          FilledButton(
            child: const Text("Rate App"),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _launchURL(Platform.isIOS ? globals.PREMIUM_APP_STORE_URL : globals.PREMIUM_PLAY_STORE_URL);
            },
          ),
        ],
      ),
    );
  }

  void updateDialog(BuildContext context) {
    showAppDialog(
      context: context,
      builder: (dialogCtx) {
        Timer(const Duration(milliseconds: 1800), () {
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
        });
        return const AppDialog(
          icon: Icons.wifi_off,
          title: "Connection Required",
          subtitle: "Internet access is required to check for app updates.",
          content: SizedBox(height: 8),
        );
      },
    );
  }

  void versionUpdate() async {
    if (globals.app_version.isEmpty || globals.app_update.isEmpty) {
      debugPrint(globals.app_version);
      debugPrint(globals.app_update);
      updateDialog(context);
    } else {
      //Get Current installed version of app
      double defaultVersion =
          double.parse(globals.app_version.trim().replaceAll(".", ""));
//      print("default :$defaultVersion");
      double newVersion =
          double.parse(globals.app_update.trim().replaceAll(".", ""));
//      print(newVersion);
      if (newVersion > defaultVersion) {
        _showVersionDialog(context);
      } else {
        _showVersionUpdatedDialog(context);
      }
    }
  }

  void premiumAppUpdate() {
    if (Platform.isAndroid) {
      _launchURL(globals.PREMIUM_PLAY_STORE_URL);
    } else if (Platform.isIOS) {
      _launchURL(globals.PREMIUM_APP_STORE_URL);
    } else {}
  }

  shareIntent() {
    String url;
    Platform.isAndroid
        ? url = globals.PLAY_STORE_URL
        : url = globals.APP_STORE_URL;
    Share.share(
        "Worship God in Awe\nInstall Sacred Songs & Solos app and enjoy the free tunes attached to each hymn.\nGet it here: \n $url");
  }
}
