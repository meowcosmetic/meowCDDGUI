import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_config.dart';
import '../models/method_group_models.dart';

class InterventionMethodService {
  final String baseUrl;
  InterventionMethodService({String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.cddAPI;

  // GET methods by group ID with pagination
  Future<PaginatedMethods> getMethodsByGroup({
    required String groupId,
    int page = 0,
    int size = 10,
  }) async {
    final uri =
        Uri.parse(
          '$baseUrl/intervention-methods/group/$groupId/paginated',
        ).replace(
          queryParameters: {'page': page.toString(), 'size': size.toString()},
        );

    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      try {
        // Validate response body is not empty
        if (resp.body.isEmpty) {
          throw Exception('API trả về dữ liệu rỗng');
        }

        // Try to parse JSON
        final dynamic decoded = jsonDecode(resp.body);

        // Handle different response formats
        if (decoded is List) {
          // API returns array directly - convert to paginated format
          final methods = decoded.map((item) {
            if (item is Map<String, dynamic>) {
              return InterventionMethodModel.fromJson(item);
            } else {
              // Handle minified objects
              try {
                // Try to convert to Map if it's a dynamic object
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                  item as Map,
                );
                return InterventionMethodModel.fromJson(itemMap);
              } catch (e) {
                throw Exception(
                  'Phần tử trong mảng không thể chuyển đổi thành Map<String, dynamic>. Type: ${item.runtimeType}, Content: $item, Error: $e',
                );
              }
            }
          }).toList();

          return PaginatedMethods(
            content: methods,
            pageNumber: page,
            pageSize: size,
            totalElements: methods.length,
            totalPages: 1,
            hasNext: false,
            hasPrevious: false,
            first: true,
            last: true,
          );
        } else if (decoded is Map<String, dynamic>) {
          // API returns paginated object
          return PaginatedMethods.fromJson(decoded);
        } else {
          // Try to handle other types that might be minified objects

          try {
            // Try to convert to Map
            final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(
              decoded as Map,
            );
            return PaginatedMethods.fromJson(convertedMap);
          } catch (conversionError) {
            throw Exception(
              'API trả về định dạng dữ liệu không đúng. Mong đợi List hoặc Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}. Conversion error: $conversionError',
            );
          }
        }
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
            'Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}',
          );
        }
        rethrow;
      }
    }

    // Handle non-200 status codes
    String errorMessage =
        'Không thể tải danh sách phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        // If response body is not JSON, include first 100 chars
        errorMessage +=
            '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // POST create method
  Future<InterventionMethodModel> createMethod({
    required String code,
    required LocalizedText displayedName,
    LocalizedText? description,
    required int minAgeMonths,
    required int maxAgeMonths,
    required String groupId,
  }) async {
    final uri = Uri.parse('$baseUrl/intervention-methods');
    final payload = {
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'groupId': int.parse(groupId),
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
          throw Exception(
            'API trả về định dạng dữ liệu không đúng. Mong đợi Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}',
          );
        }

        return InterventionMethodModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
            'Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}',
          );
        }
        rethrow;
      }
    }

    // Handle non-success status codes
    String errorMessage =
        'Không thể tạo phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        errorMessage +=
            '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // PATCH update method
  Future<InterventionMethodModel> updateMethod({
    required String methodId,
    required String code,
    required LocalizedText displayedName,
    LocalizedText? description,
    required int minAgeMonths,
    required int maxAgeMonths,
    required String groupId,
  }) async {
    final uri = Uri.parse('$baseUrl/intervention-methods/$methodId');
    final payload = {
      'code': code,
      'displayedName': displayedName.toJson(),
      if (description != null) 'description': description.toJson(),
      'minAgeMonths': minAgeMonths,
      'maxAgeMonths': maxAgeMonths,
      'groupId': int.parse(groupId),
    };

    final resp = await http.patch(
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
          throw Exception(
            'API trả về định dạng dữ liệu không đúng. Mong đợi Map<String, dynamic> nhưng nhận được: ${decoded.runtimeType}',
          );
        }

        return InterventionMethodModel.fromJson(decoded);
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
            'Lỗi phân tích JSON từ API: ${e.message}\nDữ liệu nhận được: ${resp.body.length > 200 ? '${resp.body.substring(0, 200)}...' : resp.body}',
          );
        }
        rethrow;
      }
    }

    // Handle non-success status codes
    String errorMessage =
        'Không thể cập nhật phương pháp. Mã lỗi: ${resp.statusCode}';
    if (resp.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(resp.body);
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          errorMessage = 'Lỗi từ server: ${errorData['message']}';
        }
      } catch (_) {
        errorMessage +=
            '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
      }
    }
    throw Exception(errorMessage);
  }

  // DELETE method
  Future<void> deleteMethod(String methodId) async {
    final uri = Uri.parse('$baseUrl/intervention-methods/$methodId');

    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      String errorMessage =
          'Không thể xóa phương pháp. Mã lỗi: ${resp.statusCode}';
      if (resp.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(resp.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            errorMessage = 'Lỗi từ server: ${errorData['message']}';
          }
        } catch (_) {
          errorMessage +=
              '\nChi tiết: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
        }
      }
      throw Exception(errorMessage);
    }
  }
}
