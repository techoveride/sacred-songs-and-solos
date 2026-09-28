import 'package:flutter/foundation.dart';

/// Built-in ChangeNotifier to coordinate hymn list updates across screens
/// without relying on fragile GlobalKey currentState references.
class HymnsNotifier extends ChangeNotifier {
  static final HymnsNotifier instance = HymnsNotifier._();
  HymnsNotifier._();

  int _version = 0;
  int get version => _version;

  /// Call whenever hymn data changes (favorite toggled, remote sync, added song)
  void notifyHymnsChanged() {
    _version++;
    notifyListeners();
  }
}
