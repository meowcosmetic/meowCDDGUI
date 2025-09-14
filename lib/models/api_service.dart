import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'user.dart';
import '../features/cdd_test_management/models/cdd_test.dart';
import 'user_session.dart';
import 'child.dart';
import 'test_result_model.dart';
import 'library_item.dart';
import 'test_category.dart';

class ApiService {
  final String baseUrl;
  
  const ApiService._(this.baseUrl);
  
  factory ApiService({String? baseUrl}) {
    return ApiService._(baseUrl ?? AppConfig.apiBaseUrl);
  }

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
    
    if (parentId == null || parentId.isEmpty) {
      throw Exception('User ID not found. Please login first.');
    }

    // Kiểm tra JWT token
    // if (UserSession.jwtToken == null || UserSession.jwtToken!.isEmpty) {
    //   throw Exception('JWT token not found. Please login first.');
    // }

    // Tạo payload với format mới và parentId từ user session
    
    final payload = childData.copyWith(
      parentId: parentId, // Gửi parentId dưới dạng String
    ).toJson();

    final uri = Uri.parse('${AppConfig.cddAPI}/children');
    
    // Debug: In thông tin request
    
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

  /// Lấy danh sách tất cả test categories
  Future<List<TestCategory>> getAllTestCategories() async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-test-categories/all');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body);
      return jsonList.map((json) => TestCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load test categories: ${resp.statusCode}');
    }
  }

  /// Tạo category bài test mới
  Future<http.Response> createTestCategory({
    required String code,
    required Map<String, Object> displayedName,
    Map<String, Object>? description,
  }) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/cdd-test-categories');
    final payload = <String, dynamic>{
      'code': code,
      'displayedName': displayedName,
      if (description != null) 'description': description,
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
    
    
    
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(testResult.toJson()),
    );
    
    
    
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
    
    
    
    return resp;
  }

  /// Lấy danh sách sách từ API với phân trang và sắp xếp
  Future<http.Response> getBooksPaginated({
    int page = 0,
    int size = 10,
    String sortBy = 'title',
    String sortDir = 'desc',
  }) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/books?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir');
    
    
    
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    
    
    return resp;
  }

  /// Lấy danh sách sách với filter
  Future<http.Response> getBooksWithFilter({
    int page = 0,
    int size = 10,
    String sortBy = 'title',
    String sortDir = 'desc',
    String? filter,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    
    if (filter != null && filter.isNotEmpty) {
      queryParams['filter'] = filter;
    }
    
    final uri = Uri.parse('${AppConfig.cddAPI}/books').replace(queryParameters: queryParams);
    
    
    
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    
    
    return resp;
  }

  /// Lấy danh sách lĩnh vực phát triển (developmental domains)
  Future<http.Response> getDevelopmentalDomains() async {
    final uri = Uri.parse('${AppConfig.cddAPI}/developmental-domains');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy chi tiết sách theo ID
  Future<http.Response> getBookById(int bookId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/books/$bookId');
    
    
    
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    
    
    return resp;
  }

  /// Lấy danh sách định dạng được hỗ trợ (supported formats)
  Future<http.Response> getSupportedFormats() async {
    final uri = Uri.parse('${AppConfig.cddAPI}/supported-formats');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  // Library Management APIs
  Future<http.Response> createBook(Map<String, dynamic> bookData) async {
    final uri = Uri.parse('$baseUrl/books');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(bookData),
    );
    return resp;
  }

  Future<http.Response> createVideo(Map<String, dynamic> videoData) async {
    final uri = Uri.parse('$baseUrl/videos');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(videoData),
    );
    return resp;
  }

  Future<http.Response> createPost(Map<String, dynamic> postData) async {
    final uri = Uri.parse('$baseUrl/posts');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(postData),
    );
    return resp;
  }
}
