import 'package:flutter/material.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../state/reading_settings_notifier.dart';
import 'app_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _fontRadioSelected = '18.0';
  String _lineRadioSelected = '1.2';
  String _bgRadioSelected = 'white';
  String _textRadioSelected = 'black';

  bool _wakeLock = false;

  late ColorScheme theme;
  late Color splash;
  late Color accentColor;

  @override
  void initState() {
    super.initState();
    initialisePrefs();
  }

  _saveBgColor(int colorVal) async {
    await ReadingSettingsNotifier.instance.setBgColor(Color(colorVal));
  }

  _saveTextColor(int colorVal) async {
    await ReadingSettingsNotifier.instance.setTxtColor(Color(colorVal));
  }

  _saveLineSpacing(double value) async {
    await ReadingSettingsNotifier.instance.setLineSpacing(value);
  }

  _saveFontSize(double value) async {
    await ReadingSettingsNotifier.instance.setFontSize(value);
  }

  _saveWakeLock(bool flag) async {
    SharedPreferences wakeLockPref = await SharedPreferences.getInstance();
    await wakeLockPref.setBool("wakelock", flag);
    try {
      if (flag) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
      debugPrint("Settings wakelock applied: $flag");
    } catch (e) {
      debugPrint("Settings wakelock error: $e");
    }
  }

  // methods for accessing stored values
  Future<int?> _loadBgColor() async {
    SharedPreferences bgColorPref = await SharedPreferences.getInstance();
    var color = bgColorPref.getInt("bgColor");
    setState(() {
      if (color != null) _bgRadioSelected = bgColorIdentifier(color);
    });
    return color;
  }

  Future<int?> _loadTxtColor() async {
    SharedPreferences txtColorPref = await SharedPreferences.getInstance();
    var color = txtColorPref.getInt("txtColor");
    setState(() {
      if (color != null) _textRadioSelected = txtColorIdentifier(color);
    });
    return color;
  }

  Future<double?> _loadFontSize() async {
    SharedPreferences fontSizePref = await SharedPreferences.getInstance();
    var size = fontSizePref.getDouble("fontSize");
    setState(() {
      if (size != null) _fontRadioSelected = size.toString();
    });
    return size;
  }

  Future<double?> _loadLineSp() async {
    SharedPreferences lineSpPref = await SharedPreferences.getInstance();
    var size = lineSpPref.getDouble("lineSp");
    setState(() {
      if (size != null) _lineRadioSelected = size.toString();
    });
    return size;
  }

  Future<bool?> _loadWakeLock() async {
    SharedPreferences wakeLockPref = await SharedPreferences.getInstance();
    var lock = wakeLockPref.getBool("wakelock") ?? false;
    setState(() {
      _wakeLock = lock;
    });
    try {
      if (lock) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (e) {
      debugPrint("Load wakelock error: $e");
    }
    return lock;
  }

  setBackground(String val) {
    setState(() {
      switch (val) {
        case 'white':
          globals.bgColor = Colors.white;
          _saveBgColor(Colors.white.toARGB32());
          break;
        case 'red':
          globals.bgColor = Colors.red;

          _saveBgColor(Colors.red.value);
          break;
        case 'blue':
          globals.bgColor = Colors.blue;

          _saveBgColor(Colors.blue.value);

          break;
        case 'green':
          globals.bgColor = Colors.green;

          _saveBgColor(Colors.green.value);

          break;
        case 'black':
          globals.bgColor = Colors.black;

          _saveBgColor(Colors.black.toARGB32());
          break;
        case 'silver':
          globals.bgColor = Colors.black12;

          _saveBgColor(Colors.black12.toARGB32());

          break;
        case 'grey':
          globals.bgColor = Colors.grey;

          _saveBgColor(Colors.grey.value);

          break;
        case 'lime':
          globals.bgColor = Colors.lime;

          _saveBgColor(Colors.lime.value);

          break;
        case 'teal':
          globals.bgColor = Colors.teal;

          _saveBgColor(Colors.teal.value);

          break;
        case 'navy':
          globals.bgColor = Colors.blueAccent;

          _saveBgColor(Colors.blueAccent.value);

          break;
        case 'indigo':
          globals.bgColor = Colors.indigo;

          _saveBgColor(Colors.indigo.value);

          break;
        default:
          globals.bgColor = Colors.lightGreenAccent;

          _saveBgColor(Colors.lightGreenAccent.value);

          break;
      }
    });
  }

  setTextColor(String val) {
    setState(() {
      switch (val) {
        case 'white':
          globals.txtColor = Colors.white;
          _saveTextColor(Colors.white.toARGB32());
          break;
        case 'red':
          globals.txtColor = Colors.red;

          _saveTextColor(Colors.red.value);
          break;
        case 'blue':
          globals.txtColor = Colors.blue;

          _saveTextColor(Colors.blue.value);

          break;
        case 'green':
          globals.txtColor = Colors.green;

          _saveTextColor(Colors.green.value);

          break;
        case 'black':
          globals.txtColor = Colors.black;

          _saveTextColor(Colors.black.toARGB32());
          break;
        case 'silver':
          globals.txtColor = Colors.black12;

          _saveTextColor(Colors.black12.toARGB32());

          break;
        case 'grey':
          globals.txtColor = Colors.grey;

          _saveTextColor(Colors.grey.value);

          break;
        case 'lime':
          globals.txtColor = Colors.lime;

          _saveTextColor(Colors.lime.value);

          break;
        case 'teal':
          globals.txtColor = Colors.teal;

          _saveTextColor(Colors.teal.value);

          break;
        case 'navy':
          globals.txtColor = Colors.blueAccent;

          _saveTextColor(Colors.blueAccent.value);

          break;
        case 'indigo':
          globals.txtColor = Colors.indigo;

          _saveTextColor(Colors.indigo.value);

          break;
        default:
          globals.txtColor = Colors.lightGreenAccent;

          _saveTextColor(Colors.lightGreenAccent.value);

          break;
      }
    });
  }

  setFontSize(String val) {
    switch (val) {
      case '16.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '18.0':
        globals.fontSize = double.parse(val);

        _saveFontSize(double.parse(val));
        break;
      case '20.0':
        globals.fontSize = double.parse(val);

        _saveFontSize(double.parse(val));
        break;
      case '22.0':
        globals.fontSize = double.parse(val);

        _saveFontSize(double.parse(val));
        break;
      case '24.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '26.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '28.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '30.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '32.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '34.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      case '36.0':
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
      default:
        globals.fontSize = double.parse(val);
        _saveFontSize(double.parse(val));
        break;
    }
  }

  setLineSpacing(String val) {
    switch (val) {
      case '1.2':
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
      case '1.5':
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
      case '2.0':
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
      case '2.2':
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
      case '2.5':
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
      default:
        globals.lineSp = double.parse(val);
        _saveLineSpacing(double.parse(val));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context).colorScheme;
    splash = Theme.of(context).splashColor;
    accentColor = Theme.of(context).colorScheme.secondary;
    fontSizeDialog() {
      final fontSizes = ['14.0', '16.0', '18.0', '20.0', '22.0', '24.0', '26.0', '28.0', '30.0'];
      showAppDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AppDialog(
                icon: Icons.format_size,
                title: "Lyrics Font Size",
                subtitle: "Select preferred size for reading hymn lyrics",
                content: SizedBox(
                  height: 320,
                  child: ListView.builder(
                    itemCount: fontSizes.length,
                    itemBuilder: (context, index) {
                      final sizeStr = fontSizes[index];
                      final sizeVal = double.parse(sizeStr);
                      return AppOptionCard<String>(
                        value: sizeStr,
                        groupValue: _fontRadioSelected,
                        title: "${sizeVal.toInt()} pt",
                        subtitle: "Praise, my soul, the King of heaven",
                        onSelected: (val) {
                          setDialogState(() => _fontRadioSelected = val);
                          setState(() => setFontSize(val));
                          Navigator.of(dialogCtx).pop();
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    lineSpaceDialog() {
      final lineSpacings = [
        {'val': '1.0', 'title': 'Compact (1.0)', 'sub': 'Tighter line spacing'},
        {'val': '1.2', 'title': 'Normal (1.2)', 'sub': 'Standard default spacing'},
        {'val': '1.5', 'title': 'Comfortable (1.5)', 'sub': 'Pleasant reading balance'},
        {'val': '1.8', 'title': 'Spacious (1.8)', 'sub': 'Extra room between lines'},
        {'val': '2.0', 'title': 'Double (2.0)', 'sub': 'Generous line distance'},
        {'val': '2.5', 'title': 'Expanded (2.5)', 'sub': 'Maximum line distance'},
      ];
      showAppDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AppDialog(
                icon: Icons.format_line_spacing,
                title: "Lyrics Line Spacing",
                subtitle: "Adjust spacing between lines of hymn stanzas",
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: lineSpacings.map((item) {
                    return AppOptionCard<String>(
                      value: item['val']!,
                      groupValue: _lineRadioSelected,
                      title: item['title']!,
                      subtitle: item['sub'],
                      onSelected: (val) {
                        setDialogState(() => _lineRadioSelected = val);
                        setState(() => setLineSpacing(val));
                        Navigator.of(dialogCtx).pop();
                      },
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    textColorDialog() {
      final textColors = [
        {'val': 'black', 'name': 'Classic Black', 'color': Colors.black},
        {'val': 'white', 'name': 'Crisp White', 'color': Colors.white},
        {'val': 'red', 'name': 'Crimson Red', 'color': Colors.red},
        {'val': 'blue', 'name': 'Sanctuary Blue', 'color': Colors.blue},
        {'val': 'green', 'name': 'Forest Green', 'color': Colors.green},
        {'val': 'silver', 'name': 'Muted Silver', 'color': Colors.grey},
      ];
      showAppDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AppDialog(
                icon: Icons.format_color_text,
                title: "Lyrics Text Color",
                subtitle: "Choose text color for reading lyrics",
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: textColors.map((item) {
                    final color = item['color'] as Color;
                    return AppOptionCard<String>(
                      value: item['val'] as String,
                      groupValue: _textRadioSelected,
                      title: item['name'] as String,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        ),
                      ),
                      onSelected: (val) {
                        setDialogState(() => _textRadioSelected = val);
                        setState(() => setTextColor(val));
                        Navigator.of(dialogCtx).pop();
                      },
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    bgColorDialog() {
      final bgColors = [
        {'val': 'white', 'name': 'Pure White', 'color': Colors.white},
        {'val': 'amber', 'name': 'Warm Amber / Parchment', 'color': Colors.amber.shade100},
        {'val': 'green', 'name': 'Soft Mint Green', 'color': Colors.green.shade100},
        {'val': 'blue', 'name': 'Gentle Sky Blue', 'color': Colors.blue.shade100},
        {'val': 'grey', 'name': 'Light Charcoal', 'color': Colors.grey.shade300},
        {'val': 'black', 'name': 'Midnight Black', 'color': Colors.black},
      ];
      showAppDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AppDialog(
                icon: Icons.format_color_fill,
                title: "Lyrics Background",
                subtitle: "Select background color for hymn reader",
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: bgColors.map((item) {
                    final color = item['color'] as Color;
                    return AppOptionCard<String>(
                      value: item['val'] as String,
                      groupValue: _bgRadioSelected,
                      title: item['name'] as String,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        ),
                      ),
                      onSelected: (val) {
                        setDialogState(() => _bgRadioSelected = val);
                        setState(() => setBackground(val));
                        Navigator.of(dialogCtx).pop();
                      },
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    themeChoiceDialog() {
      showAppDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AppDialog(
                icon: Icons.palette,
                title: "Choose App Theme",
                subtitle: "Select color atmosphere for the application",
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...globals.availableThemes.map((themeOpt) {
                        final isSelected = globals.currentThemeKey == themeOpt.key && !globals.nightMode;
                        return AppOptionCard<String>(
                          value: themeOpt.key,
                          groupValue: isSelected ? themeOpt.key : '',
                          title: themeOpt.name,
                          subtitle: themeOpt.description,
                          leading: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: themeOpt.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          onSelected: (key) async {
                            await globals.setAppTheme(key);
                            if (globals.nightMode) {
                              await globals.setNightMode(false);
                            }
                            setDialogState(() {});
                            setState(() {});
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Theme updated to ${themeOpt.name}"),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 6),
                      const Divider(),
                      AppOptionCard<bool>(
                        value: true,
                        groupValue: globals.nightMode,
                        title: "Midnight Dark",
                        subtitle: "Deep black background for night worship",
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 1.5),
                          ),
                          child: const Icon(Icons.dark_mode, color: Colors.amber, size: 16),
                        ),
                        onSelected: (_) async {
                          await globals.setNightMode(true);
                          setDialogState(() {});
                          setState(() {});
                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Theme set to Midnight Dark"),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.settings),
          )
        ],
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 16.0,
              child: const Icon(Icons.palette, color: Colors.white, size: 18),
            ),
            title: const Text(
              "App Theme",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              globals.nightMode
                  ? "Midnight Dark"
                  : globals.availableThemes
                      .firstWhere(
                        (t) => t.key == globals.currentThemeKey,
                        orElse: () => globals.availableThemes.first,
                      )
                      .name,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: globals.nightMode
                        ? Colors.black87
                        : Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: globals.nightMode
                          ? Colors.amber
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => themeChoiceDialog(),
          ),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
              title: const Text("Font Size"),
              subtitle: const Text("Change the size of the Lyrics"),
              onTap: () => fontSizeDialog()),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            title: const Text("Line Spacing"),
            subtitle:
                const Text("Change the space between lines of the Lyrics"),
            onTap: () => lineSpaceDialog(),
          ),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            title: const Text("Text Color"),
            subtitle: const Text("Change the color of the Lyrics"),
            trailing: CircleAvatar(
              backgroundColor: globals.txtColor,
              radius: 18.0,
              child: Container(),
            ),
            onTap: () => textColorDialog(),
          ),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            title: const Text("Background Color"),
            subtitle: const Text("Change the background color of the Lyrics"),
            trailing: CircleAvatar(
              backgroundColor: globals.bgColor,
              radius: 18.0,
              child: Container(),
            ),
            onTap: () => bgColorDialog(),
          ),
          const Divider(
            thickness: 2.0,
          ),
          ListTile(
            leading: Icon(
              _wakeLock
                  ? Icons.screen_lock_portrait
                  : Icons.screen_lock_portrait_outlined,
              color: _wakeLock ? Theme.of(context).primaryColor : null,
            ),
            trailing: Switch(
              value: _wakeLock,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (val) async {
                final sm = ScaffoldMessenger.of(context);
                setState(() => _wakeLock = val);
                await _saveWakeLock(_wakeLock);
                sm.showSnackBar(
                  SnackBar(
                    content: Text(
                      _wakeLock
                          ? "Keep Screen Awake is ON (Screen will not dim or sleep)"
                          : "Keep Screen Awake is OFF (Normal screen timeout)",
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            title: const Text("Keep Screen Awake",
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                "Prevent screen from turning off while reading hymns"),
          ),
          const Divider(
            thickness: 2.0,
          ),
        ],
      ),
    );
  }

  String txtColorIdentifier(int color) {
    switch (color) {
      case 4294967295:
        return _textRadioSelected = 'white';

      case 4294198070:
        return _textRadioSelected = 'red';

      case 4280391411:
        return _textRadioSelected = 'blue';

      case 4283215696:
        return _textRadioSelected = 'green';

      case 4278190080:
        return _textRadioSelected = 'black';

      case 1660944383:
        return _textRadioSelected = 'silver';

      case 4288585374:
        return _textRadioSelected = 'grey';

      case 4291681337:
        return _textRadioSelected = 'lime';

      case 4278228616:
        return _textRadioSelected = 'teal';

      case 4282682111:
        return _textRadioSelected = 'navy';

      case 4282339765:
        return _textRadioSelected = 'indigo';

      default:
        return _textRadioSelected = 'white';
    }
  }

  String bgColorIdentifier(int color) {
    switch (color) {
      case 4294967295:
        return _bgRadioSelected = 'white';

      case 4294198070:
        return _bgRadioSelected = 'red';

      case 4280391411:
        return _bgRadioSelected = 'blue';

      case 4283215696:
        return _bgRadioSelected = 'green';

      case 4278190080:
        return _bgRadioSelected = 'black';

      case 1660944383:
        return _bgRadioSelected = 'silver';

      case 4288585374:
        return _bgRadioSelected = 'grey';

      case 4291681337:
        return _bgRadioSelected = 'lime';

      case 4278228616:
        return _bgRadioSelected = 'teal';

      case 4282682111:
        return _bgRadioSelected = 'navy';

      case 4282339765:
        return _bgRadioSelected = 'indigo';

      default:
        return _bgRadioSelected = 'white';
    }
  }

  void initialisePrefs() {
    _loadWakeLock();
    _loadLineSp();
    _loadFontSize();
    _loadBgColor();
    _loadTxtColor();
  }

  Color getTextColor(String val) {
    switch (val) {
      case 'white':
        return Colors.white;

      case 'red':
        return Colors.red;

      case 'blue':
        return Colors.blue;

      case 'green':
        return Colors.green;

      case 'black':
        return Colors.black;

      case 'silver':
        return Colors.black12;

      case 'grey':
        return Colors.grey;

      case 'lime':
        return Colors.lime;

      case 'teal':
        return Colors.teal;

      case 'navy':
        return Colors.blueAccent;

      case 'indigo':
        return Colors.indigo;

      default:
        return Colors.lightGreenAccent;
    }
  }

  Color getBgColor(String val) {
    switch (val) {
      case 'white':
        return Colors.white;

      case 'red':
        return Colors.red;

      case 'blue':
        return Colors.blue;

      case 'green':
        return Colors.green;

      case 'black':
        return Colors.black;

      case 'silver':
        return Colors.black12;

      case 'grey':
        return Colors.grey;

      case 'lime':
        return Colors.lime;

      case 'teal':
        return Colors.teal;

      case 'navy':
        return Colors.blueAccent;

      case 'indigo':
        return Colors.indigo;

      default:
        return Colors.lightGreenAccent;
    }
  }
}
