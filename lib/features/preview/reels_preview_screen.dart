// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:whatsapp_status_saver/core/database/save_status_database.dart';
// import 'package:whatsapp_status_saver/core/utils/widgets.dart';
// import '../../data/models/status_media.dart';
// import '../../services/status_reader_service.dart';
// import 'package:share_plus/share_plus.dart';

// /// Instagram Reels-style vertical scrolling preview
// class ReelsPreviewScreen extends StatefulWidget {
//   final List<StatusMedia> statuses;
//   final int initialIndex;

//   const ReelsPreviewScreen({
//     super.key,
//     required this.statuses,
//     this.initialIndex = 0,
//   });

//   @override
//   State<ReelsPreviewScreen> createState() => _ReelsPreviewScreenState();
// }

// class _ReelsPreviewScreenState extends State<ReelsPreviewScreen> {
//   late PageController _pageController;
//   int _currentIndex = 0;
//   Map<int, VideoPlayerController> _videoControllers = {};
//   Map<String, bool> _savedStatuses = {};

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//     _loadSavedStatuses();
//     _initializeCurrentVideo();
//   }

//   Future<void> _loadSavedStatuses() async {
//     for (var status in widget.statuses) {
//       final isSaved = await SavedStatusDatabase.instance.isSaved(status.images);
//       if (mounted) {
//         setState(() {
//           _savedStatuses[status.images] = isSaved;
//         });
//       }
//     }
//   }

//   Future<void> _initializeCurrentVideo() async {
//     final current = widget.statuses[_currentIndex];
//     if (current.isVideo && !_videoControllers.containsKey(_currentIndex)) {
//       await _loadVideo(_currentIndex);
//     }
//   }

//   Future<void> _loadVideo(int index) async {
//     if (_videoControllers.containsKey(index)) return;

//     final status = widget.statuses[index];
//     if (!status.isVideo) return;

//     try {
//       VideoPlayerController controller;

//       if (status.images.startsWith('content://')) {
//         controller = VideoPlayerController.contentUri(Uri.parse(status.images));
//       } else {
//         controller = VideoPlayerController.file(File(status.images));
//       }

//       await controller.initialize();
//       controller.setLooping(true);

//       if (mounted) {
//         setState(() {
//           _videoControllers[index] = controller;
//         });

//         if (index == _currentIndex) {
//           controller.play();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading video: $e');
//     }
//   }

//   void _onPageChanged(int index) {
//     // Pause previous video
//     if (_videoControllers.containsKey(_currentIndex)) {
//       _videoControllers[_currentIndex]?.pause();
//     }

//     setState(() {
//       _currentIndex = index;
//     });

//     // Play current video
//     if (_videoControllers.containsKey(index)) {
//       _videoControllers[index]?.play();
//     } else {
//       _loadVideo(index);
//     }

//     // Preload next video
//     if (index + 1 < widget.statuses.length) {
//       _loadVideo(index + 1);
//     }
//   }

//   Future<void> _toggleSave() async {
//     final current = widget.statuses[_currentIndex];
//     final isSaved = _savedStatuses[current.images] ?? false;

//     if (isSaved) {
//       // Already saved - remove from favorites
//       _showSnackBar('Removed from favorites', Icons.heart_broken);
//       setState(() {
//         _savedStatuses[current.images] = false;
//       });
//       // TODO: Remove from database
//     } else {
//       // Save to favorites
//       await _saveStatus(current);
//       setState(() {
//         _savedStatuses[current.images] = true;
//       });
//       _showSnackBar('Saved to favorites!', Icons.favorite);
//     }
//   }

//   Future<void> _saveStatus(StatusMedia status) async {
//     try {
//       // Download the file first
//       final success = await StatusReaderService.downloadStatus(status);

//       if (success) {
//         // Save to database
//         final savedStatus = SavedStatus(
//           uri: status.images,
//           fileName:
//               status.name ?? 'status_${DateTime.now().millisecondsSinceEpoch}',
//           isVideo: status.isVideo,
//           savedAt: DateTime.now().millisecondsSinceEpoch,
//           size: status.size,
//         );

//         await SavedStatusDatabase.instance.create(savedStatus);
//       }
//     } catch (e) {
//       debugPrint('Error saving status: $e');
//     }
//   }

//   Future<void> _shareStatus() async {
//     final current = widget.statuses[_currentIndex];

//     try {
//       if (current.images.startsWith('content://')) {
//         // For content URIs, we need to download first
//         await StatusReaderService.downloadStatus(current);
//         _showSnackBar(
//           'Status downloaded. Check your gallery to share.',
//           Icons.share,
//         );
//       } else {
//         // For file paths, share directly
//         await SharePlus.instance.share(
//           ShareParams(files: [XFile(current.images)]),
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Failed to share', Icons.error);
//       debugPrint('Share error: $e');
//     }
//   }

//   void _showSnackBar(String message, IconData icon) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF0D9488),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     for (var controller in _videoControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Vertical scrolling content
//           PageView.builder(
//             controller: _pageController,
//             scrollDirection: Axis.vertical,
//             onPageChanged: _onPageChanged,
//             itemCount: widget.statuses.length,
//             itemBuilder: (context, index) {
//               return _buildStatusPage(widget.statuses[index], index);
//             },
//           ),

//           // Top bar
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '${_currentIndex + 1}/${widget.statuses.length}',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusPage(StatusMedia status, int index) {
//     return GestureDetector(
//       onDoubleTap: _toggleSave,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Content (Image or Video)
//           Center(
//             child: status.isVideo
//                 ? _buildVideoPlayer(index)
//                 : UniversalImage(path: status.images, fit: BoxFit.contain),
//           ),

//           // Double-tap heart animation
//           if (_savedStatuses[status.images] == true)
//             Center(
//               child: TweenAnimationBuilder<double>(
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 duration: const Duration(milliseconds: 500),
//                 builder: (context, value, child) {
//                   return Transform.scale(
//                     scale: value,
//                     child: Opacity(
//                       opacity: 1.0 - value,
//                       child: const Icon(
//                         Icons.favorite,
//                         color: Colors.white,
//                         size: 100,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//           // Right side actions
//           Positioned(
//             right: 12,
//             bottom: 100,
//             child: Column(
//               children: [
//                 _buildActionButton(
//                   icon: _savedStatuses[status.images] == true
//                       ? Icons.favorite
//                       : Icons.favorite_border,
//                   onTap: _toggleSave,
//                   color: _savedStatuses[status.images] == true
//                       ? Colors.red
//                       : Colors.white,
//                 ),
//                 const SizedBox(height: 20),
//                 _buildActionButton(
//                   icon: Icons.download_rounded,
//                   onTap: () async {
//                     await StatusReaderService.downloadStatus(status);
//                     _showSnackBar('Downloaded!', Icons.check_circle);
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 _buildActionButton(
//                   icon: Icons.share_rounded,
//                   onTap: _shareStatus,
//                 ),
//                 const SizedBox(height: 20),
//                 _buildActionButton(
//                   icon: Icons.repeat_rounded,
//                   onTap: () {
//                     // TODO: Repost to WhatsApp
//                     _showSnackBar('Repost feature coming soon!', Icons.info);
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Bottom info
//           Positioned(
//             left: 12,
//             bottom: 100,
//             right: 80,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (status.name != null)
//                   Text(
//                     status.name!,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _getTimeAgo(status.lastModified),
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoPlayer(int index) {
//     final controller = _videoControllers[index];

//     if (controller == null || !controller.value.isInitialized) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     }

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (controller.value.isPlaying) {
//             controller.pause();
//           } else {
//             controller.play();
//           }
//         });
//       },
//       child: AspectRatio(
//         aspectRatio: controller.value.aspectRatio,
//         child: VideoPlayer(controller),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color color = Colors.white,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.5),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 28),
//       ),
//     );
//   }

//   String _getTimeAgo(int? timestamp) {
//     if (timestamp == null) return 'Recent';

//     final now = DateTime.now();
//     final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final difference = now.difference(date);

//     if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return '${difference.inDays}d ago';
//     }
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_status_saver/core/database/save_status_database.dart';
import 'package:whatsapp_status_saver/core/utils/widgets.dart';
import '../../data/models/status_media.dart';
import '../../services/status_reader_service.dart';
import 'package:share_plus/share_plus.dart';

/// Instagram Reels-style vertical scrolling preview
class ReelsPreviewScreen extends StatefulWidget {
  final List<StatusMedia> statuses;
  final int initialIndex;

  const ReelsPreviewScreen({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<ReelsPreviewScreen> createState() => _ReelsPreviewScreenState();
}

class _ReelsPreviewScreenState extends State<ReelsPreviewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<String, bool> _savedStatuses = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadSavedStatuses();
    _initializeCurrentVideo();
  }

  Future<void> _loadSavedStatuses() async {
    for (var status in widget.statuses) {
      final isSaved = await SavedStatusDatabase.instance.isSaved(status.images);
      if (mounted) {
        setState(() {
          _savedStatuses[status.images] = isSaved;
        });
      }
    }
  }

  Future<void> _initializeCurrentVideo() async {
    final current = widget.statuses[_currentIndex];
    if (current.isVideo && !_videoControllers.containsKey(_currentIndex)) {
      await _loadVideo(_currentIndex);
    }
  }

  Future<void> _loadVideo(int index) async {
    if (_videoControllers.containsKey(index)) return;

    final status = widget.statuses[index];
    if (!status.isVideo) return;

    try {
      VideoPlayerController controller;

      if (status.images.startsWith('content://')) {
        controller = VideoPlayerController.contentUri(Uri.parse(status.images));
      } else {
        controller = VideoPlayerController.file(File(status.images));
      }

      await controller.initialize();
      controller.setLooping(true);

      if (mounted) {
        setState(() {
          _videoControllers[index] = controller;
        });

        if (index == _currentIndex) {
          controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
    }
  }

  void _onPageChanged(int index) {
    // Pause previous video
    if (_videoControllers.containsKey(_currentIndex)) {
      _videoControllers[_currentIndex]?.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    // Play current video
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]?.play();
    } else {
      _loadVideo(index);
    }

    // Preload next video
    if (index + 1 < widget.statuses.length) {
      _loadVideo(index + 1);
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaving) return; // Prevent multiple saves
    
    final current = widget.statuses[_currentIndex];
    final isSaved = _savedStatuses[current.images] ?? false;

    if (isSaved) {
      // Already saved - show message
      _showSnackBar('Already in favorites!', Icons.favorite, Colors.amber);
    } else {
      // Save to favorites
      setState(() => _isSaving = true);
      
      final success = await _saveStatus(current);
      
      setState(() => _isSaving = false);
      
      if (success) {
        setState(() {
          _savedStatuses[current.images] = true;
        });
        _showSnackBar('Saved to favorites!', Icons.favorite, const Color(0xFF0D9488));
        
        // Show heart animation
        _showHeartAnimation();
      } else {
        _showSnackBar('Failed to save', Icons.error, Colors.red);
      }
    }
  }

  void _showHeartAnimation() {
    // This will trigger the TweenAnimationBuilder in build method
    setState(() {});
  }

  Future<bool> _saveStatus(StatusMedia status) async {
    try {
      print('Saving status: ${status.images}');
      
      // Download the file and get local path
      final localPath = await StatusReaderService.downloadAndGetPath(status);
      
      if (localPath == null) {
        print('Failed to download file');
        return false;
      }
      
      print('Downloaded to: $localPath');
      
      // Save to database
      final savedStatus = SavedStatus(
        uri: status.images,
        fileName: status.name ?? 'status_${DateTime.now().millisecondsSinceEpoch}',
        isVideo: status.isVideo,
        savedAt: DateTime.now().millisecondsSinceEpoch,
        localPath: localPath,
        size: status.size,
      );

      await SavedStatusDatabase.instance.create(savedStatus);
      print('Saved to database successfully');
      
      return true;
    } catch (e) {
      print('Error saving status: $e');
      return false;
    }
  }

  Future<void> _downloadStatus() async {
    final current = widget.statuses[_currentIndex];
    
    setState(() => _isSaving = true);
    final success = await StatusReaderService.downloadStatus(current);
    setState(() => _isSaving = false);
    
    if (success) {
      _showSnackBar('Downloaded to gallery!', Icons.check_circle, const Color(0xFF0D9488));
    } else {
      _showSnackBar('Download failed', Icons.error, Colors.red);
    }
  }

  Future<void> _shareStatus() async {
    final current = widget.statuses[_currentIndex];
    
    try {
      if (current.images.startsWith('content://')) {
        // For content URIs, download first then share from gallery
        _showSnackBar('Downloading to share...', Icons.share, const Color(0xFF0D9488));
        
        final success = await StatusReaderService.downloadStatus(current);
        if (success) {
          _showSnackBar('Downloaded! Check gallery to share.', Icons.share, const Color(0xFF0D9488));
        }
      } else {
        // For file paths, share directly
        await Share.shareXFiles([XFile(current.images)]);
      }
    } catch (e) {
      _showSnackBar('Failed to share', Icons.error, Colors.red);
      debugPrint('Share error: $e');
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical scrolling content
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.statuses.length,
            itemBuilder: (context, index) {
              return _buildStatusPage(widget.statuses[index], index);
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.statuses.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator when saving
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0D9488),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPage(StatusMedia status, int index) {
    final isSaved = _savedStatuses[status.images] ?? false;
    
    return GestureDetector(
      onDoubleTap: _toggleSave,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Content (Image or Video)
          Center(
            child: status.isVideo
                ? _buildVideoPlayer(index)
                : UniversalImage(path: status.images, fit: BoxFit.contain),
          ),

          // Double-tap heart animation (only show when just saved)
          if (isSaved)
            Center(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('heart_${status.images}_${DateTime.now().millisecondsSinceEpoch}'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  if (value == 1.0) return const SizedBox.shrink();
                  
                  return Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: Opacity(
                      opacity: 1.0 - value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 120,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Right side actions
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                _buildActionButton(
                  icon: isSaved ? Icons.favorite : Icons.favorite_border,
                  label: isSaved ? 'Saved' : 'Save',
                  onTap: _toggleSave,
                  color: isSaved ? Colors.red : Colors.white,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  onTap: _downloadStatus,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: _shareStatus,
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.repeat_rounded,
                  label: 'Repost',
                  onTap: () {
                    _showSnackBar('Download and post from gallery', Icons.info, Colors.blue);
                  },
                ),
              ],
            ),
          ),

          // Bottom info
          Positioned(
            left: 12,
            bottom: 100,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.name != null)
                  Text(
                    status.name!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(status.lastModified),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Double-tap to save ❤️',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(int index) {
    final controller = _videoControllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          if (!controller.value.isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(int? timestamp) {
    if (timestamp == null) return 'Recent';

    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}