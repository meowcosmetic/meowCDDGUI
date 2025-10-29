import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collaborator_models.dart';

class CollaboratorService {
  static const String baseUrl = 'https://api.example.com/neon/collaborators';
  
  // Lấy danh sách tất cả collaborators với phân trang
  static Future<Map<String, dynamic>> getCollaborators({
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load collaborators: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading collaborators: $e');
    }
  }

  // Tìm kiếm collaborators
  static Future<Map<String, dynamic>> searchCollaborators({
    required String keyword,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?keyword=$keyword&page=$page&size=$size'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search collaborators: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching collaborators: $e');
    }
  }

  // Lấy thông tin collaborator theo ID
  static Future<CollaboratorDetail> getCollaboratorById(String collaboratorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$collaboratorId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CollaboratorDetail.fromJson(data);
      } else {
        throw Exception('Failed to load collaborator: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading collaborator: $e');
    }
  }

  // Tạo collaborator mới
  static Future<CollaboratorDetail> createCollaborator(CreateCollaboratorRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return CollaboratorDetail.fromJson(data);
      } else {
        throw Exception('Failed to create collaborator: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating collaborator: $e');
    }
  }

  // Cập nhật collaborator
  static Future<CollaboratorDetail> updateCollaborator(
    String collaboratorId,
    UpdateCollaboratorRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$collaboratorId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CollaboratorDetail.fromJson(data);
      } else {
        throw Exception('Failed to update collaborator: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating collaborator: $e');
    }
  }

  // Xóa collaborator
  static Future<void> deleteCollaborator(String collaboratorId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$collaboratorId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete collaborator: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting collaborator: $e');
    }
  }

  // Lấy collaborators theo user ID
  static Future<Map<String, dynamic>> getCollaboratorsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user collaborators: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user collaborators: $e');
    }
  }

  // Lấy collaborators theo role ID
  static Future<Map<String, dynamic>> getCollaboratorsByRoleId(String roleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/role/$roleId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load role collaborators: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading role collaborators: $e');
    }
  }

  // Lấy collaborators theo status
  static Future<Map<String, dynamic>> getCollaboratorsByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$status'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load status collaborators: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading status collaborators: $e');
    }
  }
}

