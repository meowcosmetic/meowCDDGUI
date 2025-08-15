import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('customer_id');
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
}
