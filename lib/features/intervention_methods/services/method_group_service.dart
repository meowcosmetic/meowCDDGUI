import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_config.dart';
import '../models/method_group_models.dart';

class InterventionMethodGroupService {
  final String baseUrl;
  InterventionMethodGroupService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.cddAPI;

  // GET method groups with pagination
  Future<PaginatedMethodGroups> getMethodGroups({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/intervention-method-groups?page=$page&size=$size');
    print('🔍 Calling API: $uri'); // Debug log
    
    final resp = await http.get(uri, headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
    
    print('📡 Response status: ${resp.statusCode}'); // Debug log
    print('📄 Response body length: ${resp.body.length}'); // Debug log
    print('📄 Response body preview: ${resp.body.length > 100 ? resp.body.substring(0, 100) + '...' : resp.body}'); // Debug log
    
    if (resp.statusCode == 200) {
      try {
        // Validate response body is not empty
        if (resp.body.isEmpty) {
          throw Exception('API trả về dữ liệu rỗng');
        }
        
        // Try to parse JSON
        final dynamic decoded = jsonDecode(resp.body);
        print('🔍 Decoded type: ${decoded.runtimeType}'); // Debug log
        print('🔍 Decoded content: $decoded'); // Debug log - show full content
        
        // Handle different response formats
        if (decoded is List) {
          print('📋 Processing as List with ${decoded.length} items'); // Debug log
          // API returns array directly - convert to paginated format
          final methodGroups = decoded.map((item) {
            print('🔍 Item type: ${item.runtimeType}'); // Debug log
            print('🔍 Item content: $item'); // Debug log
            if (item is Map<String, dynamic>) {
              return InterventionMethodGroupModel.fromJson(item);
            } else {
              // Handle minified objects
              try {
                // Try to convert to Map if it's a dynamic object
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
                return InterventionMethodGroupModel.fromJson(itemMap);
              } catch (e) {
                throw Exception('Phần tử trong mảng không thể chuyển đổi thành Map<String, dynamic>. Type: ${item.runtimeType}, Content: $item, Error: $e');
              }
            }
          }).toList();
          
          return PaginatedMethodGroups(
            content: methodGroups,
            pageNumber: page,
            pageSize: size,
            totalElements: methodGroups.length,
            totalPages: 1,
            hasNext: false,
            hasPrevious: false,
            first: true,
            last: true,
          );
        } else if (decoded is Map<String, dynamic>) {
          print('📋 Processing as Map'); // Debug log
          // API returns paginated object
          return PaginatedMethodGroups.fromJson(decoded);
        } else {
          // Try to handle other types that might be minified objects
          print('⚠️ Unexpected data type: ${decoded.runtimeType}, trying to convert...');
          try {
            // Try to convert to Map
            final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(decoded as Map);
            return PaginatedMethodGroups.fromJson(convertedMap);
          } catch (conversionError) {
            print('❌ Conversion failed: $conversionError');
            throw Exception('API trả về định dạng dữ liệu không đúng. Mong đợi List hoặc Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}. Conversion error: $conversionError');
          }
        }
      } catch (e) {
        print('❌ Error in getMethodGroups: $e'); // Debug log
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-200 status codes
    String errorMessage = 'Không thể tải danh sách nhóm phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        // If response body is not JSON, include first 100 chars
        errorMessage += '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // GET single method group by ID
  Future<InterventionMethodGroupModel> getMethodGroupById(String groupId) async {
    final uri = Uri.parse('$baseUrl/intervention-method-groups/$groupId');
    print('🔍 Calling API: $uri'); // Debug log
    
    final resp = await http.get(uri, headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
    
    print('📡 Response status: ${resp.statusCode}'); // Debug log
    print('📄 Response body: ${resp.body}'); // Debug log
    
    if (resp.statusCode == 200) {
      try {
        // Validate response body is not empty
        if (resp.body.isEmpty) {
          throw Exception('API trả về dữ liệu rỗng');
        }
        
        // Try to parse JSON
        final dynamic decoded = jsonDecode(resp.body);
        
        // Validate that decoded data is a Map
        if (decoded is! Map<String, dynamic>) {
          throw Exception('API trả về định dạng dữ liệu không đúng. Mong đợi Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}');
        }
        
        return InterventionMethodGroupModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-success status codes
    String errorMessage = 'Không thể tải nhóm phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        errorMessage += '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // POST create method group
  Future<InterventionMethodGroupModel> createMethodGroup({
    required String code,
    required LocalizedText displayedName,
    LocalizedText? description,
    required int minAgeMonths,
    required int maxAgeMonths,
  }) async {
    final uri = Uri.parse('$baseUrl/intervention-method-groups');
    final payload = {
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
    };
    
    print('🔍 Creating method group with payload: $payload'); // Debug log
    
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    
    print('📡 Response status: ${resp.statusCode}'); // Debug log
    print('📄 Response body: ${resp.body}'); // Debug log
    
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      try {
        // Validate response body is not empty
        if (resp.body.isEmpty) {
          throw Exception('API trả về dữ liệu rỗng');
        }
        
        // Try to parse JSON
        final dynamic decoded = jsonDecode(resp.body);
        
        // Validate that decoded data is a Map
        if (decoded is! Map<String, dynamic>) {
          throw Exception('API trả về định dạng dữ liệu không đúng. Mong đợi Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}');
        }
        
        return InterventionMethodGroupModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-success status codes
    String errorMessage = 'Không thể tạo nhóm phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        errorMessage += '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // PATCH update method group
  Future<InterventionMethodGroupModel> updateMethodGroup({
    required String groupId,
    required String code,
    required LocalizedText displayedName,
    LocalizedText? description,
    required int minAgeMonths,
    required int maxAgeMonths,
  }) async {
    final uri = Uri.parse('$baseUrl/intervention-method-groups/$groupId');
    final payload = {
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
    };
    
    print('🔍 Updating method group $groupId with payload: $payload'); // Debug log
    
    final resp = await http.patch(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    
    print('📡 Response status: ${resp.statusCode}'); // Debug log
    print('📄 Response body: ${resp.body}'); // Debug log
    
    if (resp.statusCode == 200) {
      try {
        // Validate response body is not empty
        if (resp.body.isEmpty) {
          throw Exception('API trả về dữ liệu rỗng');
        }
        
        // Try to parse JSON
        final dynamic decoded = jsonDecode(resp.body);
        
        // Validate that decoded data is a Map
        if (decoded is! Map<String, dynamic>) {
          throw Exception('API trả về định dạng dữ liệu không đúng. Mong đợi Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}');
        }
        
        return InterventionMethodGroupModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-success status codes
    String errorMessage = 'Không thể cập nhật nhóm phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        errorMessage += '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // DELETE method group
  Future<void> deleteMethodGroup(String groupId) async {
    final uri = Uri.parse('$baseUrl/intervention-method-groups/$groupId');
    print('🔍 Deleting method group: $groupId'); // Debug log
    
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📡 Response status: ${resp.statusCode}'); // Debug log
    print('📄 Response body: ${resp.body}'); // Debug log
    
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      String errorMessage = 'Không thể xóa nhóm phương pháp. Mã lỗi: ${resp.statusCode}';
      if (resp.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(resp.body);
          if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
            errorMessage = 'Lỗi từ server: ${errorData['message']}';
          }
        } catch (_) {
          errorMessage += '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
        }
      }
      throw Exception(errorMessage);
    }
  }
}
