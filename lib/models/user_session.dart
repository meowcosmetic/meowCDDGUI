import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? jwtToken;
  static String? userId; // sub from JWT
  static bool isGuest = false;

  static Future<void> initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      jwtToken = prefs.getString('user_token');
      userId = prefs.getString('customer_id');
      isGuest = prefs.getBool('guest_mode') ?? false;
    } catch (_) {
      // swallow
    }
  }

  static Future<void> updateFromLoginToken(String token) async {
    jwtToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
    
    final sub = getSubFromJwt(token);
    if (sub != null) {
      userId = sub;
      await prefs.setString('customer_id', sub);
    }
  }

  static String? getSubFromJwt(String token) {
    try {
      final parts = token.split('.');
      
      if (parts.length != 3) {
        return null;
      }
      final payload = parts[1];
      final normalized = _base64UrlNormalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);
      if (data is Map<String, dynamic>) {
        final sub = data['sub'];
        if (sub is String && sub.isNotEmpty) {
          return sub;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _base64UrlNormalize(String input) {
    var output = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        break;
    }
    return output;
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all session-related data
      await prefs.remove('user_token');
      await prefs.remove('customer_id');
      await prefs.remove('guest_mode');
      await prefs.remove('guest_mode_enabled');
      await prefs.remove('guest_policy_accepted');
      await prefs.remove('current_user');
      
      // Reset static variables
      jwtToken = null;
      userId = null;
      isGuest = false;
    } catch (e) {
      // Log error if needed
      // print('Error clearing session: $e');
    }
  }
}


