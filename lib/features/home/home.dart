import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_status_saver/core/utils/colors.dart';
import '../../core/permissions/storage_permission_service.dart';
import '../../data/models/status_media.dart';
import '../../services/status_reader_service.dart';
import '../../services/status_saver_service.dart';
import '../preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<StatusMedia> statuses = <StatusMedia>[];
  void initializeVideo() async {
    setState(() {
      statuses = StatusReaderService.readStatuses();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("status ${statuses.first.isVideo}");
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Status Saver', style: TextStyle(fontSize: 20)),
        ),
        body: Column(
          spacing: 10,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: List.generate(3, (index) {
                  return statuses.isEmpty
                      ? const Center(
                          child: Text('View status once, then come back'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: statuses.length,
                          itemBuilder: (_, i) {
                            if (currentIndex == 1 &&
                                statuses[i].isVideo == true) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PreviewScreen(media: statuses[i]),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(color: Colors.black12),
                                    const Icon(
                                      Icons.play_circle_fill,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              );
                            }
                            {
                              return statuses[i].isVideo
                                  ? SizedBox.shrink()
                                  : Image.file(
                                      File(statuses[i].images),
                                      fit: BoxFit.cover,
                                    );
                            }
                            return null;
                          },
                        );
                }),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 30, left: 10, right: 10),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightBorder),
                borderRadius: BorderRadiusGeometry.circular(20),
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              child: TabBar(
                padding: EdgeInsets.symmetric(horizontal: 10),
                indicatorPadding: EdgeInsets.symmetric(horizontal: -10),
                splashFactory: NoSplash.splashFactory,
                dividerColor: Colors.white,
                indicator: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadiusGeometry.circular(20),
                  color: Colors.white,
                ),
                indicatorAnimation: TabIndicatorAnimation.linear,
                indicatorWeight: 0,
                mouseCursor: MouseCursor.defer,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.deepPurple,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                automaticIndicatorColorAdjustment: true,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.image, size: 28),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.video_camera_back, size: 28),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.favorite, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
