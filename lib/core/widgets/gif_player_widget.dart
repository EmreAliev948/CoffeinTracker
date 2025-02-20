import 'package:flutter/material.dart';

class GifPlayerWidget extends StatefulWidget {
  final String gifAssetPath;

  const GifPlayerWidget({
    Key? key,
    required this.gifAssetPath,
  }) : super(key: key);

  @override
  State<GifPlayerWidget> createState() => _GifPlayerWidgetState();
}

class _GifPlayerWidgetState extends State<GifPlayerWidget> {
  bool _hasError = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.gifAssetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 30),
                const SizedBox(height: 8),
                Text(
                  'Error loading GIF',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null
              ? child
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
