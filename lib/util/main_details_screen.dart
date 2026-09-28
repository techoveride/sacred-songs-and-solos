import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/util/fav_hymn_listing.dart';
import 'package:hymn_book/util/hymn_listing.dart';
import 'package:hymn_book/util/my_drawer.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ads/anchored_adaptive_ad.dart';
import '../service/hymn_sync_service.dart';
import 'app_dialog.dart';
import 'hymn_details.dart';

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String testDevice = '0D7F74813DAA8CF871287A05BE47FDE7';
const int maxFailedLoadAttempts = 3;
// const String testDevice = 'D3E0FD831CF53C8B3EA7798C1AD0128D';
final myTabbedPageKey = GlobalKey<_MasterDetailsScreenState>();

class MasterDetailsScreen extends StatefulWidget {
  const MasterDetailsScreen({super.key});

  @override
  _MasterDetailsScreenState createState() => _MasterDetailsScreenState();
}

class _MasterDetailsScreenState extends State<MasterDetailsScreen>
    with SingleTickerProviderStateMixin {
  int currentTabIndex = 0;
  bool tabFlag = true;
  late TabController tabController;
  //Google Ads setup
  // static const AdRequest request = AdRequest(
  //   nonPersonalizedAds: true,
  // );
  late Orientation _currentOrientation;

  //end Banner Ads
  // InterstitialAd? _interstitialAd;
  // int _numInterstitialLoadAttempts = 0;

  bool isTabletLayout = false;

/*  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-2165165254805026/2118092023'
            // ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('$ad loaded');
            }
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }*/
  AppUpdateInfo? _updateInfo;

  bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_mainDetailKey.currentContext != null) {
      ScaffoldMessenger.of(_mainDetailKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void initState() {
    activeSearch = false;
    tabController =
        TabController(vsync: this, length: _kTabs.length, initialIndex: 0);
    super.initState();

    checkForUpdate();
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate().then((_) {
          setState(() {
            _flexibleUpdateAvailable = true;
          });
        }).catchError((e) {
          showSnack(e.toString());
        });
        if (_flexibleUpdateAvailable) {
          InAppUpdate.completeFlexibleUpdate().then((_) {
            showSnack("Success!");
          }).catchError((e) {
            showSnack(e.toString());
          });
        }
      }
    });

    //ads Setup

    //load Interstitial Ad
    // loadInterstitial();
    tabController.addListener(() async {
      if (tabController.indexIsChanging) {
        await globals.player.stop();
      }
    });
    versionCheck();
  }

  @override
  void dispose() {
    tabController.dispose();
    // _interstitialAd?.dispose();
    super.dispose();
  }

  static const int tabletBreakpoint = 600;
  Hymns _selectedHymn = Hymns(
      id: 1,
      lyric:
          "Praise, my soul, the King of heaven ;\nTo His feet thy tribute bring ;\nRansomed, healed, restored, forgiven,\nWho like thee His praise shall sing ?\nPraise Him ! praise Him !\nPraise the everlasting King !\n \n2\n Praise Him for His grace and favour\nTo our fathers in distress ;\nPraise Him, still the same as ever,\nSlow to chide, and swift to bless :\nPraise Him ! praise Him !\nGlorious in His faithfulness !\n \n3\n Father- like He tends and spares us,\nWell our feeble frame He knows ;\nIn His hands He gently bears us,\nRescues us from all our foes :\nPraise Him ! praise Him !\nWidely as His mercy flows.\n \n4\n Angels, help us to adore Him,\nYe behold Him face to face !\nSun and moon, bow down before\nHim !Dwellers all in time and space,\nPraise Him ! praise Him !\nPraise with us the God of grace !\n",
      favorite: 0,
      tune: "",
      title: "Praise, my soul, the King of heaven");
  Hymns _favSelectedHymn = Hymns(
      id: -1,
      lyric: "Please select a hymn from the list",
      favorite: 0,
      tune: "",
      author: "",
      title: "No Hymn Selected !");
  bool activeSearch = false;
  final _searchController = TextEditingController();

  Key? searchBox;
  final _kTabs = <Tab>[
    const Tab(
      text: "All",
      icon: Icon(Icons.all_inclusive),
    ),
    const Tab(
      text: 'Favorite',
      icon: Icon(Icons.favorite),
    ),
  ];

  final GlobalKey<ScaffoldState> _mainDetailKey = GlobalKey();

/*
  Future<void> themeMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool status = preferences.getBool("nightMode");

    setState(() {
      if (status != null) globals.nightMode = status;
    });
  }
*/


  Widget _buildMobileFavLayout() {
    return FavHymnListing(
      key: favHymnGKey,
      hymnSelectedCallback: (hymnSelected) async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HymnDetails(
            isInTabletLayout: false,
            hymns: hymnSelected,
            onFavoriteChanged: () {
              favHymnGKey.currentState?.refreshList();
              hymnGKey.currentState?.refreshList();
            },
          );
        }));
      },
    );
  }

  Widget _buildTabFavLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Material(
            elevation: 4.0,
            child: FavHymnListing(
              key: favHymnGKey,
              hymnSelectedCallback: (hymn) {
                setState(() {
                  _favSelectedHymn = hymn;
                });
              },
              hymnSelected: _favSelectedHymn,
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Flexible(
          flex: 4,
          child: HymnDetails(
            isInTabletLayout: true,
            hymns: _favSelectedHymn,
            onFavoriteChanged: () {
              favHymnGKey.currentState?.refreshList();
              hymnGKey.currentState?.refreshList();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return HymnListing(
      key: hymnGKey,
      hymnSelectedCallback: (hymnSelected) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HymnDetails(
            isInTabletLayout: false,
            hymns: hymnSelected,
            onFavoriteChanged: () {
              hymnGKey.currentState?.refreshList();
              favHymnGKey.currentState?.refreshList();
            },
          );
        }));
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Material(
            elevation: 4.0,
            child: HymnListing(
              key: hymnGKey,
              hymnSelectedCallback: (hymn) {
                setState(() {
                  _selectedHymn = hymn;
                });
              },
              hymnSelected: _selectedHymn,
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Flexible(
          flex: 4,
          child: HymnDetails(
            isInTabletLayout: true,
            hymns: _selectedHymn,
            onFavoriteChanged: () {
              hymnGKey.currentState?.refreshList();
              favHymnGKey.currentState?.refreshList();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    Widget favContent;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    var orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait &&
        shortestSide < tabletBreakpoint) {
      //Mobile
      content = _buildMobileLayout();
      favContent = _buildMobileFavLayout();
      isTabletLayout = false;
    } else {
      //tablet
      content = _buildTabletLayout();
      favContent = _buildTabFavLayout();
      isTabletLayout = true;
    }
    final kTabPages = <Widget>[
      content,
      favContent,
    ];

    return DefaultTabController(
      length: 2,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (activeSearch) {
            _searchController.clear();
            if (hymnGKey.currentState != null) {
              hymnGKey.currentState!.onSearchExit(" ");
            } else if (favHymnGKey.currentState != null) {
              favHymnGKey.currentState!.onSearchExit(" ");
            }
            setState(() {
              activeSearch = false;
            });
            return;
          }
          final shouldExit = await showExitConfirmationDialog(context);
          if (shouldExit) {
            await SystemNavigator.pop();
          }
        },
        child: Scaffold(
          key: _mainDetailKey,
          appBar: _appBar(),
          body: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                TabBarView(controller: tabController, children: kTabPages),
                // const AnchoredAdaptiveAd(),
              ]),
          drawer: MyDrawer(
            isTabletLayout: isTabletLayout,
            // destroyBanner: destroyBanner,
            // buildBanner: buildBanner,
          ),
          bottomNavigationBar: const AnchoredAdaptiveAd(),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    if (activeSearch) {
      return AppBar(
        leading: const Icon(Icons.search),
        title: TextField(
          key: searchBox,
          controller: _searchController,
          autofocus: true,
          onChanged: onItemChanged,
          decoration: const InputDecoration(
              hintText: "Search Hymn",
              hintStyle: TextStyle(color: Colors.white70)),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                if (hymnGKey.currentState != null) {
                  hymnGKey.currentState!.onSearchExit(" ");
                } else if (hymnGKey.currentState == null) {
                  favHymnGKey.currentState!.onSearchExit(" ");
                }

                setState(() {
                  activeSearch = false;
                });
              })
        ],
      );
    } else {
      return AppBar(
        title: const Text("Sacred Songs & Solos"),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            isTabletLayout
                ? const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.all_inclusive),
                        ),
                        Text('All')
                      ],
                    ),
                  )
                : const Tab(
                    text: "All",
                    icon: Icon(Icons.all_inclusive),
                  ),
            isTabletLayout
                ? const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.favorite),
                        ),
                        Text('Favorite')
                      ],
                    ),
                  )
                : const Tab(
                    text: "Favorite",
                    icon: Icon(Icons.favorite),
                  )

//            Tab(
////              text: ".",
//                child: isTabletLayout
//                    ? Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.only(right: 8.0),
//                            child: const Icon(Icons.all_inclusive),
//                          ),
//                          const Text("All")
//                        ],
//                      )
//                    : Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          const Text("All"),
//                          const Icon(Icons.all_inclusive),
//                        ],
//                      )),
//            Tab(
//                child: isTabletLayout
//                    ? Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.only(right: 8.0),
//                            child: const Icon(Icons.favorite),
//                          ),
//                          const Text("Favorite")
//                        ],
//                      )
//                    : Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          const Text("Favorite"),
//                          const Icon(Icons.favorite),
//                        ],
//                      )),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.sort), onPressed: () => sortList()),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() => activeSearch = true);
            },
          )
        ],
      );
    }
  }

  void onItemChanged(String value) {
    hymnGKey.currentState != null
        ? hymnGKey.currentState!.onSearchedItem(value)
        : favHymnGKey.currentState!.onSearchedItem(value);
  }

  sortList() {
    showAppDialog(
      context: context,
      builder: (dialogCtx) => AppDialog(
        icon: Icons.sort,
        title: "Sort Hymns By",
        subtitle: "Choose catalog ordering",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppOptionCard<String>(
              value: 'number',
              groupValue: '',
              title: "Hymn Number (#)",
              subtitle: "Order hymns numerically (1, 2, 3...)",
              leading: const Icon(Icons.format_list_numbered),
              onSelected: (_) {
                hymnGKey.currentState != null
                    ? hymnGKey.currentState!.sortByNumber()
                    : favHymnGKey.currentState!.sortByNumber();
                Navigator.of(dialogCtx).pop(true);
              },
            ),
            const SizedBox(height: 6),
            AppOptionCard<String>(
              value: 'title',
              groupValue: '',
              title: "Hymn Title (A-Z)",
              subtitle: "Order hymns alphabetically",
              leading: const Icon(Icons.sort_by_alpha),
              onSelected: (_) {
                hymnGKey.currentState != null
                    ? hymnGKey.currentState!.sortByTitle()
                    : favHymnGKey.currentState!.sortByTitle();
                Navigator.of(dialogCtx).pop(true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // void loadBanner() {
  //   _bannerAd = createBannerAd();
  //   _bannerAd?.load();
  // }

  // void loadInterstitial() {
  //   _createInterstitialAd();
  //   //show interstitial timer
  //   Timer(const Duration(minutes: 6), () {
  //     _showInterstitialAd();
  //   });
  // }

  // destroyBanner() async {
  //   await _bannerAd?.dispose();
  //   _bannerAd = null;
  //   setState(() => adPadding = 0.0);
  // }

  // buildBanner() {
  //   loadBanner();
  // }

  void versionCheck() async {
    // Current installed version of app (matches pubspec.yaml version)
    const String currentVersionStr = "1.2.1";
    globals.app_version = currentVersionStr.replaceAll(".", "");
    double currentVersion = double.tryParse(globals.app_version) ?? 121.0;
    // Get Latest version info from firebase config
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.fetchAndActivate();
      String remoteVersion = remoteConfig.getString("app_version");
      String shareApp = remoteConfig.getString("share_app");
      String moreApps = remoteConfig.getString("more_apps");
      String proStoreUrl = remoteConfig.getString("pro_store_url");
      String proPlayUrl = remoteConfig.getString("pro_play_url");
      if (proStoreUrl.isNotEmpty) globals.PREMIUM_APP_STORE_URL = proStoreUrl;
      if (proPlayUrl.isNotEmpty) globals.PREMIUM_PLAY_STORE_URL = proPlayUrl;
      if (shareApp.isNotEmpty) globals.share_app = shareApp;
      if (moreApps.isNotEmpty) globals.more_apps = moreApps;
      globals.app_update = remoteVersion;

      if (remoteVersion.isNotEmpty) {
        double? newVersion =
            double.tryParse(remoteVersion.trim().replaceAll(".", ""));
        if (newVersion != null && newVersion > currentVersion) {
          _showVersionDialog();
        }
      }

      // Automatically sync latest hymn catalog if a newer version is present
      HymnSyncService().syncRemoteHymns().then((result) {
        if (result.updatedCount > 0 && mounted) {
          hymnGKey.currentState?.refreshList();
          showSnack("Updated ${result.updatedCount} hymns from the cloud!");
        }
      }).catchError((e) {
        debugPrint("Silent catalog sync check notice: $e");
      });
    } catch (exception) {
      if (kDebugMode) {
        print('Unable to fetch remote config. Cached or default values will be '
            'used\nException: $exception');
      }
    }
  }

  _showVersionDialog() async {
    await showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AppDialog(
        icon: Icons.system_update,
        title: "New Update Available",
        subtitle: "A newer version of the app is available. Please update now for the latest songs and improvements.",
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

  _launchURL(String myUrl) async {
    Uri url = Uri.parse(myUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

void setTheme(bool mode) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool("nightMode", mode);
  globals.nightMode = mode;
}
