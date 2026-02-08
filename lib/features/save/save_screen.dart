import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver/core/database/save_status_database.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import 'package:whatsapp_status_saver/core/utils/widgets.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  List<SavedStatus> _allSaved = [];
  List<SavedStatus> _images = [];
  List<SavedStatus> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    _loadSavedStatuses();
  }

  Future<void> _loadSavedStatuses() async {
    setState(() => _isLoading = true);

    final all = await SavedStatusDatabase.instance.getAllSaved();
    final images = await SavedStatusDatabase.instance.getSavedImages();
    final videos = await SavedStatusDatabase.instance.getSavedVideos();

    if (mounted) {
      setState(() {
        _allSaved = all;
        _images = images;
        _videos = videos;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStatus(SavedStatus status) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Status?'),
        content: const Text(
          'This will permanently delete this saved status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SavedStatusDatabase.instance.deleteWithFile(status);
      _loadSavedStatuses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Status deleted'),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Saved Statuses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadSavedStatuses,
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            _buildTab('All (${_allSaved.length})', 0),
                            _buildTab('Images (${_images.length})', 1),
                            _buildTab('Videos (${_videos.length})', 2),
                          ],
                        ),
                        // Animated Indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left: _getIndicatorLeft(),
                          right: _getIndicatorRight(),
                          bottom: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0D9488),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(_allSaved),
                      _buildGrid(_images),
                      _buildGrid(_videos),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _currentIndex == index
                  ? const Color(0xFF0D9488)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  double _getIndicatorLeft() {
    final width = MediaQuery.of(context).size.width;
    final tabWidth = (width - 32) / 3;
    return 16 + (_currentIndex * tabWidth);
  }

  double _getIndicatorRight() {
    final width = MediaQuery.of(context).size.width;
    final tabWidth = (width - 32) / 3;
    return width - 16 - ((_currentIndex + 1) * tabWidth);
  }

  Widget _buildGrid(List<SavedStatus> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved statuses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Double-tap any status to save it',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItem(item);
      },
    );
  }

  Widget _buildGridItem(SavedStatus item) {
    return GestureDetector(
      onTap: () {
        // TODO: Open in Reels preview
      },
      onLongPress: () => _deleteStatus(item),
      child: Stack(
        children: [
          // Content
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.localPath != null
                ? Image.file(
                    File(item.localPath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return UniversalImage(
                        path: item.uri,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : UniversalImage(
                    path: item.uri,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),

          // Video indicator
          if (item.isVideo)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    if (item.duration != null)
                      Text(
                        _formatDuration(item.duration!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Delete button
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _deleteStatus(item),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}