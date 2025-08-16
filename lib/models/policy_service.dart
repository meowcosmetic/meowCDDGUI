import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';
import 'policy_data.dart';

class PolicyService {
  static const String _baseUrl = 'http://localhost:8000';
  static const String _policyCacheKey = 'policy_cache_cdd_terms';
  static const String _policyCacheTimeKey = 'policy_cache_time_cdd_terms';
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache 24 giờ

  // Lấy policy từ cache hoặc API
  static Future<PolicyData?> getPolicy({
    String serviceName = 'CDD',
    String policyType = 'terms',
    String language = 'vi',
  }) async {
    try {
      // Kiểm tra cache trước
      final cachedPolicy = await _getCachedPolicy();
      if (cachedPolicy != null) {
        return cachedPolicy;
      }

      // Nếu không có cache, gọi API
      final policy = await _fetchPolicyFromAPI(serviceName, policyType);
      if (policy != null) {
        // Lưu vào cache
        await _cachePolicy(policy);
        return policy;
      }

      return null;
    } catch (e) {
      print('Error getting policy: $e');
      // Trả về cached data nếu có lỗi API
      return await _getCachedPolicy();
    }
  }

  // Gọi API để lấy policy
  static Future<PolicyData?> _fetchPolicyFromAPI(
    String serviceName,
    String policyType,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/policy/get?serviceName=$serviceName&policyType=$policyType',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PolicyData.fromJson(jsonData);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  // Lấy policy từ cache
  static Future<PolicyData?> _getCachedPolicy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Kiểm tra thời gian cache
      final cacheTime = prefs.getString(_policyCacheTimeKey);
      if (cacheTime != null) {
        final cachedAt = DateTime.parse(cacheTime);
        final now = DateTime.now();
        if (now.difference(cachedAt) > _cacheExpiry) {
          // Cache đã hết hạn
          await _clearCache();
          return null;
        }
      }

      // Lấy data từ cache
      final cachedData = prefs.getString(_policyCacheKey);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return PolicyData.fromJson(jsonData);
      }

      return null;
    } catch (e) {
      print('Error reading cache: $e');
      return null;
    }
  }

  // Lưu policy vào cache
  static Future<void> _cachePolicy(PolicyData policy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(policy.toJson());
      
      await prefs.setString(_policyCacheKey, jsonData);
      await prefs.setString(_policyCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching policy: $e');
    }
  }

  // Xóa cache
  static Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_policyCacheKey);
      await prefs.remove(_policyCacheTimeKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Force refresh policy từ API (bỏ qua cache)
  static Future<PolicyData?> refreshPolicy({
    String serviceName = 'CDD',
    String policyType = 'terms',
  }) async {
    try {
      // Xóa cache cũ
      await _clearCache();
      
      // Gọi API mới
      final policy = await _fetchPolicyFromAPI(serviceName, policyType);
      if (policy != null) {
        // Lưu cache mới
        await _cachePolicy(policy);
        return policy;
      }

      return null;
    } catch (e) {
      print('Error refreshing policy: $e');
      return null;
    }
  }

  // Kiểm tra xem có cần cập nhật policy không
  static Future<bool> shouldUpdatePolicy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getString(_policyCacheTimeKey);
      
      if (cacheTime == null) {
        return true; // Chưa có cache
      }

      final cachedAt = DateTime.parse(cacheTime);
      final now = DateTime.now();
      return now.difference(cachedAt) > _cacheExpiry;
    } catch (e) {
      print('Error checking policy update: $e');
      return true; // Có lỗi thì cập nhật
    }
  }

  // Gửi request mark policy đã đọc
  static Future<bool> markPolicyAsRead({
    required String customerId,
    required String policyId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/policy/read/mark');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'customerId': customerId,
          'policyId': policyId,
          'id': customerId, // id và customerId giống nhau
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Policy marked as read successfully');
        return true;
      } else {
        print('Failed to mark policy as read: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking policy as read: $e');
      return false;
    }
  }

  // Lấy customer ID từ SharedPreferences
    static Future<String?> getCustomerId() async {
    try {
      print('=== GET CUSTOMER ID ===');
      // Ưu tiên lấy từ session (đã decode từ JWT)
      if (UserSession.userId != null && UserSession.userId!.isNotEmpty) {
        print('Using UserSession.userId: ${UserSession.userId}');
        return UserSession.userId;
      }
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('customer_id');
      print('SharedPreferences customer_id: $id');
      
      if ((id == null || id.isEmpty) && UserSession.jwtToken != null) {
        print('No customer_id in SharedPreferences, trying to decode JWT...');
        final sub = UserSession.getSubFromJwt(UserSession.jwtToken!);
        if (sub != null && sub.isNotEmpty) {
          print('Decoded sub from JWT: $sub');
          await prefs.setString('customer_id', sub);
          UserSession.userId = sub;
          return sub;
        }
      }
      
      print('Returning customer_id: $id');
      return id;
    } catch (e) {
      print('Error getting customer ID: $e');
      return null;
    }
  }

  // Lưu customer ID vào SharedPreferences
  static Future<void> saveCustomerId(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customer_id', customerId);
    } catch (e) {
      print('Error saving customer ID: $e');
    }
  }

  // Kiểm tra user đã đọc policy chưa
  static Future<bool> hasUserReadPolicy({
    required String customerId,
    String serviceName = 'CDD',
    String policyType = 'terms',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/policy/read/hasByType?customerId=$customerId&serviceName=$serviceName&policyType=$policyType&currentVersion=true');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData = jsonDecode(response.body);
          // Giả sử API trả về true/false hoặc có trường hasRead
          if (responseData is bool) {
            return responseData;
          } else if (responseData is Map<String, dynamic>) {
            return responseData['hasRead'] == true || responseData['read'] == true;
          }
          return false;
        } catch (e) {
          print('Error parsing hasRead response: $e');
          return false;
        }
      } else {
        print('Failed to check policy read status: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error checking policy read status: $e');
      return false;
    }
  }

  // Kiểm tra xem có cần hiển thị policy screen không
  static Future<bool> shouldShowPolicyScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Kiểm tra guest mode
      final isGuest = prefs.getBool('guest_mode') ?? false;
      if (isGuest) {
        final guestAccepted = prefs.getBool('guest_policy_accepted') ?? false;
        return !guestAccepted;
      }

      // Kiểm tra user đã đăng nhập chưa
      final userToken = prefs.getString('user_token');
      if (userToken == null || userToken.isEmpty) {
        return true; // Chưa đăng nhập thì hiển thị
      }

      // Khởi tạo UserSession nếu cần và lấy customer ID từ JWT
      if (UserSession.jwtToken == null || UserSession.userId == null) {
        await UserSession.initFromPrefs();
      }
      final customerId = UserSession.userId ?? prefs.getString('customer_id');
      if (customerId == null || customerId.isEmpty) {
        return true; // Chưa có customer ID thì hiển thị
      }

      // Gọi API kiểm tra đã đọc policy chưa
      final hasRead = await hasUserReadPolicy(customerId: customerId);
      return !hasRead; // Chưa đọc thì hiển thị
      
    } catch (e) {
      print('Error checking should show policy screen: $e');
      return true; // Có lỗi thì hiển thị để đảm bảo an toàn
    }
  }
}
