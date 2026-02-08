import 'package:flutter/material.dart';

/// Helper dialog to guide users through folder selection
class FolderNavigationGuide extends StatelessWidget {
  const FolderNavigationGuide({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const FolderNavigationGuide(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF0D9488),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Navigation Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Folder Path Visual
            _buildFolderPath(),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Important Tips',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('The .Statuses folder may be hidden'),
                  _buildTip('Scroll down to find it'),
                  _buildTip('Make sure WhatsApp is installed'),
                  _buildTip('View some statuses in WhatsApp first'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Got it button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderPath() {
    final folders = [
      {'name': 'Android', 'icon': Icons.android},
      {'name': 'media', 'icon': Icons.folder},
      {'name': 'com.whatsapp', 'icon': Icons.chat_bubble},
      {'name': 'WhatsApp', 'icon': Icons.chat},
      {'name': 'Media', 'icon': Icons.perm_media},
      {'name': '.Statuses', 'icon': Icons.radio_button_checked},
    ];

    return Column(
      children: List.generate(folders.length, (index) {
        final folder = folders[index];
        final isLast = index == folders.length - 1;

        return Column(
          children: [
            Row(
              children: [
                // Folder Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLast
                        ? const Color(0xFF0D9488).withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    folder['icon'] as IconData,
                    size: 20,
                    color: isLast
                        ? const Color(0xFF0D9488)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                // Folder Name
                Expanded(
                  child: Text(
                    folder['name'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                      color: isLast
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                // Target Badge
                if (isLast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SELECT THIS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            // Arrow
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 18),
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFD97706),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}