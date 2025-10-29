import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/services/domain_item_service.dart';
import '../../intervention_domains/models/domain_item_models.dart' as di;
import '../../../view/layouts/web_main_layout.dart';
import 'criteria_list_view.dart';

class ProgramCriteriaView extends StatefulWidget {
  final int programId;
  final Map<String, dynamic> programData;

  const ProgramCriteriaView({
    super.key,
    required this.programId,
    required this.programData,
  });

  @override
  State<ProgramCriteriaView> createState() => _ProgramCriteriaViewState();
}

class _ProgramCriteriaViewState extends State<ProgramCriteriaView> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String? _error;
  final DevelopmentalDomainItemService _itemService =
      DevelopmentalDomainItemService();
  List<di.DevelopmentalDomainItemModel> _domainItems = [];
  Map<String, String> _domainNames = {};

  @override
  void initState() {
    super.initState();
    _loadDomains();
    _loadDomainItems();
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
            name = m['vi'] ?? m['en'] ?? 'Domain';
          } else {
            name = displayedName?.toString() ?? 'Domain';
          }
          domainMap[id] = name;
        }
        if (mounted) {
          setState(() {
            _domainNames = domainMap;
          });
        }
      }
    } catch (e) {
      print('Error loading domains: $e');
    }
  }

  Future<void> _loadDomainItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all domain items (API doesn't support filtering by program yet)
      final page = await _itemService.getItems(page: 0, size: 100);
      if (mounted) {
        setState(() {
          _domainItems = page.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToCriteria(di.DevelopmentalDomainItemModel item) async {
    final title = item.title?.vi.isNotEmpty == true
        ? item.title!.vi
        : (item.title?.en ?? item.name ?? 'Mục tiêu lớn');

    // Check if we're in a web layout context
    final webLayoutProvider = WebLayoutProgramNavigationProvider.of(context);

    if (webLayoutProvider != null) {
      // Use web layout navigation (in-place)
      webLayoutProvider.onLargeGoalSelected(item);
    } else {
      // Use traditional navigation (mobile)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CriteriaListView(domainItemId: item.id, domainItemTitle: title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.programData['name']?.toString() ?? 'Chương trình';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Lỗi: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDomainItems,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(name),
        elevation: 0,
      ),
      body: _domainItems.isEmpty
          ? const Center(
              child: Text(
                'Chưa có mục tiêu lớn nào',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _domainItems.length,
              itemBuilder: (context, index) {
                final item = _domainItems[index];
                final title = item.title?.vi ?? item.title?.en ?? item.name ?? '';
                final domainName = _domainNames[item.domainId] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _navigateToCriteria(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (domainName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                domainName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Xem mục tiêu nhỏ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

