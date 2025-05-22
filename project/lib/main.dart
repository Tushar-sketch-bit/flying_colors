import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MKC UI',
      theme: ThemeData.dark(),
      // theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  void openLink() async {
    final Uri url = Uri.parse("https://github.com/Tushar-sketch-bit");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(),
        backgroundColor: Colors.blueGrey[800],
        leading: Icon(Icons.menu),
        title: Text("top bar", style: TextStyle(color: Colors.amber)),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: Icon(Icons.code), onPressed: openLink),
              IconButton(icon: Icon(Icons.login), onPressed: () {}),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text(
          "mkc Ui screen",
          style: TextStyle(fontSize: 24, fontFamily: 'arial'),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.brightness_high, "brightness 0", true),
            navItem(Icons.brightness_high, "brightness 1", false),
            SizedBox(width: 50),
            navItem(Icons.brightness_high, "brightness 2", false),
            navItem(Icons.brightness_high, "brightness 3", false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: Icon(Icons.brightness_3),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget navItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.orange : Colors.white),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
