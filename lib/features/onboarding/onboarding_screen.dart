import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver/core/utils/colors.dart';

import '../../core/permissions/storage_permission_service.dart';
import '../home/home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController? _pageController;
  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(initialPage: 0, keepPage: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: introList.length,
        itemBuilder: (context, index) {
          return introCard(
            onPressed: () async {
              _pageController?.jumpToPage(index + 1,);
              if (index == 1) {
                final granted = await StoragePermissionService.request();
                if (granted || context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              }
            },

            title: introList[index]['title'],
            subTitle: introList[index]['subTitle'],
            buttonText: introList[index]['buttonText'],
            icon: introList[index]['icon'],
          );
        },
      ),
    );
  }

  Widget introCard({
    required String title,
    required String subTitle,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          Text(
            title, //Save statuses you’ve already seen,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            subTitle, //"No screenshots. No screen recording. Just save them instantly",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(10),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
                fixedSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              /*   () async {
                  final granted = await StoragePermissionService.request();
                  if (granted || context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },*/
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> introList = [
    {
      "title": "Save statuses you’ve already seen",
      "subTitle":
          "No screenshots. No screen recording. Just save them instantly",
      "buttonText": "Continue",
      "icon": Icons.save_alt_rounded,
    },
    {
      "title": "Allow access to media",
      "subTitle":
          "We only access media already stored on your device. We never read your messages or private data.",
      "buttonText": "Allow Access",
      "icon": Icons.shield_moon,
    },
  ];
}

/*body: Center(
        child: ElevatedButton(
          child: const Text('Allow Storage Access'),
          onPressed: () async {
            final granted = await StoragePermissionService.request();
            if (granted || context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          },
        ),
      ),*/
