import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver/features/home/home.dart';
import 'package:whatsapp_status_saver/services/folder_navigation_guide.dart';
import 'package:whatsapp_status_saver/services/status_reader_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  bool _isLoading = false;

  final List<_OnboardingContent> _steps = [
    _OnboardingContent(
      icon: Icons.folder_outlined,
      title: 'Storage Permission Needed',
      description:
          'To save statuses, we need access to your WhatsApp status folder. We respect your privacy and don\'t upload your data.',
      buttonText: 'Continue',
    ),
    _OnboardingContent(
      icon: Icons.touch_app_outlined,
      title: 'Select WhatsApp Folder',
      description:
          'Next, you\'ll select a folder. Please navigate to:\n\nAndroid → media → com.whatsapp → WhatsApp → Media → .Statuses\n\nDon\'t worry, we\'ll guide you!',
      buttonText: 'Open Folder Picker',
    ),
    _OnboardingContent(
      icon: Icons.check_circle_outline,
      title: 'All Set!',
      description:
          'Perfect! You\'re ready to view and download WhatsApp statuses. The permission is saved for future use.',
      buttonText: 'Get Started',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    // Check if user already granted folder access
    final hasPermission = await StatusReaderService.hasPermission();
    if (hasPermission && mounted) {
      // Skip onboarding if permission already exists
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    if (_currentStep == 1) {
      // Step 2: Actually request folder access via SAF
      setState(() => _isLoading = true);

      try {
        final success = await StatusReaderService.requestFolderAccess();

        if (success && mounted) {
          // Animate to success screen
          _controller.reset();
          _controller.forward();
          setState(() {
            _currentStep = 2;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          if (mounted) {
            _showError(
              'Please select the .Statuses folder.\n\nPath: Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showError('An error occurred. Please try again.');
        }
      }
    } else if (_currentStep == 2) {
      // Step 3: Go to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Step 1: Move to next step
      _controller.reset();
      _controller.forward();
      setState(() => _currentStep++);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444), // red-500
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Progress Indicator
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              
              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon Circle
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 192,
                          height: 192,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F7F1), // teal-50
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            content.icon,
                            size: 96,
                            color: const Color(0xFF0D9488), // teal-600
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937), // gray-800
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            content.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280), // gray-500
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Helper hint for step 2
                    if (_currentStep == 1) ...[
                      const SizedBox(height: 24),
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7), // amber-100
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFBBF24), // amber-400
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFFD97706), // amber-600
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Look for ".Statuses" folder - it may be hidden!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFD97706), // amber-600
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Main Action Button
                      _ScaleButton(
                        onPressed: _isLoading ? () {} : _handleNextStep,
                        child: SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isLoading
                                  ? const Color(0xFF9CA3AF) // gray-400
                                  : const Color(0xFF0D9488), // teal-600
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isLoading
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF0D9488)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    content.buttonText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Safe & Secure Badge / Skip Button / Help Button
                      if (_currentStep == 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Color(0xFF9CA3AF), // gray-400
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '100% Safe & Secure',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF), // gray-400
                              ),
                            ),
                          ],
                        )
                      else if (_currentStep == 1)
                        Column(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                FolderNavigationGuide.show(context);
                              },
                              icon: const Icon(
                                Icons.help_outline,
                                size: 18,
                                color: Color(0xFF0D9488),
                              ),
                              label: const Text(
                                'Need Help? See Guide',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0D9488),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Skip for now',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(
        _steps.length,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < _steps.length - 1 ? 8 : 0,
            ),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? const Color(0xFF0D9488) // teal-600
                  : const Color(0xFFE5E7EB), // gray-200
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;

  _OnboardingContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class _ScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _ScaleButton({required this.onPressed, required this.child});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}