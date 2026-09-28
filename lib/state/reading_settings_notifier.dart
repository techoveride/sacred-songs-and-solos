import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/globals.dart' as globals;

/// Built-in ChangeNotifier for reactive reading settings (font size, spacing, colors).
/// Provides automatic UI rebuilds whenever reading preferences change,
/// while synchronizing with SharedPreferences and legacy globals.
class ReadingSettingsNotifier extends ChangeNotifier {
  static final ReadingSettingsNotifier instance = ReadingSettingsNotifier._();
  ReadingSettingsNotifier._();

  double _fontSize = 18.0;
  double _lineSp = 1.2;
  Color _bgColor = Colors.white;
  Color _txtColor = Colors.black;

  double get fontSize => _fontSize;
  double get lineSp => _lineSp;
  Color get bgColor => _bgColor;
  Color get txtColor => _txtColor;

  /// Loads persisted settings from SharedPreferences
  Future<void> init(SharedPreferences prefs) async {
    final sizeFont = prefs.getDouble("fontSize");
    _fontSize = sizeFont ?? 18.0;
    globals.fontSize = _fontSize;

    final sizeLineSp = prefs.getDouble("lineSp");
    _lineSp = sizeLineSp ?? 1.2;
    globals.lineSp = _lineSp;

    final colorBg = prefs.getInt("bgColor");
    _bgColor = colorBg != null ? Color(colorBg) : Colors.white;
    globals.bgColor = _bgColor;

    final colorText = prefs.getInt("txtColor");
    _txtColor = colorText != null ? Color(colorText) : Colors.black;
    globals.txtColor = _txtColor;

    notifyListeners();
  }

  /// Updates font size, persists to SharedPreferences, and notifies listeners
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    globals.fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSize", size);
  }

  /// Updates line spacing, persists to SharedPreferences, and notifies listeners
  Future<void> setLineSpacing(double spacing) async {
    _lineSp = spacing;
    globals.lineSp = spacing;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("lineSp", spacing);
  }

  /// Updates background color, persists to SharedPreferences, and notifies listeners
  Future<void> setBgColor(Color color) async {
    _bgColor = color;
    globals.bgColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("bgColor", color.toARGB32());
  }

  /// Updates text color, persists to SharedPreferences, and notifies listeners
  Future<void> setTxtColor(Color color) async {
    _txtColor = color;
    globals.txtColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("txtColor", color.toARGB32());
  }

  TextStyle get lyricStyle => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _fontSize,
        height: _lineSp,
        color: globals.nightMode == false ? _txtColor : Colors.white,
      );

  TextStyle get titleStyle => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 30.0,
        color: globals.nightMode == false ? _txtColor : Colors.white,
      );

  TextStyle get subheadStyle => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        color: globals.nightMode == false ? _txtColor : Colors.white,
      );
}
