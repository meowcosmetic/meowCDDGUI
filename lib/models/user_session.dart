import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'api_service.dart';

class UserSession {
  static String? jwtToken;
  static String? userId; // sub from JWT
  static bool isGuest = false;
  static User? currentUserProfile;
  
  // Get current user info
  static String? get currentUser => userId;
  
  // Check if user has specific role
  static bool hasRole(String roleName) {
    if (currentUserProfile?.roles == null) return false;
    return currentUserProfile!.roles.any((role) => role.name.toUpperCase() == roleName.toUpperCase());
  }
  
  // Check if user is parent
  static bool get isParent => hasRole('PARENT');
  
  // Check if user is teacher
  static bool get isTeacher => hasRole('TEACHER');
  
  // Helper methods for easy access to user profile data
  static String get userName => currentUserProfile?.name ?? 'Chưa có thông tin';
  static String get userEmail => currentUserProfile?.email ?? 'Chưa có thông tin';
  static String get userPhone => currentUserProfile?.phone ?? 'Chưa có thông tin';
  static String get userSex => currentUserProfile?.sex ?? 'Chưa có thông tin';
  static int get userYearOfBirth => currentUserProfile?.yearOfBirth ?? 0;
  static String get userAvatar => currentUserProfile?.avatar ?? '';
  
  // Check if user profile is loaded
  static bool get isProfileLoaded => currentUserProfile != null;

  static Future<void> initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      jwtToken = prefs.getString('user_token');
      userId = prefs.getString('customer_id');
      isGuest = prefs.getBool('guest_mode') ?? false;
      
      print('Loading from SharedPreferences:');
      print('JWT Token: ${jwtToken != null ? "EXISTS" : "NULL"}');
      print('User ID: $userId');
      print('Is Guest: $isGuest');
      
      // Load user profile if available
      final userProfileJson = prefs.getString('user_profile');
      if (userProfileJson != null) {
        print('Found user profile in SharedPreferences');
        try {
          currentUserProfile = User.fromJsonString(userProfileJson);
          print('Successfully loaded user profile:');
          print('Name: ${currentUserProfile?.name}');
          print('Email: ${currentUserProfile?.email}');
          print('Phone: ${currentUserProfile?.phone}');
        } catch (e) {
          print('Error parsing user profile from SharedPreferences: $e');
          // If parsing fails, clear the stored profile
          await prefs.remove('user_profile');
        }
      } else {
        print('No user profile found in SharedPreferences');
      }
    } catch (e) {
      print('Error in initFromPrefs: $e');
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
      
      // Load user profile immediately after login
      await _loadUserProfileFromAPI(sub);
    }
  }
  
  /// Load user profile from API and save to local storage
  static Future<void> _loadUserProfileFromAPI(String userId) async {
    try {
      final api = ApiService();
      final response = await api.getUserProfile(userId);
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userData = jsonDecode(response.body);
        print('Parsed User Data: $userData');
        
        try {
          final user = User.fromJson(userData);
          print('Successfully created User object: ${user.name}, ${user.email}, ${user.phone}');
          await updateUserProfile(user);
          print('User profile saved to local storage');
        } catch (parseError) {
          print('Error parsing User from JSON: $parseError');
          print('UserData keys: ${userData.keys.toList()}');
          
          // Try to create a minimal User object with available data
          final minimalUser = User(
            customerId: userData['customerId'] ?? userData['id'] ?? userId,
            name: userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            sex: userData['sex'] ?? 'other',
            yearOfBirth: userData['yearOfBirth'] ?? 1990,
            avatar: userData['avatar'] ?? '',
            addresses: [],
            cardDetails: [],
            interactive: 0,
            bought: 0,
            viewed: 0,
            password: '',
            token: '',
            roles: (userData['roles'] as List<dynamic>? ?? [])
                .map((r) => Role(r.toString()))
                .toList(),
            metadata: Metadata(
              createdAtIso: DateTime.now().toIso8601String(),
              updatedAtIso: DateTime.now().toIso8601String(),
            ),
          );
          
          print('Created minimal User object: ${minimalUser.name}, ${minimalUser.email}, ${minimalUser.phone}');
          await updateUserProfile(minimalUser);
          print('Minimal user profile saved to local storage');
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error loading user profile after login: $e');
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

  static Future<void> updateUserProfile(User user) async {
    currentUserProfile = user;
    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJsonString();
    
    print('Saving user profile to SharedPreferences:');
    print('Name: ${user.name}');
    print('Email: ${user.email}');
    print('Phone: ${user.phone}');
    print('JSON: $userJson');
    
    await prefs.setString('user_profile', userJson);
    
    // Verify it was saved
    final savedJson = prefs.getString('user_profile');
    print('Verified saved profile: ${savedJson != null ? "SUCCESS" : "FAILED"}');
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
      await prefs.remove('user_profile');

      // Reset static variables
      jwtToken = null;
      userId = null;
      isGuest = false;
      currentUserProfile = null;
    } catch (e) {
      // Log error if needed
      // print('Error clearing session: $e');
    }
  }
}
