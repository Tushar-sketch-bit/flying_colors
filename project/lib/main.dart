import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

// Create a class to manage app brightness state
class BrightnessManager extends ChangeNotifier {
  int _brightnessLevel = 2; // Default to middle brightness (0-4)

  int get brightnessLevel => _brightnessLevel;

  // Get the appropriate theme based on brightness level
  ThemeData getTheme() {
    switch (_brightnessLevel) {
      case 0: // Pure black
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            background: Colors.black,
            surface: Colors.black,
            primary: Colors.orange,
          ),
        );
      case 1: // Very dark
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey[900],
          colorScheme: ColorScheme.dark(
            background: Colors.grey[900],
            surface: const Color.fromARGB(255, 143, 142, 142),
            primary: Colors.orange,
          ),
        );
      case 2: // Medium dark (default)
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey[800],
          colorScheme: ColorScheme.dark(
            background: Colors.grey[800],
            surface: Colors.grey.shade500,
            primary: Colors.orange,
          ),
        );
      case 3: // Light
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[200],
          colorScheme: ColorScheme.light(primary: Colors.orange),
        );
      case 4: // Almost white
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.light(
            background: Colors.white,
            surface: Colors.white,
            primary: Colors.orange,
          ),
        );
      default:
        return ThemeData.dark();
    }
  }

  // Set brightness level and notify listeners
  void setBrightnessLevel(int level) {
    if (level >= 0 && level <= 4) {
      _brightnessLevel = level;
      notifyListeners();
    }
  }
}

// Create a global instance of the brightness manager
final brightnessManager = BrightnessManager();

// Flow delegate for the animated FAB menu
class FlowMenuDelegate extends FlowDelegate {
  final bool isFabMenuOpen;
  final int menuItemCount;

  FlowMenuDelegate({required this.isFabMenuOpen, required this.menuItemCount});

  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - 56;
    final yStart = size.height - 56;

    // Draw the main FAB
    context.paintChild(
      0,
      transform: Matrix4.translationValues(xStart, yStart, 0.0),
    );

    if (isFabMenuOpen) {
      for (int i = 1; i <= menuItemCount; i++) {
        // Calculate the position for each menu item
        final double angle = i * math.pi / (menuItemCount + 1);
        final double radius = 100;

        final double x = xStart - radius * math.cos(angle);
        final double y = yStart - radius * math.sin(angle);

        // Apply a scale animation
        final double scale = isFabMenuOpen ? 1.0 : 0.0;

        // Create the transform matrix
        final transform = Matrix4.translationValues(x, y, 0.0)
          ..scale(scale, scale);

        // Paint the child with the calculated transform
        context.paintChild(i, transform: transform);
      }
    }
  }

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return oldDelegate.isFabMenuOpen != isFabMenuOpen;
  }
}

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

class _HoverIconButtonState extends State<HoverIconButton>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _iconColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(
      begin: 27,
      end: 30,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.orange[500],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _iconColorAnimation = ColorTween(
      begin: Colors.white70,
      end: Colors.orange.shade100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => isHovered = false);
          _controller.reverse();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: IconButton(
            icon: Icon(widget.icon, color: _iconColorAnimation.value),
            onPressed: widget.onPressed,
            iconSize: _sizeAnimation.value,
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
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Listen to brightness changes
  @override
  void initState() {
    super.initState();
    brightnessManager.addListener(_onBrightnessChanged);
  }

  @override
  void dispose() {
    brightnessManager.removeListener(_onBrightnessChanged);
    super.dispose();
  }

  void _onBrightnessChanged() {
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI SCREEN MAIN',
      theme: brightnessManager.getTheme(),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Get appropriate icon for each brightness level
  IconData getBrightnessIcon(int level) {
    switch (level) {
      case 0:
        return Icons.brightness_1; // Darkest
      case 1:
        return Icons.brightness_2;
      case 2:
        return Icons.brightness_4;
      case 3:
        return Icons.brightness_5;
      case 4:
        return Icons.brightness_7; // Brightest
      default:
        return Icons.brightness_4;
    }
  }

  // Set brightness level
  void setBrightness(int level) {
    brightnessManager.setBrightnessLevel(level);
    setState(() {});
  }

  // Build animated floating action button with menu
  Widget _buildAnimatedFab(Color highlightColor) {
    return Flow(
      delegate: FlowMenuDelegate(
        isFabMenuOpen: _isFabMenuOpen,
        menuItemCount: 3,
      ),
      children: [
        // Main FAB that toggles the menu
        FloatingActionButton(
          backgroundColor: highlightColor,
          onPressed: () {
            setState(() {
              _isFabMenuOpen = !_isFabMenuOpen;
              if (_isFabMenuOpen) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            });
          },
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
          ),
        ),
        // FAB Menu Item 1 - Color Picker
        FloatingActionButton(
          backgroundColor: Colors.red,
          mini: true,
          onPressed: () {
            _showColorPickerDialog();
          },
          child: const Icon(Icons.color_lens),
        ),
        // FAB Menu Item 2 - Progress Demo
        FloatingActionButton(
          backgroundColor: Colors.green,
          mini: true,
          onPressed: () {
            _showProgressDemo();
          },
          child: const Icon(Icons.speed),
        ),
        // FAB Menu Item 3 - Share
        FloatingActionButton(
          backgroundColor: Colors.blue,
          mini: true,
          onPressed: () {
            _showShareOptions();
          },
          child: const Icon(Icons.share),
        ),
      ],
    );
  }

  // Show color picker dialog
  void _showColorPickerDialog() {
    final List<Color> colorOptions = [
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.deepOrange,
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Accent Color'),
            content: Container(
              width: double.maxFinite,
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: colorOptions.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorOptions[index];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorOptions[index],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }

  // Show progress demo dialog
  void _showProgressDemo() {
    _progressValue = 0.0;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              // Start progress animation
              Future.delayed(const Duration(milliseconds: 100), () {
                _animateProgress(setDialogState);
              });

              return AlertDialog(
                title: const Text('Progress Animation Demo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Loading simulation...'),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_selectedColor),
                    ),
                    const SizedBox(height: 10),
                    Text('${(_progressValue * 100).toInt()}%'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Animate progress bar
  void _animateProgress(Function setDialogState) {
    if (_progressValue < 1.0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setDialogState(() {
          _progressValue += 0.01;
        });
        _animateProgress(setDialogState);
      });
    }
  }

  // Show share options
  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share Flying Colors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareOption(Icons.message, 'Message', Colors.green),
                    _buildShareOption(Icons.email, 'Email', Colors.red),
                    _buildShareOption(Icons.facebook, 'Facebook', Colors.blue),
                    _buildShareOption(Icons.link, 'Copy Link', Colors.purple),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  // Build share option item
  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Build color circle for palette selection
  Widget _buildColorCircle(Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: isSelected ? 12 : 4,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  // State variables for interactive elements
  bool _isExpanded = false;
  double _sliderValue = 0.5;
  int _selectedCardIndex = -1;
  bool _isFabMenuOpen = false;
  double _progressValue = 0.0;
  Color _selectedColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    final currentBrightness = brightnessManager.brightnessLevel;
    final isDarkMode = currentBrightness < 3;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey[200];
    final highlightColor = Colors.orange;

    return Scaffold(
      floatingActionButton: _buildAnimatedFab(highlightColor),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(),
        backgroundColor: Colors.blueGrey[800],
        leading: const Icon(Icons.menu),
        title: const Text(
          "Flying Colors",
          style: TextStyle(color: Colors.amber),
        ),
        actions: [
          HoverIconButton(
            icon: Icons.code,
            tooltip: 'GitHub',
            onPressed: () => openLink("https://github.com/Tushar-sketch-bit"),
          ),
          HoverIconButton(
            icon: Icons.person,
            tooltip: 'LinkedIn',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.7),
                    Colors.deepOrange.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Flying Colors",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Adjust the brightness to your preference using the controls below",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Interactive slider for demonstration
                  Row(
                    children: [
                      Icon(Icons.tune, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                            });
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        "${(_sliderValue * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Color Palette Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Color Palette",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildColorCircle(
                        Colors.orange,
                        _selectedColor == Colors.orange,
                      ),
                      _buildColorCircle(
                        Colors.blue,
                        _selectedColor == Colors.blue,
                      ),
                      _buildColorCircle(
                        Colors.green,
                        _selectedColor == Colors.green,
                      ),
                      _buildColorCircle(
                        Colors.purple,
                        _selectedColor == Colors.purple,
                      ),
                      _buildColorCircle(
                        Colors.red,
                        _selectedColor == Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Animated progress indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loading Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: _sliderValue),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _selectedColor,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${(value * 100).toInt()}%",
                                style: TextStyle(
                                  color: _selectedColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Expandable section
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "About This App",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: highlightColor,
                        ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      Text(
                        "This app demonstrates various UI components and animations in Flutter. "
                        "It features a custom brightness control system with 5 different levels, "
                        "from pure black to almost white. Explore the different sections and "
                        "interact with the components to see the animations in action.",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Interactive cards
            Text(
              "Interactive Features",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Grid of interactive cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3, // Adjusted for better fit
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isSelected = _selectedCardIndex == index;

                // Define card content based on index
                final List<IconData> cardIcons = [
                  Icons.color_lens,
                  Icons.animation,
                  Icons.dashboard_customize,
                  Icons.settings,
                ];

                final List<String> cardTitles = [
                  "Theme Editor",
                  "Animations",
                  "Widgets",
                  "Settings",
                ];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform:
                        isSelected
                            ? (Matrix4.identity()..scale(1.02))
                            : Matrix4.identity(),
                    child: Card(
                      elevation: isSelected ? 8 : 2,
                      color:
                          isSelected
                              ? highlightColor.withOpacity(0.2)
                              : cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            isSelected
                                ? BorderSide(color: highlightColor, width: 2)
                                : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCardIndex = isSelected ? -1 : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                cardIcons[index],
                                size: 32,
                                color:
                                    isSelected
                                        ? highlightColor
                                        : textColor.withOpacity(0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cardTitles[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected ? highlightColor : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 56.0, // Fixed height to prevent overflow
        padding: EdgeInsets.zero, // Remove default padding
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.grey[900],
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available width for buttons
              final availableWidth = constraints.maxWidth;
              final buttonWidth =
                  (availableWidth - 50) / 4; // 50px for FAB space

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: navItem(
                      getBrightnessIcon(0),
                      "Level 0",
                      currentBrightness == 0,
                      () => setBrightness(0),
                    ),
                  ),
                  SizedBox(
                    width: buttonWidth,
                    child: navItem(
                      getBrightnessIcon(1),
                      "Level 1",
                      currentBrightness == 1,
                      () => setBrightness(1),
                    ),
                  ),
                  const SizedBox(width: 50), // Space for FAB
                  SizedBox(
                    width: buttonWidth,
                    child: navItem(
                      getBrightnessIcon(2),
                      "Level 2",
                      currentBrightness == 2,
                      () => setBrightness(2),
                    ),
                  ),
                  SizedBox(
                    width: buttonWidth,
                    child: navItem(
                      getBrightnessIcon(3),
                      "Level 3",
                      currentBrightness == 3,
                      () => setBrightness(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget navItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 70,
        ), // Limit width to prevent overflow
        padding: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 4.0,
        ), // Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.white,
              size: 20, // Smaller icon
            ),
            const SizedBox(height: 2), // Reduced spacing
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.white,
                  fontSize: 9, // Even smaller text
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
