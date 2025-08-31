import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'user.dart';
import '../features/cdd_test_management/models/cdd_test.dart';
import 'user_session.dart';
import 'child.dart';
import 'test_result_model.dart';

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
    // Đảm bảo UserSession đã được khởi tạo
    await UserSession.initFromPrefs();
    
    // Lấy parentId từ user session
    final parentId = UserSession.userId;
    print('DEBUG: UserSession.userId = $parentId');
    
    if (parentId == null || parentId.isEmpty) {
      throw Exception('User ID not found. Please login first.');
    }

    // Kiểm tra JWT token
    print('DEBUG: UserSession.jwtToken = ${UserSession.jwtToken?.substring(0, 20)}...');
    // if (UserSession.jwtToken == null || UserSession.jwtToken!.isEmpty) {
    //   throw Exception('JWT token not found. Please login first.');
    // }

    // Tạo payload với format mới và parentId từ user session
    print('DEBUG: parentId string = $parentId');
    
    final payload = childData.copyWith(
      parentId: parentId, // Gửi parentId dưới dạng String
    ).toJson();

    final uri = Uri.parse('${AppConfig.cddAPI}/children');
    
    // Debug: In thông tin request
    print('DEBUG: Creating child with URL: $uri');
    print('DEBUG: Payload: ${jsonEncode(payload)}');
    print('DEBUG: Headers: ${{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer ${UserSession.jwtToken?.substring(0, 20)}...',
    }}');
    
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer ${UserSession.jwtToken}',
      },
      body: jsonEncode(payload),
    );
    
    // Debug: In response
    print('DEBUG: Response status: ${resp.statusCode}');
    print('DEBUG: Response body: ${resp.body}');
    
    return resp;
  }

  /// Lấy danh sách bài test có phân trang
  Future<http.Response> getTestsPaginated({int page = 0, int size = 10}) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests/paginated?page=$page&size=$size');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy danh sách bài test theo độ tuổi có phân trang
  Future<http.Response> getTestsByAgePaginated({int ageMonths = 0, int page = 0, int size = 10}) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests/age/$ageMonths/status/ACTIVE/paginated?page=$page&size=$size');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy danh sách bài test theo category có phân trang
  Future<http.Response> getTestsByCategoryPaginated({String category = '', int page = 0, int size = 10}) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests/category/$category/status/ACTIVE/paginated?page=$page&size=$size');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy danh sách bài test theo cả age và category có phân trang
  Future<http.Response> getTestsByAgeAndCategoryPaginated({int ageMonths = 0, String category = '', int page = 0, int size = 10}) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests/age/$ageMonths/category/$category/status/ACTIVE/paginated?page=$page&size=$size');
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
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests/$testId');
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
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-tests');
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

  /// Lấy danh sách trẻ theo parentId
  Future<http.Response> getChildrenByParentId(String parentId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/children/parent/$parentId');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Gửi kết quả bài test lên server
  Future<http.Response> submitTestResult(TestResultModel testResult) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/child-test-records');
    
    print('DEBUG: Submitting test result to: $uri');
    print('DEBUG: Test result payload: ${jsonEncode(testResult.toJson())}');
    
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(testResult.toJson()),
    );
    
    print('DEBUG: Submit test result response status: ${resp.statusCode}');
    print('DEBUG: Submit test result response body: ${resp.body}');
    
    return resp;
  }

  /// Lấy danh sách kết quả bài test của một trẻ
  Future<http.Response> getTestResultsByChildId(String childId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/child-test-records/child/$childId');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('DEBUG: Get test results response status: ${resp.statusCode}');
    print('DEBUG: Get test results response body: ${resp.body}');
    
    return resp;
  }
}
