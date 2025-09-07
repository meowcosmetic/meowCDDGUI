import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';
import 'policy_data.dart';
import '../services/host_service.dart';

class PolicyService {
  static String get _baseUrl => HostService.getApiBaseUrl();
  static const String _policyCacheKey = 'policy_cache_cdd_terms';
  static const String _policyCacheTimeKey = 'policy_cache_time_cdd_terms';
  static const Duration _cacheExpiry = Duration(hours: 24);

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
      // Trả về cached data nếu có lỗi API
      return await _getCachedPolicy();
    }
  }

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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<PolicyData?> _getCachedPolicy() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cacheTime = prefs.getString(_policyCacheTimeKey);
      if (cacheTime != null) {
        final cachedAt = DateTime.parse(cacheTime);
        final now = DateTime.now();
        if (now.difference(cachedAt) > _cacheExpiry) {
          await _clearCache();
          return null;
        }
      }

      final cachedData = prefs.getString(_policyCacheKey);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return PolicyData.fromJson(jsonData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _cachePolicy(PolicyData policy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(policy.toJson());

      await prefs.setString(_policyCacheKey, jsonData);
      await prefs.setString(_policyCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
    }
  }

  static Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_policyCacheKey);
      await prefs.remove(_policyCacheTimeKey);
    } catch (e) {
    }
  }

  static Future<PolicyData?> refreshPolicy({
    String serviceName = 'CDD',
    String policyType = 'terms',
  }) async {
    try {
      await _clearCache();

      final policy = await _fetchPolicyFromAPI(serviceName, policyType);
      if (policy != null) {
        await _cachePolicy(policy);
        return policy;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> shouldUpdatePolicy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getString(_policyCacheTimeKey);
      if (cacheTime == null) {
        return true;
      }

      final cachedAt = DateTime.parse(cacheTime);
      final now = DateTime.now();
      return now.difference(cachedAt) > _cacheExpiry;
    } catch (e) {
      return true;
    }
  }

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
          'id': customerId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('customer_id');
      return id;
    } catch (e) {
      return null;
    }
  }

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
          if (responseData is bool) {
            return responseData;
          } else if (responseData is Map<String, dynamic>) {
            return responseData['hasRead'] == true || responseData['read'] == true;
          }
          return false;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> shouldShowPolicyScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isGuest = prefs.getBool('guest_mode') ?? false;
      if (isGuest) {
        final guestAccepted = prefs.getBool('guest_policy_accepted') ?? false;
        return !guestAccepted;
      }

      final userToken = prefs.getString('user_token');
      if (userToken == null || userToken.isEmpty) {
        return true;
      }

      if (UserSession.jwtToken == null || UserSession.userId == null) {
        await UserSession.initFromPrefs();
      }
      final customerId = UserSession.userId ?? prefs.getString('customer_id');
      if (customerId == null || customerId.isEmpty) {
        return true;
      }

      final hasRead = await hasUserReadPolicy(customerId: customerId);
      return !hasRead;

    } catch (e) {
      return true;
    }
  }
}
