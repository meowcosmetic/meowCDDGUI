import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/models/domain_item_models.dart' as di;
import '../pages/add_criteria_page.dart';

class CriteriaListView extends StatefulWidget {
  final String domainItemId;
  final String domainItemTitle;

  const CriteriaListView({
    super.key,
    required this.domainItemId,
    required this.domainItemTitle,
  });

  @override
  State<CriteriaListView> createState() => _CriteriaListViewState();
}

class _CriteriaListViewState extends State<CriteriaListView> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _criteria = [];
  Map<String, String> _domainNames = {};

  @override
  void initState() {
    super.initState();
    print('=== CriteriaListView initialized ===');
    print('widget.domainItemId: ${widget.domainItemId}');
    print('widget.domainItemTitle: ${widget.domainItemTitle}');
    _loadDomains();
    _loadCriteria();
  }

  Future<void> _loadDomains() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDomains = prefs.getString('cached_domains');

      if (cachedDomains != null) {
        final domains = jsonDecode(cachedDomains) as List<dynamic>;
        final domainMap = <String, String>{};
        for (final domain in domains) {
          final id = domain['id']?.toString() ?? '';
          final displayedName = domain['displayedName'];
          String name = '';
          if (displayedName is Map) {
            final m = displayedName.cast<String, dynamic>();
            name = (m['vi'] ?? m['en'] ?? '').toString();
          } else if (displayedName != null) {
            name = displayedName.toString();
          }
          if (id.isNotEmpty && name.isNotEmpty) {
            domainMap[id] = name;
          }
        }
        setState(() => _domainNames = domainMap);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _loadCriteria() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('Loading criteria for itemId: ${widget.domainItemId}');
      final resp = await _apiService.getDevelopmentalItemCriteriaByItemId(
        widget.domainItemId,
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('API Response: $data');

        List<dynamic> criteriaList = [];
        if (data is Map<String, dynamic>) {
          if (data['content'] is List) {
            criteriaList = data['content'];
          } else if (data['data'] is List) {
            criteriaList = data['data'];
          } else if (data['items'] is List) {
            criteriaList = data['items'];
          } else if (data['results'] is List) {
            criteriaList = data['results'];
          }
          // If no list found in map, keep empty list
        } else if (data is List) {
          criteriaList = data;
        }

        setState(() {
          _criteria = criteriaList
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });

        print('Loaded ${_criteria.length} criteria items');
      } else {
        setState(() => _error = 'Lỗi tải danh sách: ${resp.statusCode}');
        print('Error loading criteria: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      print('Exception loading criteria: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewCriteria() async {
    print('=== Adding new criteria ===');
    print('widget.domainItemId: ${widget.domainItemId}');
    print('widget.domainItemTitle: ${widget.domainItemTitle}');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCriteriaPage(itemId: widget.domainItemId),
      ),
    );

    // Always reload criteria when returning from add page
    _loadCriteria();
  }

  Future<void> _editCriteria(Map<String, dynamic> criteria) async {
    print('=== Editing criteria ===');
    print('Criteria ID: ${criteria['id']}');
    print('Criteria data: $criteria');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCriteriaPage(
          itemId: widget.domainItemId,
          initialData: criteria,
          isEditMode: true,
        ),
      ),
    );

    // Always reload criteria when returning from edit page
    _loadCriteria();
  }

  Future<void> _deleteCriteria(String id) async {
    print('=== Deleting criteria ===');
    print('Criteria ID to delete: $id');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu can thiệp'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa mục tiêu can thiệp này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      print('Calling delete API for criteria ID: $id');
      final resp = await _apiService.deleteDevelopmentalItemCriteria(id);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        // Remove from local list
        setState(() {
          _criteria.removeWhere((item) => item['id']?.toString() == id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa mục tiêu can thiệp'),
              backgroundColor: Colors.green,
            ),
          );
        }
        print('Criteria deleted successfully');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xóa thất bại: ${resp.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Delete failed with status: ${resp.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Delete exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mục tiêu nhỏ - ${widget.domainItemTitle}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCriteria,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCriteria,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Lỗi: $_error'))
          : RefreshIndicator(
              onRefresh: _loadCriteria,
              child: _criteria.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có mục tiêu nhỏ nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn nút + để thêm mục tiêu mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _criteria.length,
                      itemBuilder: (context, index) {
                        final criteria = _criteria[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              print(
                                'Clicked criteria itemId: ${widget.domainItemId}',
                              );
                              print('Criteria data: $criteria');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          criteria['name'] ??
                                              criteria['title'] ??
                                              criteria['content'] ??
                                              'Mục tiêu can thiệp',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _editCriteria(criteria),
                                        tooltip: 'Sửa',
                                        iconSize: 20,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteCriteria(
                                          criteria['id']?.toString() ?? '',
                                        ),
                                        tooltip: 'Xóa',
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                  if (criteria['description'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      criteria['description'] is Map
                                          ? (criteria['description']['vi'] ??
                                                criteria['description']['en'] ??
                                                '')
                                          : criteria['description'].toString(),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (criteria['minAgeMonths'] != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Từ ${criteria['minAgeMonths']} tháng',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (criteria['maxAgeMonths'] != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Đến ${criteria['maxAgeMonths']} tháng',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (criteria['level'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Mức ${criteria['level']}',
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
