import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hymn_book/model/webview.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportUs extends StatelessWidget {
  // Color accentColor;

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Us",
            style: TextStyle(fontFamily: 'sans serif')),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.people_outline),
          )
        ],
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: theme.secondaryContainer),
                  height: 46,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.accessibility),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Vision,Mission and Purpose",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Enjoy worshipping our Almighty God with hymns and songs of praise!\n\nWe believe there is more to music than its perceived and we affirm music is spiritual by nature. We desire that more people develop love for the hymns and acknowledge the great impact they can have in their lives and let them rejoice in the content and beauty of the hymns. We believe active participation in congregational hymn singing is an essential part of personal worship. We believe time spent in the home learning and singing the hymns will reap eternal blessings for the family. We testify of the extraordinary joy that comes when the hymns are sung with heart-felt praises unto the Lord",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: theme.secondaryContainer),
                  height: 46,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.wifi_tethering),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Our Request",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "We believe users can provide us with the melody (midi files, tunes) of each lyric so that we can incorporate them in the apps (especially Sacred Songs and Solos App) to make it easy for people to learn almost every hymn in the app easily. We look forward to hearing from you. \nIn addition, if you desire that a particular hymn app be developed for your church, institution or organization, feel free to contact us and we will discuss about it.Hymnestry, a non-profit organization, is supported through advertising which just reduces a little portion of the running cost of the hymnarian.com and the Hymnestry Apps available for the mobile devices. However, if you are glad with the work Hymnestry App Team do offer for free and you want to support us, you can reach us via any channel below :",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: Image.asset('images/email.png'),
                title: const Text("Email Us !"),
                onTap: () {
                  _emailIntent();
                },
              ),
              ListTile(
                leading: Image.asset("images/linkedin.png"),
                title: const Text("LinkedIn"),
                onTap: () => _launchURL(
                    "https://www.linkedin.com/in/yakubu-buba-techoveride"),
              ),
              ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
//                  shape: BoxShape.circle,
                      image: const DecorationImage(
                          image: AssetImage("images/paypal.png")),
                      border: Border.all(
                        width: 3.0,
                        style: BorderStyle.solid,
                        color: Colors.blue,
                      )),
                  child: Container(
                    width: 46.0,
                  ),
                ),
                title: const Text("Donate with PayPal !"),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentWebView(
                        url: payPalGateWay,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
//                  shape: BoxShape.circle,
                        image: const DecorationImage(
                            image: AssetImage("images/flutter.jpg")),
                        border: Border.all(
                          width: 3.0,
                          style: BorderStyle.solid,
                          color: Colors.blue,
                        )),
                    child: Container(
                      width: 46.0,
                    ),
                  ),
                  title: const Text("Donate Now !"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentWebView(
                          url: flutterWaveGateWay,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  final flutterWaveGateWay = "https://flutterwave.com/pay/yakubububamagc";
  final payPalGateWay = "https://www.paypal.com/myaccount/transfer/homepage";
  final Email email = Email(
    body: 'Hi Hymnestry !\n\n',
    subject: 'Contact Hymnestry',
    recipients: ['hymnestryteam@outlook.com'],
    isHTML: false,
  );

  SupportUs({super.key});

  _emailIntent() async {
    await FlutterEmailSender.send(email);
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
