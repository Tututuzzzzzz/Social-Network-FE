import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdater {
  static const String githubRepo = 'Tututuzzzzzz/Social-Network-FE';
  static const String apiUrl = 'https://api.github.com/repos/$githubRepo/releases/latest';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        String latestVersion = response.data['tag_name'].toString().replaceAll('v', '');
        
        List assets = response.data['assets'];
        String? downloadUrl;
        if (assets.isNotEmpty) {
          downloadUrl = assets[0]['browser_download_url'];
        }

        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, downloadUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        int c = i < currentParts.length ? currentParts[i] : 0;
        int l = i < latestParts.length ? latestParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (_) {
      return current.compareTo(latest) < 0;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String newVersion, String? url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Có bản cập nhật mới!'),
        content: Text('Đã có phiên bản $newVersion với nhiều tính năng mới. Cập nhật ngay nhé!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (url != null) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: const Text('Tải về ngay'),
          ),
        ],
      ),
    );
  }
}
