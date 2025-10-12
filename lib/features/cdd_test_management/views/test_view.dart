import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_colors.dart';
import '../../../constants/app_config.dart';
import '../../../models/api_service.dart';
import 'test_detail_view.dart';
import 'create_test_view.dart';
import 'create_category_view.dart';
import '../models/cdd_test.dart';
import '../../../uiElement/chat_dialog.dart';
import '../../../uiElement/fab_utility.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  List<CDDTest> tests = [];
  List<CDDTest> filteredTests = [];
  String searchQuery = '';
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  final ApiService _api = ApiService();

  // Pagination variables
  int currentPage = 0;
  int pageSize = 10;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  int totalItems = 0;

  // Filter variables
  String selectedCategory = 'Tất cả';
  int? selectedAgeMonths; // null = không filter theo tuổi
  List<String> availableCategories = [];

  // Text editing controller for age input
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadTests({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 0;
        tests.clear();
        filteredTests.clear();
        hasMoreData = true;
      });
    }

    if (!hasMoreData || isLoadingMore) return;

    setState(() {
      if (refresh) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      hasError = false;
      errorMessage = '';
    });

    try {
      http.Response response;

      // Determine which API to call based on filters
      if (selectedCategory != 'Tất cả' && selectedAgeMonths != null) {
        // Both filters active
        final category = _getCategoryCode(selectedCategory);
        response = await _api.getTestsByAgeAndCategoryPaginated(
          ageMonths: selectedAgeMonths!,
          category: category,
          page: currentPage,
          size: pageSize,
        );
      } else if (selectedCategory != 'Tất cả') {
        // Only category filter active
        final category = _getCategoryCode(selectedCategory);
        response = await _api.getTestsByCategoryPaginated(
          category: category,
          page: currentPage,
          size: pageSize,
        );
      } else if (selectedAgeMonths != null) {
        // Only age filter active
        response = await _api.getTestsByAgePaginated(
          ageMonths: selectedAgeMonths!,
          page: currentPage,
          size: pageSize,
        );
      } else {
        // No filters active
        response = await _api.getTestsPaginated(
          page: currentPage,
          size: pageSize,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['content'] ?? [];
        final int total = responseData['totalElements'] ?? 0;
        final bool isLastPage = responseData['last'] == true;
        final int totalPages =
            responseData['totalPages'] ?? ((total + pageSize - 1) ~/ pageSize);

        final List<CDDTest> fetchedTests = data
            .map((json) => CDDTest.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            tests = fetchedTests;
            filteredTests = fetchedTests;
          } else {
            tests.addAll(fetchedTests);
            if (selectedCategory != 'Tất cả' || selectedAgeMonths != null) {
              filteredTests = fetchedTests;
            } else {
              filteredTests.addAll(fetchedTests);
            }
          }
          totalItems = total;
          currentPage++;
          // Prefer explicit flag from API; fallback to length vs total
          hasMoreData = totalPages > 0 ? !isLastPage : tests.length < total;
          isLoading = false;
          isLoadingMore = false;
        });

        // Update available filter options
        _updateFilterOptions();

        // Apply search filter only if no other filters are active
        if (selectedCategory == 'Tất cả' && selectedAgeMonths == null) {
          _applySearchFilter();
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage =
              'Không thể tải danh sách bài test. Mã lỗi: ${response.statusCode}';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _updateFilterOptions() {
    // Update available categories
    final categories = tests
        .map((t) => _getCategoryDisplayName(t.category))
        .toSet()
        .toList();
    categories.sort();
    availableCategories = ['Tất cả', ...categories];
  }

  String _getCategoryCode(String displayName) {
    switch (displayName) {
      case 'Sàng lọc phát triển':
        return 'DEVELOPMENTAL_SCREENING';
      case 'Giao tiếp & Ngôn ngữ':
        return 'COMMUNICATION_LANGUAGE';
      case 'Vận động thô':
        return 'GROSS_MOTOR';
      case 'Vận động tinh':
        return 'FINE_MOTOR';
      case 'Bắt chước & Học tập':
        return 'IMITATION_LEARNING';
      case 'Cá nhân & Xã hội':
        return 'PERSONAL_SOCIAL';
      case 'Khác':
        return 'OTHER';
      default:
        return displayName;
    }
  }

  void _filter() {
    // Reset pagination and reload data with new filters
    setState(() {
      currentPage = 0;
      tests.clear();
      filteredTests.clear();
      hasMoreData = true;
    });
    _loadTests();
  }

  void _applyAgeFilter() {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      setState(() {
        selectedAgeMonths = null;
      });
    } else {
      final age = int.tryParse(ageText);
      if (age != null && age >= 0) {
        setState(() {
          selectedAgeMonths = age;
        });
      } else {
        // Show error for invalid input
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập số tháng hợp lệ (>= 0)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    _filter();
  }

  void _applySearchFilter() {
    setState(() {
      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) {
        // If no search query, show all tests (respecting other filters)
        if (selectedCategory == 'Tất cả' && selectedAgeMonths == null) {
          filteredTests = tests;
        }
        // If other filters are active, keep the current filtered results
      } else {
        // Apply search filter on top of existing filters
        final baseTests =
            selectedCategory == 'Tất cả' && selectedAgeMonths == null
            ? tests
            : filteredTests;
        filteredTests = baseTests.where((t) {
          return t.getName('vi').toLowerCase().contains(q) ||
              t.getDescription('vi').toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _loadMoreData() async {
    if (hasMoreData && !isLoadingMore) {
      await _loadTests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FABUtility.buildSmartFAB(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Bài Test'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTestView()),
            ),
            tooltip: 'Thêm bài test',
          ),
          if (AppConfig.enableAddTestCategory)
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCategoryView(),
                ),
              ),
              tooltip: 'Thêm category',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTests(refresh: true),
            tooltip: 'Làm mới',
          ),
        ],
        bottom: totalItems > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hiển thị ${filteredTests.length} / ${tests.length} bài test (tổng: $totalItems)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    searchQuery = value;
                    _applySearchFilter();
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bài test...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            hint: const Text('Danh mục'),
                            items: availableCategories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedCategory = newValue;
                                });
                                _filter();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Age Input Filter
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Nhập số tháng (VD: 24)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _applyAgeFilter(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _applyAgeFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Áp dụng'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Clear Filters Button
                if (selectedCategory != 'Tất cả' ||
                    selectedAgeMonths != null ||
                    searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedCategory = 'Tất cả';
                            selectedAgeMonths = null;
                            searchQuery = '';
                            _ageController.clear();
                          });
                          _filter();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Xóa bộ lọc'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Test List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? _buildErrorState()
                : filteredTests.isEmpty
                ? _buildEmptyState()
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        _loadMoreData();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTests.length + (hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredTests.length) {
                          return _buildLoadMoreIndicator();
                        }
                        final test = filteredTests[index];
                        return _buildTestCard(test);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadTests(refresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(CDDTest test) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _startTest(test),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        test.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(test.category),
                      color: _getCategoryColor(test.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.getName('vi'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test.getDescription('vi'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildInfoChip(
                              Icons.timer,
                              '${test.estimatedDuration} phút',
                            ),
                            if (test.version.isNotEmpty)
                              _buildInfoChip(Icons.sell, 'v${test.version}'),
                            _buildInfoChip(
                              Icons.assignment_ind,
                              _getAdministrationText(test.administrationType),
                            ),
                            if (test.createdAt != null)
                              _buildInfoChip(
                                Icons.event_note,
                                'Tạo: ${_formatDate(test.createdAt!)}',
                              ),
                            if (test.updatedAt != null)
                              _buildInfoChip(
                                Icons.update,
                                'Cập nhật: ${_formatDate(test.updatedAt!)}',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${test.minAgeMonths}-${test.maxAgeMonths} tháng',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.quiz,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${test.questions.length} câu',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        test.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(test.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(test.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _startTest(test),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Small info chip for metadata on test cards
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Map administration type to readable text
  String _getAdministrationText(String type) {
    switch (type) {
      case 'PARENT_REPORT':
        return 'Phụ huynh báo cáo';
      case 'PROFESSIONAL_OBSERVATION':
        return 'Chuyên gia quan sát';
      case 'DIRECT_ASSESSMENT':
        return 'Đánh giá trực tiếp';
      case 'SELF_REPORT':
        return 'Tự báo cáo';
      default:
        return type;
    }
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.quiz, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy bài test nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Thử thay đổi tìm kiếm để tìm bài test phù hợp'),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!hasMoreData) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Đã tải hết dữ liệu',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'Đang tải thêm...',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _startTest(CDDTest test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestDetailView(
          testId: test.id ?? '',
          testTitle: test.getName('vi'),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return Icons.psychology;
      case 'COMMUNICATION_LANGUAGE':
        return Icons.chat;
      case 'GROSS_MOTOR':
        return Icons.accessibility;
      case 'FINE_MOTOR':
        return Icons.handyman;
      case 'IMITATION_LEARNING':
        return Icons.school;
      case 'PERSONAL_SOCIAL':
        return Icons.people;
      case 'OTHER':
        return Icons.more_horiz;
      default:
        return Icons.quiz;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Bản nháp';
      case 'ACTIVE':
        return 'Hoạt động';
      case 'INACTIVE':
        return 'Không hoạt động';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.orange;
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return 'Sàng lọc phát triển';
      case 'COMMUNICATION_LANGUAGE':
        return 'Giao tiếp & Ngôn ngữ';
      case 'GROSS_MOTOR':
        return 'Vận động thô';
      case 'FINE_MOTOR':
        return 'Vận động tinh';
      case 'IMITATION_LEARNING':
        return 'Bắt chước & Học tập';
      case 'PERSONAL_SOCIAL':
        return 'Cá nhân & Xã hội';
      case 'OTHER':
        return 'Khác';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return Colors.blue;
      case 'COMMUNICATION_LANGUAGE':
        return Colors.green;
      case 'GROSS_MOTOR':
        return Colors.orange;
      case 'FINE_MOTOR':
        return Colors.purple;
      case 'IMITATION_LEARNING':
        return Colors.teal;
      case 'PERSONAL_SOCIAL':
        return Colors.indigo;
      case 'OTHER':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
