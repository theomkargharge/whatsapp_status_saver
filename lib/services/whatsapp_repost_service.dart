import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class WhatsAppRepostService {
  static Future<bool> repostToStatus(String filePath) async {
    try {
      // WhatsApp doesn't have a direct API for posting status
      // We can only open WhatsApp
      
      final whatsappUrl = Uri.parse('whatsapp://send');
      
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error reposting: $e');
      return false;
    }
  }
}