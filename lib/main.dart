import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

void main() {
  // Register the view type for HtmlElementView.
  ui.platformViewRegistry.registerViewFactory(
    'image-view',
    (int viewId) {
      final container = html.DivElement();
      container.id = 'image-view-$viewId';
      return container;
    },
  );

  runApp(const MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Display Demo',
      home: const HomePage(),
    );
  }
}

/// Home page where users can input an image URL and display it.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String? imageUrl;

  // Track fullscreen state.
  bool _isFullscreen = false;
  bool _isContextMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL to Image Display')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  GestureDetector(
                    onDoubleTap: _toggleFullscreen,
                    child: Container(
                      width: double.infinity,
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: HtmlElementView(
                        viewType: 'image-view',
                        onPlatformViewCreated: (int viewId) {
                          _updateImageView(viewId);
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _loadImage,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isContextMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isContextMenuOpen = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: AlertDialog(
                    title: const Text('Context Menu'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _enterFullscreen,
                          child: const Text('Enter Fullscreen'),
                        ),
                        TextButton(
                          onPressed: _exitFullscreen,
                          child: const Text('Exit Fullscreen'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showContextMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Loads the image from the provided URL and updates the view.
  void _loadImage() {
    setState(() {
      imageUrl = _controller.text;
    });

    // Ensure the image reloads properly.
    Future.delayed(const Duration(milliseconds: 50), () {
      final container = html.document.getElementById('image-view-0');
      if (container != null) {
        container.children.clear();
        final imageElement = html.ImageElement()
          ..src = imageUrl!
          ..style.borderRadius = '12px'
          ..style.objectFit = 'contain'
          ..style.width = '100%'
          ..style.height = '100%';
        container.append(imageElement);
      }
    });
  }

  /// Updates the HTML element for the image view.
  void _updateImageView(int viewId) {
    final container = html.document.getElementById('image-view-\$viewId');
    if (container != null) {
      container.children.clear();
      final imageElement = html.ImageElement()
        ..src = imageUrl!
        ..style.borderRadius = '12px'
        ..style.objectFit = 'cover'
        ..style.width = '100%'
        ..style.height = '100%';
      container.append(imageElement);
    }
  }

  /// Toggles fullscreen mode for the image.
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      _enterFullscreen();
    } else {
      _exitFullscreen();
    }
  }

  /// Displays the context menu.
  void _showContextMenu() {
    setState(() {
      _isContextMenuOpen = true;
    });
  }

  /// Enters fullscreen mode.
  void _enterFullscreen() {
    html.document.documentElement?.requestFullscreen();
  }

  /// Exits fullscreen mode.
  void _exitFullscreen() {
    html.document.exitFullscreen();
  }
}
