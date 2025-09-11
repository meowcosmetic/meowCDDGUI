import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_config.dart';
import '../models/domain_models.dart';

class InterventionDomainService {
  final String baseUrl;
  InterventionDomainService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.cddAPI;

  // GET domains with pagination
  Future<PaginatedDomains> getDomains({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/developmental-domains?page=$page&size=$size');
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
          final domains = decoded.map((item) {
            print('🔍 Item type: ${item.runtimeType}'); // Debug log
            print('🔍 Item content: $item'); // Debug log
            if (item is Map<String, dynamic>) {
              return InterventionDomainModel.fromJson(item);
            } else {
              // Handle minified objects
              try {
                // Try to convert to Map if it's a dynamic object
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
                return InterventionDomainModel.fromJson(itemMap);
              } catch (e) {
                throw Exception('Phần tử trong mảng không thể chuyển đổi thành Map<String, dynamic>. Type: ${item.runtimeType}, Content: $item, Error: $e');
              }
            }
          }).toList();
          
          return PaginatedDomains(
            content: domains,
            pageNumber: page,
            pageSize: size,
            totalElements: domains.length,
            totalPages: 1,
            hasNext: false,
            hasPrevious: false,
            first: true,
            last: true,
          );
        } else if (decoded is Map<String, dynamic>) {
          print('📋 Processing as Map'); // Debug log
          // API returns paginated object
          return PaginatedDomains.fromJson(decoded);
        } else {
          // Try to handle other types that might be minified objects
          print('⚠️ Unexpected data type: ${decoded.runtimeType}, trying to convert...');
          try {
            // Try to convert to Map
            final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(decoded as Map);
            return PaginatedDomains.fromJson(convertedMap);
          } catch (conversionError) {
            print('❌ Conversion failed: $conversionError');
            throw Exception('API trả về định dạng dữ liệu không đúng. Mong đợi List hoặc Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}. Conversion error: $conversionError');
          }
        }
      } catch (e) {
        print('❌ Error in getDomains: $e'); // Debug log
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-200 status codes
    String errorMessage = 'Không thể tải danh sách lĩnh vực. Mã lỗi: ${resp.statusCode}';
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

  // POST create domain
  Future<InterventionDomainModel> createDomain({
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    required String category,
  }) async {
    final uri = Uri.parse('$baseUrl/developmental-domains');
    final payload = {
      'name': name,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'category': category,
    };
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
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
        
        return InterventionDomainModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-success status codes
    String errorMessage = 'Không thể tạo lĩnh vực. Mã lỗi: ${resp.statusCode}';
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

  // PUT update domain
  Future<InterventionDomainModel> updateDomain({
    required String domainId,
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    required String category,
  }) async {
    final uri = Uri.parse('$baseUrl/developmental-domains/$domainId');
    final payload = {
      'name': name,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'category': category,
    };
    final resp = await http.put(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
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
        
        return InterventionDomainModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}');
        }
        rethrow;
      }
    }
    
    // Handle non-success status codes
    String errorMessage = 'Không thể cập nhật lĩnh vực. Mã lỗi: ${resp.statusCode}';
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

  // DELETE domain
  Future<void> deleteDomain(String domainId) async {
    final uri = Uri.parse('$baseUrl/developmental-domains/$domainId');
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      String errorMessage = 'Không thể xóa lĩnh vực. Mã lỗi: ${resp.statusCode}';
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
