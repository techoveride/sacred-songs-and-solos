import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/util/hymn_listing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../ads/anchored_adaptive_ad.dart';
import '../state/hymns_notifier.dart';
import '../state/reading_settings_notifier.dart';

GlobalKey<HymnDetailsState> hymnDetailKey = GlobalKey();

class HymnDetails extends StatefulWidget {
  final bool isInTabletLayout;
  final Hymns hymns;
  final double? adPadding;
  final VoidCallback? onFavoriteChanged;

  const HymnDetails({
    Key? key,
    required this.isInTabletLayout,
    required this.hymns,
    this.adPadding,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  HymnDetailsState createState() => HymnDetailsState();
}

class HymnDetailsState extends State<HymnDetails> with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  IconData favIcon = Icons.favorite_border;
  final IconData _off = Icons.favorite_border;
  final IconData _on = Icons.favorite;

  StreamSubscription<PlayerState>? _audioPlayerStateSubs;
  bool tuneIconVisibility = true;
  double? barHeight;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    favIcon = widget.hymns.favorite == 1 ? _on : _off;

    initAudioPlayer();
    _initFavoriteState();
    _loadTune();
    _applyWakeLock();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant HymnDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hymns.id != widget.hymns.id) {
      _stopAndResetPlayer();
      _initFavoriteState();
      _loadTune();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  void _stopAndResetPlayer() {
    try {
      globals.player.stop();
    } catch (e) {
      debugPrint("Error stopping player on hymn switch: $e");
    }
    globals.mp3Uri = '';
    globals.tuneIcon = globals.play;
    globals.playerState = PlayerState.stopped;
    if (mounted) {
      setState(() {});
    }
  }

  void _loadTune() {
    if (!widget.hymns.isUserComposed && widget.hymns.id > 0) {
      globals.load(
        widget.hymns.id.toString(),
        tuneSource: widget.hymns.tune,
        hymnId: widget.hymns.id,
      );
    }
  }

  Future<void> _handlePlayPressed({bool isTablet = false}) async {
    if (globals.isPlaying) {
      await pausePlayer();
      if (isTablet) {
        audioTabSnackBuilder();
      } else {
        audioSnackBuilder();
      }
    } else {
      try {
        await globals.playSound(
          onStreamingStarted: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Streaming tune & caching for offline use..."),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onOfflineNotification: (message) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
        if (mounted) {
          setState(() {
            globals.tuneIcon = globals.pause;
            globals.playerState = PlayerState.playing;
          });
          if (isTablet) {
            audioTabSnackBuilder();
          } else {
            audioSnackBuilder();
          }
        }
      } catch (e) {
        debugPrint("Play tune notice: $e");
      }
    }
  }

  Future<void> _initFavoriteState() async {
    if (widget.hymns.id <= 0) return;
    final current = await _dbHelper.getHymnById(widget.hymns.id);
    if (current != null && mounted) {
      setState(() {
        favIcon = current.favorite == 1 ? _on : _off;
      });
    }
  }

  void initAudioPlayer() {
    _audioPlayerStateSubs =
        globals.player.onPlayerStateChanged.listen((state) async {
      if (state == PlayerState.completed) {
        await globals.player.stop();
        if (mounted) {
          setState(() {
            globals.tuneIcon = globals.play;
            globals.playerState = PlayerState.completed;
          });
          widget.isInTabletLayout
              ? tabOnCompletedSnackbar()
              : onCompletedSnackbar();
        }
      }
    }, onError: (error) async {
      await stopPlayer();
      if (mounted) {
        widget.isInTabletLayout ? audioTabSnackBuilder() : audioSnackBuilder();
        debugPrint("AudioPlayer subscription error: $error");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _applyWakeLock();
    }
  }

  Future<void> _applyWakeLock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool("wakelock") == true) {
        await WakelockPlus.enable();
      }
    } catch (e) {
      debugPrint("HymnDetails wakelock notice: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayerStateSubs?.cancel();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    try {
      globals.player.stop();
      globals.tuneIcon = globals.play;
      globals.playerState = PlayerState.stopped;
    } catch (_) {}
    super.dispose();
  }

  void toggleFavorite() async {
    if (widget.hymns.id <= 0) return;
    final newFav = await _dbHelper.toggleFavorite(widget.hymns.id);
    if (mounted) {
      setState(() {
        widget.hymns.favorite = newFav;
        favIcon = newFav == 1 ? _on : _off;
      });
      widget.onFavoriteChanged?.call();
      hymnGKey.currentState?.refreshList();
      HymnsNotifier.instance.notifyHymnsChanged();

      final message = newFav == 1
          ? "Hymn ${indexOptimiser(widget.hymns.id)} added to favorites"
          : "Hymn ${indexOptimiser(widget.hymns.id)} removed from favorites";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  void hideTabTuneBar(bool hide) {
    setState(() {
      barHeight = hide ? 0.0 : 36.0;
      tuneIconVisibility = !hide;
    });
  }

  Future<void> pausePlayer() async {
    await globals.player.pause();
    setState(() {
      globals.tuneIcon = globals.play;
      globals.playerState = PlayerState.paused;
    });
  }

  Future<void> stopPlayer() async {
    await globals.player.stop();
    setState(() {
      globals.tuneIcon = globals.play;
      globals.playerState = PlayerState.stopped;
    });
  }

  void shareIntent() {
    Share.share(
      "Title: ${widget.hymns.title}\n\n${widget.hymns.lyric}\n\nShared from Sacred Songs & Solos",
      subject: widget.hymns.title,
    );
  }

  String lyricOptimiser(String lyric) {
    if (lyric.isEmpty) return lyric;
    if (lyric.trimLeft().startsWith('1')) {
      return lyric;
    } else {
      return "1\n $lyric";
    }
  }

  void audioSnackBuilder() {
    String message =
        "Tune ${globals.isPlaying ? 'Playing...' : (globals.isPaused ? 'Paused...' : 'Stopped...')}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void audioTabSnackBuilder() {
    audioSnackBuilder();
  }

  void onCompletedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Tune Completed"), duration: Duration(seconds: 1)),
    );
  }

  void tabOnCompletedSnackbar() {
    onCompletedSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    // If on tablet and no hymn selected yet (id <= 0)
    if (widget.isInTabletLayout && widget.hymns.id <= 0) {
      return Container(
        color: globals.nightMode == false ? globals.bgColor : Colors.black45,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books, size: 72, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "Select a hymn from the list to view lyrics",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final Widget lyricsBody = ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                widget.hymns.title,
                textAlign: TextAlign.center,
                style: globals.titleStyle(),
              ),
              subtitle: Text(
                widget.hymns.isUserComposed
                    ? "User Composed Hymn"
                    : "Hymn ~ ${widget.hymns.id}${widget.hymns.author != null && widget.hymns.author!.isNotEmpty ? '\n${widget.hymns.author}' : ''}",
                textAlign: TextAlign.center,
                style: globals.subheadStyle(),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              lyricOptimiser(widget.hymns.lyric),
              textAlign: TextAlign.center,
              style: globals.lyricStyle(),
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );

    return ListenableBuilder(
      listenable: ReadingSettingsNotifier.instance,
      builder: (context, _) {
        if (widget.isInTabletLayout) {
          return Scaffold(
            body: Container(
              color: globals.nightMode == false ? globals.bgColor : Colors.black45,
              child: Column(
                children: <Widget>[
                  if (!widget.hymns.isUserComposed)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: tuneIconVisibility ? 1.0 : 0.0,
                      child: SizedBox(
                        height: barHeight ?? 42.0,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2.0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(globals.tuneIcon,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                                onPressed: () async {
                                  await _handlePlayPressed(isTablet: true);
                                },
                              ),
                              IconButton(
                                icon: Icon(globals.stop,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                                onPressed: () async {
                                  await stopPlayer();
                                  audioTabSnackBuilder();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: lyricsBody),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton.small(
                  heroTag: 'favBtnTablet_${widget.hymns.id}',
                  onPressed: toggleFavorite,
                  child: Icon(favIcon,
                      color: favIcon == _on ? Colors.redAccent : null),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  heroTag: 'shareBtnTablet_${widget.hymns.id}',
                  onPressed: shareIntent,
                  child: const Icon(Icons.share),
                ),
              ],
            ),
            bottomNavigationBar: const AnchoredAdaptiveAd(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.hymns.title),
            actions: <Widget>[
              if (!widget.hymns.isUserComposed) ...[
                IconButton(
                  icon: Icon(globals.tuneIcon),
                  onPressed: () async {
                    await _handlePlayPressed(isTablet: false);
                  },
                ),
                IconButton(
                  icon: Icon(globals.stop),
                  onPressed: () async {
                    await stopPlayer();
                    audioSnackBuilder();
                  },
                ),
              ],
              IconButton(
                icon:
                    Icon(favIcon, color: favIcon == _on ? Colors.redAccent : null),
                onPressed: toggleFavorite,
              ),
            ],
          ),
          body: PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) async {
              if (globals.isPlaying) {
                await stopPlayer();
              }
            },
            child: Container(
              color: globals.nightMode == false ? globals.bgColor : Colors.black45,
              child: lyricsBody,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: shareIntent,
            child: const Icon(Icons.share),
          ),
          bottomNavigationBar: const AnchoredAdaptiveAd(),
        );
      },
    );
  }
}
