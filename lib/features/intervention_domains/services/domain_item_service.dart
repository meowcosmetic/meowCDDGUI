import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_config.dart';
import '../models/domain_item_models.dart';

class DevelopmentalDomainItemService {
  final String baseUrl;
  DevelopmentalDomainItemService({String? baseUrl})
    : baseUrl = baseUrl ?? AppConfig.cddAPI;

  Future<PaginatedDomainItems> getItems({int page = 0, int size = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/developmental-domain-items?page=$page&size=$size',
    );
    final resp = await http.get(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200) {
      final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
      return PaginatedDomainItems.fromJson(jsonMap);
    }
    throw Exception('Failed to load items: ${resp.statusCode}');
  }

  // New model: only title + domainId
  Future<DevelopmentalDomainItemModel> createItem({
    required LocalizedText title,
    required String domainId,
  }) async {
    final uri = Uri.parse('$baseUrl/developmental-domain-items');
    final payload = {'title': title.toJson(), 'domainId': domainId};
    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
      return DevelopmentalDomainItemModel.fromJson(jsonMap);
    }
    throw Exception('Failed to create item: ${resp.statusCode}');
  }

  Future<DevelopmentalDomainItemModel> updateItem({
    required String id,
    required LocalizedText title,
    required String domainId,
  }) async {
    final uri = Uri.parse('$baseUrl/developmental-domain-items/$id');
    final payload = {'title': title.toJson(), 'domainId': domainId};
    final resp = await http.put(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (resp.statusCode == 200) {
      final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
      return DevelopmentalDomainItemModel.fromJson(jsonMap);
    }
    throw Exception('Failed to update item: ${resp.statusCode}');
  }

  Future<void> deleteItem(String id) async {
    final uri = Uri.parse('$baseUrl/developmental-domain-items/$id');
    final resp = await http.delete(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to delete item: ${resp.statusCode}');
    }
  }
}
