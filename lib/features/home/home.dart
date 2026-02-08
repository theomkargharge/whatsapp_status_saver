import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_status_saver/core/localization/l10n/app_localizations.dart';
import 'package:whatsapp_status_saver/core/utils/widgets.dart';
import 'package:whatsapp_status_saver/features/preview/reels_preview_screen.dart';
import 'package:whatsapp_status_saver/features/save/save_screen.dart';
import 'package:whatsapp_status_saver/features/setting/settings.dart';
import 'package:whatsapp_status_saver/services/auto_refresh_service.dart';
import '../../data/models/status_media.dart';
import '../../services/status_reader_service.dart';
import '../preview/preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = true;

  // YOUR ORIGINAL FEATURES
  Map<String, VideoPlayerController> _controllers = {};
  List<StatusMedia> statuses = [];
  List<StatusMedia> visibleStatuses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    // AutoRefreshService.instance?.refreshStream.listen((_) {
    //   _refreshStatuses();
    // });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      initializeVideo(); // YOUR ORIGINAL METHOD
      _isInitialized = true;
    }
  }

  // YOUR ORIGINAL METHOD
  Future<void> initializeVideo() async {
    setState(() => _isLoading = true);

    statuses = await StatusReaderService.readStatuses();
    visibleStatuses = List.from(statuses);

    // Pre-initialize controllers for video items
    final videoList = visibleStatuses.where((s) => s.isVideo).toList();
    for (var video in videoList) {
      if (!_controllers.containsKey(video.images)) {
        try {
          VideoPlayerController controller;

          // Check if it's a content URI or file path
          if (video.images.startsWith('content://')) {
            // Content URI - use contentUri constructor
            controller = VideoPlayerController.contentUri(
              Uri.parse(video.images),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
          } else {
            // File path - use file constructor
            final file = File(video.images);
            if (await file.exists()) {
              controller = VideoPlayerController.file(
                file,
                videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
              );
            } else {
              debugPrint('Video file does not exist: ${video.images}');
              continue;
            }
          }

          await controller.initialize();
          _controllers[video.images] = controller;
          if (mounted) setState(() {});
        } catch (e) {
          debugPrint('Video init error: $e');
        }
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  // YOUR ORIGINAL METHOD
  List<StatusMedia> getFilteredStatuses(int tabIndex) {
    if (tabIndex == 0) {
      return visibleStatuses.where((e) => !e.isVideo).toList();
    }
    if (tabIndex == 1) {
      return visibleStatuses.where((e) => e.isVideo).toList();
    }
    return [];
  }

  // YOUR ORIGINAL METHOD
  void downloadMedia(StatusMedia item) {
    StatusReaderService.downloadStatus(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Status downloaded successfully!'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onMediaSelect(StatusMedia item) {
    final index = visibleStatuses.indexOf(item);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReelsPreviewScreen(statuses: visibleStatuses, initialIndex: index),
      ),
    );
  }

  void _refreshStatuses() async {
    // Dispose old controllers
    for (var controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _isInitialized = false;
    await initializeVideo();
  }

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // gray-50
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
            child: Material(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          // Logo
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.circle_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                           Text(
                            l10n.appName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          // Refresh Button
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 24),
                            color: const Color(0xFF6B7280),
                            onPressed: _refreshStatuses,
                          ),
                          // Settings Button
                          IconButton(
                            icon: const Icon(Icons.settings, size: 24),
                            color: const Color(0xFF6B7280),
                            onPressed: () {
                              // Settings logic
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, size: 24),
                            color: const Color(0xFF6B7280),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SavedScreen(),
                                ),
                              );
                            },
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _tabController.animateTo(0),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      l10n.images,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _currentIndex == 0
                                            ? const Color(0xFF0D9488)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _tabController.animateTo(1),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Text(
                                      l10n.videos,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _currentIndex == 1
                                            ? const Color(0xFF0D9488)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Animated Indicator
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            left: _currentIndex == 0
                                ? 16
                                : MediaQuery.of(context).size.width / 2,
                            right: _currentIndex == 0
                                ? MediaQuery.of(context).size.width / 2
                                : 16,
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
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Images Tab
                      getFilteredStatuses(0).isNotEmpty
                          ? _MediaGrid(
                              items: getFilteredStatuses(0),
                              onSelect: _onMediaSelect,
                              onDownload: downloadMedia,
                            )
                          :  _EmptyState(type:l10n.images),

                      // Videos Tab
                      getFilteredStatuses(1).isNotEmpty
                          ? _VideoList(
                              items: getFilteredStatuses(1),
                              controllers: _controllers,
                              onSelect: _onMediaSelect,
                              onDownload: downloadMedia,
                            )
                          :  _EmptyState(type:l10n.videos),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildImage(String path) {
  return UniversalImage(
    path: path,
    width: double.infinity,
    height: double.infinity,
    fit: BoxFit.cover,
  );
}

// MediaGrid Widget
class _MediaGrid extends StatelessWidget {
  final List<StatusMedia> items;
  final Function(StatusMedia) onSelect;
  final Function(StatusMedia) onDownload;

  const _MediaGrid({
    required this.items,
    required this.onSelect,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
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
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () => onSelect(item),
            child: Stack(
              children: [
                // Image
                _buildImage(item.images),
       
                // Download Button Overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => onDownload(item),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        size: 20,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// VideoList Widget
class _VideoList extends StatelessWidget {
  final List<StatusMedia> items;
  final Map<String, VideoPlayerController> controllers;
  final Function(StatusMedia) onSelect;
  final Function(StatusMedia) onDownload;

  const _VideoList({
    required this.items,
    required this.controllers,
    required this.onSelect,
    required this.onDownload,
  });

  String _getTimeAgo(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final modified = file.lastModifiedSync();
        final now = DateTime.now();
        final difference = now.difference(modified);

        if (difference.inMinutes < 60) {
          return '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          return '${difference.inHours}h ago';
        } else {
          return '${difference.inDays}d ago';
        }
      }
    } catch (e) {
      debugPrint('Error getting time: $e');
    }
    return 'Recent';
  }

  String _getVideoDuration(VideoPlayerController? controller) {
    if (controller?.value.isInitialized ?? false) {
      final duration = controller!.value.duration;
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:00';
  }

  @override
  Widget build(BuildContext context) {
    var   l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final controller = controllers[item.images];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => onSelect(item),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Thumbnail
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: controller?.value.isInitialized ?? false
                              ? SizedBox(
                                  width: 112,
                                  height: 112,
                                  child: VideoPlayer(controller!),
                                )
                              : Container(
                                  width: 112,
                                  height: 112,
                                  color: const Color(0xFFE5E7EB),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'New',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                ),
                                Text(
                                  _getTimeAgo(item.images),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Status Video',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getVideoDuration(controller),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ModernActionButton(
                                      icon: Icons.ios_share_rounded,
                                      label: 'Share',
                                      gradientColors: const [
                                        Color(0xFF14B8A6),
                                        Color(0xFF0D9488),
                                      ],
                                      borderColor: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.3),
                                      onPressed: () {},
                                      isPrimary: false,
                                    ),
                                    const SizedBox(width: 8),
                                    ModernActionButton(
                                      icon: Icons.download_rounded,
                                      label: 'Save',
                                      gradientColors: const [
                                        Color(0xFF14B8A6),
                                        Color(0xFF0D9488),
                                      ],
                                      borderColor: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.3),
                                      onPressed: () {},
                                      isPrimary: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// EmptyState Widget
class _EmptyState extends StatelessWidget {
  final String type;

  const _EmptyState({required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'images'
                ? Icons.image_outlined
                : Icons.video_library_outlined,
            size: 80,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type == 'images' ? 'Images' : 'Videos'} Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'View status once, then come back',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color borderColor;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ModernActionButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.borderColor,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: .2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: isPrimary
                ? DownloadIcon()
                : Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
