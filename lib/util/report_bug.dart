import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ReportBug extends StatelessWidget {
  final _reportController = TextEditingController();

  late Color accentColor;

  late Color splash;

  ReportBug({super.key});

  @override
  Widget build(BuildContext context) {
    accentColor = Theme.of(context).colorScheme.secondary;
    splash = Theme.of(context).splashColor;
    ColorScheme theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Bug"),
        centerTitle: true,
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.report),
          )
        ],
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "You can always report to us any crashes or bugs you might have come accross through the usage of our app.\n\nWe would be glad to hear from you improvements also as your ideas are priceless.\n\nUse the form below to forward your reports, Thank You!",
                style: Theme.of(context).textTheme.titleLarge,
                softWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _reportController,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: "Report bug",
                    labelStyle: Theme.of(context).textTheme.titleMedium,
                    hintText:
                        "eg : App crashes when put in landscape mode on version 5.0 android",
                    enabled: true,
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1.2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8.0))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    elevation: WidgetStateProperty.all(6.0),
                    backgroundColor:
                        WidgetStateProperty.all(theme.secondaryContainer),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                    overlayColor: WidgetStateProperty.all<Color>(splash)),
                onPressed: () {
                  var report = _reportController.text;
                  sendReport(report);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Send Now !",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void sendReport(report) async {
    report ??= '';
    final Email email = Email(
      body: 'Hi Hymnestry !\n\n${report.toString()}',
      subject: 'Report Bug/Crash',
      recipients: ['hymnestryteam@outlook.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
