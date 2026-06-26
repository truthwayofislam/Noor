import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TelegramReportService {
  // Get bot token from environment or backend
  static const String _botToken = String.fromEnvironment('TELEGRAM_BOT_TOKEN', defaultValue: '');
  static const String _chatId = String.fromEnvironment('TELEGRAM_CHAT_ID', defaultValue: '');
  
  // Fallback: fetch from backend
  static Future<Map<String, String>> _getBotCredentials() async {
    if (_botToken.isNotEmpty && _chatId.isNotEmpty) {
      return {'token': _botToken, 'chat_id': _chatId};
    }
    
    // Fetch from backend API
    try {
      final response = await http.get(
        Uri.parse('https://noormanual.jo3.org/telegram-config'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'token': data['bot_token'] ?? '',
          'chat_id': data['chat_id'] ?? '',
        };
      }
    } catch (e) {
      // Silently handle error
    }
    
    return {'token': '', 'chat_id': ''};
  }

  static Future<bool> sendReport({
    required String issueType,
    required String description,
    String? userEmail,
    String? username,
  }) async {
    try {
      final credentials = await _getBotCredentials();
      final botToken = credentials['token'];
      final chatId = credentials['chat_id'];
      
      if (botToken == null || botToken.isEmpty || chatId == null || chatId.isEmpty) {
        return false;
      }

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Build message
      final message = _buildMessage(
        issueType: issueType,
        description: description,
        userEmail: userEmail,
        username: username,
        deviceInfo: deviceInfo,
        appVersion: packageInfo.version,
      );

      // Send to Telegram
      final url = 'https://api.telegram.org/bot$botToken/sendMessage';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static String _buildMessage({
    required String issueType,
    required String description,
    String? userEmail,
    String? username,
    required Map<String, String> deviceInfo,
    required String appVersion,
  }) {
    final timestamp = DateTime.now().toString().split('.')[0];
    final issueNumber = DateTime.now().millisecondsSinceEpoch % 10000;
    
    return '''
🔔 <b>New Issue Report #$issueNumber</b>

👤 <b>User Info:</b>
   • Username: ${username ?? 'Guest'}
   • Email: ${userEmail ?? 'Not provided'}

🏷️ <b>Issue Type:</b> $issueType

📝 <b>Description:</b>
$description

📱 <b>Device Info:</b>
   • Platform: ${deviceInfo['platform']}
   • OS Version: ${deviceInfo['version']}
   • Device: ${deviceInfo['model']}

📲 <b>App Version:</b> $appVersion

🕐 <b>Timestamp:</b> $timestamp

━━━━━━━━━━━━━━━━━━
    ''';
  }

  static Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'version': 'Android ${androidInfo.version.release}',
          'model': '${androidInfo.manufacturer} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'version': 'iOS ${iosInfo.systemVersion}',
          'model': iosInfo.model,
        };
      }
    } catch (e) {
      // Fallback
    }
    
    return {
      'platform': 'Unknown',
      'version': 'Unknown',
      'model': 'Unknown',
    };
  }
}
