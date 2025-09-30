import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_config.dart';

// Conditional import for web
import 'dart:html' as html show FileReader, File;
import 'user.dart';
import '../features/cdd_test_management/models/cdd_test.dart';
import 'user_session.dart';
import 'child.dart';
import 'test_result_model.dart';
import 'test_category.dart';

class ApiService {
  final String baseUrl;

  const ApiService._(this.baseUrl);

  factory ApiService({String? baseUrl}) {
    return ApiService._(baseUrl ?? AppConfig.apiBaseUrl);
  }

  // Bulk fetch basic customer profiles
  Future<http.Response> fetchCustomerProfilesBulk(List<String> userIds) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/customer-profile/basic/bulk',
    );
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'customerIds': userIds}),
    );
    return resp;
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

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final payload = <String, dynamic>{'email': email, 'password': password};
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

    final payload = childData
        .copyWith(
          parentId: parentId, // Gửi parentId dưới dạng String
        )
        .toJson();

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
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/cdd-tests/paginated?page=$page&size=$size',
    );
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
  Future<http.Response> getTestsByAgePaginated({
    int ageMonths = 0,
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/cdd-tests/age/$ageMonths/status/ACTIVE/paginated?page=$page&size=$size',
    );
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
  Future<http.Response> getTestsByCategoryPaginated({
    String category = '',
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/cdd-tests/category/$category/status/ACTIVE/paginated?page=$page&size=$size',
    );
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
  Future<http.Response> getTestsByAgeAndCategoryPaginated({
    int ageMonths = 0,
    String category = '',
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/cdd-tests/age/$ageMonths/category/$category/status/ACTIVE/paginated?page=$page&size=$size',
    );
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
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/child-test-records/child/$childId',
    );
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
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/books?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir',
    );

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

    final uri = Uri.parse(
      '${AppConfig.cddAPI}/books',
    ).replace(queryParameters: queryParams);

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

  /// Lấy danh sách tiêu chí mục tiêu (developmental item criteria)
  Future<http.Response> getDevelopmentalItemCriteria() async {
    final uri = Uri.parse('${AppConfig.cddAPI}/developmental-item-criteria');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Tạo mô tả tự động từ nội dung can thiệp
  Future<http.Response> generateDescription(String content) async {
    final uri = Uri.parse('http://localhost:8102/generate-description');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'intervention_goal': content}),
    );
    return resp;
  }

  /// Tạo mục tiêu can thiệp mới
  Future<http.Response> createDevelopmentalItemCriteria(Map<String, dynamic> criteriaData) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/developmental-item-criteria');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(criteriaData),
    );
    return resp;
  }

  /// Tìm kiếm nội dung liên quan
  Future<http.Response> searchRelatedContent({
    required String query,
    int limit = 10,
    double scoreThreshold = 0.7,
  }) async {
    final uri = Uri.parse('http://localhost:8102/search');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'limit': limit,
        'score_threshold': scoreThreshold,
      }),
    );
    return resp;
  }

  /// Xử lý mục tiêu can thiệp với nội dung liên quan
  Future<http.Response> processInterventionGoal(Map<String, dynamic> processData) async {
    final uri = Uri.parse('http://localhost:8102/process-intervention-goal');
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(processData),
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

  /// Lấy toàn bộ chương trình can thiệp (developmental programs)
  Future<http.Response> getDevelopmentalPrograms() async {
    final uri = Uri.parse('${AppConfig.cddAPI}/developmental-programs');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy danh sách tiêu chí (criteria/items) của một chương trình can thiệp
  /// Giả định endpoint: /developmental-programs/{programId}/criteria
  Future<http.Response> getProgramCriteria(int programId) async {
    final uri = Uri.parse(
      '${AppConfig.cddAPI}/developmental-programs/$programId/criteria',
    );
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
    final uri = Uri.parse('${AppConfig.cddAPI}/books');
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

  // Create book with file upload (multipart/form-data)
  Future<http.Response> createBookWithFile(
    Map<String, dynamic> bookData,
    dynamic file,
  ) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/books/upload');

    var request = http.MultipartRequest('POST', uri);

    // Add text fields (all as strings)
    bookData.forEach((key, value) {
      if (key != 'file' && value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add file if available under field name 'file'
    if (file != null) {
      if (file is PlatformFile) {
        // For mobile
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      } else if (file is File) {
        // For web or other platforms
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      } else {
        // For web HTML File
        try {
          // Convert HTML File to bytes for web
          final bytes = await _htmlFileToBytes(file);
          request.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: file.name),
          );
        } catch (e) {}
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  // Helper method to convert HTML File to bytes
  Future<Uint8List> _htmlFileToBytes(dynamic htmlFile) async {
    if (kIsWeb) {
      // For web platform
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();

      reader.onLoad.listen((event) {
        final dynamic result = reader.result;
        if (result is ByteBuffer) {
          completer.complete(result.asUint8List());
        } else if (result is Uint8List) {
          completer.complete(result);
        } else if (result is List<int>) {
          completer.complete(Uint8List.fromList(result));
        } else {
          completer.completeError(
            'Unsupported FileReader result type: ${result.runtimeType}',
          );
        }
      });

      reader.onError.listen((event) {
        completer.completeError('Failed to read file');
      });

      reader.readAsArrayBuffer(htmlFile);
      return completer.future;
    } else {
      throw UnsupportedError('HTML file conversion only supported on web');
    }
  }

  Future<http.Response> createVideo(Map<String, dynamic> videoData) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/youtube-videos');
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

  /// Get list of YouTube videos
  Future<http.Response> getYoutubeVideos() async {
    final uri = Uri.parse(
      'http://192.168.1.184/api/cdd/api/v1/neon/youtube-videos',
    );
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Delete a YouTube video by ID
  Future<http.Response> deleteYoutubeVideo(String videoId) async {
    final uri = Uri.parse(
      'http://192.168.1.184/api/cdd/api/v1/neon/youtube-videos/$videoId',
    );
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  Future<http.Response> createPost(Map<String, dynamic> postData) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/posts');
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

  /// Tạo bài post can thiệp mới
  Future<http.Response> createInterventionPost(
    Map<String, dynamic> postData,
  ) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/intervention-posts');
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

  /// Lấy danh sách bài post can thiệp với phân trang
  Future<http.Response> getInterventionPostsPaginated({
    int page = 0,
    int size = 10,
    String sortBy = 'title',
    String sortDir = 'desc',
    String? postType,
    bool? isPublished,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (postType != null && postType.isNotEmpty) {
      queryParams['postType'] = postType;
    }

    if (isPublished != null) {
      queryParams['isPublished'] = isPublished.toString();
    }

    final uri = Uri.parse(
      '${AppConfig.cddAPI}/intervention-posts',
    ).replace(queryParameters: queryParams);

    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Lấy chi tiết bài post can thiệp theo ID
  Future<http.Response> getInterventionPostById(int postId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/intervention-posts/$postId');
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  /// Cập nhật bài post can thiệp
  Future<http.Response> updateInterventionPost(
    int postId,
    Map<String, dynamic> postData,
  ) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/intervention-posts/$postId');
    final resp = await http.put(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(postData),
    );
    return resp;
  }

  /// Xóa bài post can thiệp
  Future<http.Response> deleteInterventionPost(int postId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/intervention-posts/$postId');
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

  // Delete book by ID
  Future<http.Response> deleteBook(int bookId) async {
    final uri = Uri.parse('${AppConfig.cddAPI}/books/$bookId');
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return resp;
  }

}
