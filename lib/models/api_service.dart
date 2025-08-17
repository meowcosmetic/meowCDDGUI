import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'user.dart';
import '../features/cdd_test_management/models/cdd_test.dart';
import 'user_session.dart';
import 'child.dart';

class ApiService {
  final String baseUrl;
  const ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  Future<http.Response> createUser(User user) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final payload = <String, dynamic>{
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'phone': user.phone,
      'sex': user.sex,
      'yearOfBirth': user.yearOfBirth,
      'avatar': user.avatar,
      'roles': user.roles.map((r) => r.name).toList(),
    };
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return resp;
  }

  Future<http.Response> login({required String email, required String password}) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
    };
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );    
    return resp;
  }

  /// Tạo trẻ mới với format JSON mới
  Future<http.Response> createChild(ChildData childData) async {
    // Lấy parentId từ user session
    final parentId = UserSession.userId;
    if (parentId == null || parentId.isEmpty) {
      throw Exception('User ID not found. Please login first.');
    }

    // Tạo payload với format mới và parentId từ user session
    final payload = childData.copyWith(
      parentId: int.tryParse(parentId) ?? 1, // Convert string to int, fallback to 1
    ).toJson();

    final uri = Uri.parse('${AppConfig.testApiBaseUrl}/api/v1/supabase/children');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return resp;
  }

  /// Lấy danh sách tất cả bài test
  Future<http.Response> getTests() async {
    final uri = Uri.parse('${AppConfig.testApiBaseUrl}/api/v1/supabase/cdd-tests');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy chi tiết bài test theo ID
  Future<http.Response> getTestById(String testId) async {
    final uri = Uri.parse('${AppConfig.testApiBaseUrl}/api/v1/supabase/cdd-tests/$testId');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Tạo bài test mới
  Future<http.Response> createTest(CDDTest test) async {
    final uri = Uri.parse('${AppConfig.testApiBaseUrl}/api/v1/supabase/cdd-tests');
    final payload = test.toJson();
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return resp;
  }
}
