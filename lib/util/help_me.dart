import 'package:flutter/material.dart';

class HelpMe extends StatelessWidget {
  late ColorScheme theme;
  late Color splash;
  TextStyle? subtitle1Style;
  TextStyle? headlineStyle;
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;

  late Color accentColor;

  HelpMe({super.key});

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context).colorScheme;
    splash = Theme.of(context).splashColor;
    accentColor = Theme.of(context).colorScheme.secondary;
    subtitle1Style = Theme.of(context).textTheme.titleMedium;
    headlineStyle = Theme.of(context).textTheme.displayLarge;
    titleStyle = Theme.of(context).textTheme.titleMedium;
    subtitleStyle = Theme.of(context).textTheme.titleSmall;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.help_outline),
          )
        ],
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.white,
                  border: Border.all(
                      color: splash, width: 1.2, style: BorderStyle.solid)),
              child: Center(
                child: Image.asset(
                  "images/help.png",
                  height: 140,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "This App is has two Sections which are detailed below.",
              style: subtitle1Style,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0), color: accentColor),
            child: ListTile(
                title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.list_alt_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "All",
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                ),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "This sections contains all the songs in the hymn book numbered the way they appear in the original hymn book.",
              style: subtitle1Style,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0), color: accentColor),
            child: ListTile(
              title: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.favorite_outline_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "Favourite",
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "This sections contains the songs you have added to your favourites sorted.",
              style: subtitle1Style,
            ),
          ),
          Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0), color: accentColor),
              child: ListTile(
                // leading: const Icon(Icons.view_list),
                title: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.view_list_outlined),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Drawer",
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "The Drawer contains menus or settings for your use and is represented like in the heading here with horizontal bars .When the icon is clicked the menu is displayed and you can use other functions of the app from there.",
              style: subtitle1Style,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: accentColor,
            ),
            child: ListTile(
              title: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.question_answer_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "How to add Songs to Favourites",
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "You add songs to favourites by clicking on the heart shaped icon in the top right corner of the song lyric screen.You can aswell remove an existing song from the list clicking on it again.",
              style: subtitle1Style,
            ),
          )
        ],
      ),
    );
  }
}
