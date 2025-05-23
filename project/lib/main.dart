import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const HoverIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: isHovered ? Colors.orange[500] : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: IconButton(
            icon: Icon(
              widget.icon,
              color: isHovered ? Colors.orange.shade100 : Colors.white70,
            ),
            onPressed: widget.onPressed,
            iconSize: isHovered ? 30 : 27,
          ),
        ),
      ),
    );
  }
}

//class MenuButton extends StatefulWidget {
//final IconData icon;
//final Tooltip tooltip;
//final
//}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI SCREEN MAIN',
      theme: ThemeData.dark(),
      // theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      throw 'could not launch $url';
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
          HoverIconButton(
            icon: Icons.code,
            tooltip: 'GitHub',
            onPressed: () => openLink("https://github.com/Tushar-sketch-bit"),
          ),
          HoverIconButton(
            icon: Icons.person,
            tooltip: 'Linkdin',
            onPressed:
                () => openLink(
                  "https://www.linkedin.com/in/tushar-malik-0b331b346/",
                ),
          ),
          HoverIconButton(
            icon: Icons.camera_alt,
            tooltip: 'Instagram',
            onPressed:
                () => openLink("https://www.instagram.com/tushar_malik_99"),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "UI SCREEN MAIN",
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
            navItem(Icons.brightness_high, "brightness 0", false),
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
