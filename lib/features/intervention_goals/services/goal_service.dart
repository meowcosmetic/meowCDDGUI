import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_config.dart';
import '../models/goal_models.dart';

/// Service for managing intervention goals - Dịch vụ quản lý mục tiêu can thiệp
class InterventionGoalService {
  static const String _basePath = '/api/intervention-goals';

  /// Get all intervention goals with pagination
  Future<PagedResponse<InterventionGoalModel>> getGoals({
    int page = 0,
    int size = 10,
    String? category,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$_basePath',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PagedResponse.fromJson(
          jsonData,
          (json) => InterventionGoalModel.fromJson(json),
        );
      } else {
        throw Exception('Failed to load goals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching goals: $e');
    }
  }

  /// Get a specific goal by ID
  Future<InterventionGoalModel> getGoal(String goalId) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_basePath/$goalId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InterventionGoalModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load goal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching goal: $e');
    }
  }

  /// Create a new intervention goal
  Future<InterventionGoalModel> createGoal({
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    required String category,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_basePath');

      final payload = {
        'name': name,
        'displayedName': displayedName.toJson(),
        'description': description?.toJson(),
        'category': category,
        'targets': [], // Empty targets initially
        'isActive': true,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return InterventionGoalModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to create goal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating goal: $e');
    }
  }

  /// Update an existing intervention goal
  Future<InterventionGoalModel> updateGoal({
    required String goalId,
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    required String category,
    bool? isActive,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_basePath/$goalId');

      final payload = {
        'name': name,
        'displayedName': displayedName.toJson(),
        'description': description?.toJson(),
        'category': category,
        'isActive': isActive,
      };

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InterventionGoalModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to update goal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating goal: $e');
    }
  }

  /// Delete an intervention goal
  Future<bool> deleteGoal(String goalId) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_basePath/$goalId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting goal: $e');
    }
  }

  /// Get targets for a specific goal
  Future<List<InterventionTargetModel>> getTargets(String goalId) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$_basePath/$goalId/targets',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData
            .map((json) => InterventionTargetModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load targets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching targets: $e');
    }
  }

  /// Create a new target for a goal
  Future<InterventionTargetModel> createTarget({
    required String goalId,
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    int priority = 1,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$_basePath/$goalId/targets',
      );

      final payload = {
        'name': name,
        'displayedName': displayedName.toJson(),
        'description': description?.toJson(),
        'goalId': goalId,
        'priority': priority,
        'status': 'pending',
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return InterventionTargetModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to create target: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating target: $e');
    }
  }

  /// Update a target
  Future<InterventionTargetModel> updateTarget({
    required String targetId,
    required String name,
    required LocalizedText displayedName,
    LocalizedText? description,
    int? priority,
    String? status,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/intervention-targets/$targetId',
      );

      final payload = {
        'name': name,
        'displayedName': displayedName.toJson(),
        'description': description?.toJson(),
        'priority': priority,
        'status': status,
      };

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InterventionTargetModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to update target: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating target: $e');
    }
  }

  /// Delete a target
  Future<bool> deleteTarget(String targetId) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/api/intervention-targets/$targetId',
      );

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting target: $e');
    }
  }

  /// Get categories for goals
  Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$_basePath/categories');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData.cast<String>();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
