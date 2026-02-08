import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Widget that can display images from both file paths and content URIs
class UniversalImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const UniversalImage({
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  static const platform = MethodChannel('com.example.statussaver/storage');

  @override
  Widget build(BuildContext context) {
    // Check if it's a content URI
    if (path.startsWith('content://')) {
      return FutureBuilder<Uint8List?>(
        future: _loadBytesFromUri(path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              color: const Color(0xFFE5E7EB),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0D9488),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Container(
              width: width,
              height: height,
              color: const Color(0xFFE5E7EB),
              child: const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            );
          }

          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Color(0xFF9CA3AF),
                ),
              );
            },
          );
        },
      );
    } else {
      // Regular file path
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFE5E7EB),
            child: const Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
          );
        },
      );
    }
  }

  Future<Uint8List?> _loadBytesFromUri(String uri) async {
    try {
      final bytes = await platform.invokeMethod<Uint8List>(
        'getBytesFromUri',
        {'uri': uri},
      );
      return bytes;
    } catch (e) {
      debugPrint('Error loading bytes from URI: $e');
      return null;
    }
  }
}