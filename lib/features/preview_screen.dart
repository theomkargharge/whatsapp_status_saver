import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/status_media.dart';

class PreviewScreen extends StatefulWidget {
  final StatusMedia media;

  const PreviewScreen({super.key, required this.media});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.media.isVideo) {
      _controller = VideoPlayerController.file(
        File(widget.media.images),
      )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    }
  }

  @override
  void dispose() {
    if (widget.media.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: widget.media.isVideo
            ? _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator()
            : Image.file(File(widget.media.images)),
      ),
    );
  }
}
