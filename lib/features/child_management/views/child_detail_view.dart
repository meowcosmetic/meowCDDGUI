import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../models/child.dart';
import '../models/child_tracking.dart';
import 'child_tracking_view.dart';
import 'child_tracking_history_view.dart';
import '../../../models/api_service.dart';
import '../../../features/cdd_test_management/models/cdd_test.dart';
import 'child_completed_tests_view.dart';
import '../../cdd_test_management/views/test_detail_view.dart';
import '../../../models/test_models.dart';
import '../../../uiElement/selectable_text_widget.dart';
import '../../intervention_domains/services/domain_service.dart';
import '../../intervention_domains/models/domain_models.dart';
import '../../../models/user_session.dart';
import 'package:flutter_html/flutter_html.dart';

class ChildDetailView extends StatefulWidget {
  final Child child;

  const ChildDetailView({super.key, required this.child});

  @override
  State<ChildDetailView> createState() => _ChildDetailViewState();
}

class _ChildDetailViewState extends State<ChildDetailView> {
  final ApiService _api = ApiService();
  final InterventionDomainService _domainService = InterventionDomainService();
  List<CDDTest> _tests = [];
  List<CDDTest> _filteredTests = [];
  bool _isLoadingTests = true;
  bool _hasTestsError = false;
  String _testsErrorMessage = '';
  bool _isTestsExpanded = false;
  int _filterIndex = 0; // 0=Tất cả, 1=Khuyến nghị, 2=Không khuyến nghị
  bool _infoExpanded = false;

  // Test results state variables
  Map<String, Map<String, dynamic>> _testResults = {};
  bool _isLoadingTestResults = true;
  bool _hasTestResultsError = false;

  // Domain-related state variables
  List<InterventionDomainModel> _domains = [];
  bool _isLoadingDomains = true;
  bool _hasDomainsError = false;
  String _domainsErrorMessage = '';
  Map<String, bool> _expandedDomains = {}; // Track which domains are expanded
  bool _isActivitiesExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadTests();
    _loadDomains();
    _loadTestResults();
  }

  Future<void> _loadTests() async {
    setState(() {
      _isLoadingTests = true;
      _hasTestsError = false;
      _testsErrorMessage = '';
    });

    try {
      final resp = await _api.getTestsPaginated(
        page: 0,
        size: 100,
      ); // Load more tests for child detail
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(resp.body);
        final List<dynamic> data =
            responseData['content'] ?? responseData['data'] ?? [];
        final loaded = data.map((e) => CDDTest.fromJson(e)).toList();
        setState(() {
          _tests = loaded;
          _applyTestFilter();
          _isLoadingTests = false;
        });
      } else {
        setState(() {
          _hasTestsError = true;
          _testsErrorMessage =
              'Không thể tải danh sách bài test. Mã lỗi: ${resp.statusCode}';
          _isLoadingTests = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasTestsError = true;
        _testsErrorMessage = 'Lỗi kết nối: $e';
        _isLoadingTests = false;
      });
    }
  }

  Future<void> _loadDomains() async {
    setState(() {
      _isLoadingDomains = true;
      _hasDomainsError = false;
      _domainsErrorMessage = '';
    });

    try {
      final paginatedDomains = await _domainService.getDomains(
        page: 0,
        size: 50,
      );
      setState(() {
        _domains = paginatedDomains.content;
        _isLoadingDomains = false;
      });
    } catch (e) {
      setState(() {
        _hasDomainsError = true;
        _domainsErrorMessage = 'Lỗi kết nối: $e';
        _isLoadingDomains = false;
      });
    }
  }

  Future<void> _loadTestResults() async {
    setState(() {
      _isLoadingTestResults = true;
      _hasTestResultsError = false;
    });

    try {
      print('Child name: ${widget.child.name}');
      print('Child ID: ${widget.child}');
      print('Parent name: ${widget.child.parentName}');
      print('Loading test results for child ID: ${widget.child.id}');
      final response = await _api.getLatestTestResultsByCategory(widget.child.id);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Test results API response: $responseData');
        
        // Parse test results by category
        Map<String, Map<String, dynamic>> results = {};
        
        if (responseData is Map<String, dynamic>) {
          responseData.forEach((category, data) {
            if (data is Map<String, dynamic>) {
              results[category] = {
                'totalScore': data['totalScore'] ?? 0,
                'maxScore': data['maxScore'] ?? 0,
                'interpretation': data['interpretation'] ?? 'Chưa có thông tin',
                'resultLevel': data['resultLevel'] ?? '',
                'percentageScore': data['percentageScore'] ?? 0,
              };
            }
          });
        } else if (responseData is List) {
          // Handle case where response is a list of test results
          for (var testResult in responseData) {
            if (testResult is Map<String, dynamic>) {
              // Map testType to category
              String category = '';
              switch (testResult['testType']) {
                case 'CDD_TEST':
                  category = 'DEVELOPMENTAL_SCREENING';
                  break;
                case 'AUTISM_TEST':
                  category = 'AUTISM_SCREENING';
                  break;
                case 'ADHD_TEST':
                  category = 'ADHD_SCREENING';
                  break;
                default:
                  continue;
              }
              
              results[category] = {
                'totalScore': testResult['totalScore'] ?? 0,
                'maxScore': testResult['maxScore'] ?? 0,
                'interpretation': testResult['interpretation'] ?? 'Chưa có thông tin',
                'resultLevel': testResult['resultLevel'] ?? '',
                'percentageScore': testResult['percentageScore'] ?? 0,
              };
            }
          }
        }
        print('Test results: $results');
        setState(() {
          _testResults = results;
          _isLoadingTestResults = false;
        });
      } else {
        setState(() {
          _hasTestResultsError = true;
          _isLoadingTestResults = false;
        });
      }
    } catch (e) {
      print('Error loading test results: $e');
      setState(() {
        _hasTestResultsError = true;
        _isLoadingTestResults = false;
      });
    }
  }

  void _applyTestFilter() {
    final int childAgeMonths = widget.child.age * 12;
    List<CDDTest> base = _tests;
    if (_filterIndex == 1) {
      base = _tests.where((t) => _isRecommended(t, childAgeMonths)).toList();
    } else if (_filterIndex == 2) {
      base = _tests.where((t) => !_isRecommended(t, childAgeMonths)).toList();
    }
    setState(() {
      _filteredTests = base;
    });
  }

  bool _isRecommended(CDDTest test, int childAgeMonths) {
    final bool inAgeRange =
        childAgeMonths >= test.minAgeMonths &&
        childAgeMonths <= test.maxAgeMonths;
    final bool isActive = test.status == 'ACTIVE';
    return inAgeRange && isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          'Chi tiết: ${widget.child.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit child page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tính năng sửa thông tin trẻ sẽ được phát triển',
                  ),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // Collapsible Info Section
              _buildCollapsibleInfoSection(),

              const SizedBox(height: 16),

              // Progress Details
              _buildProgressCard(),

              const SizedBox(height: 16),

              // Recent Activities (moved up under Progress Details)
              _buildRecentActivitiesCard(),

              const SizedBox(height: 16),

              // Tracking Button
              _buildTrackingButton(),

              const SizedBox(height: 16),

              // Tests for Child
              _buildTestsCard(),

              const SizedBox(height: 16),

              // Activities Section
              _buildActivitiesCard(),

              const SizedBox(height: 16),

              // Notes
              if (widget.child.notes.isNotEmpty) ...[
                _buildNotesCard(),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadTests(),
      _loadDomains(),
      _loadTestResults(),
    ]);
  }

  Widget _buildCollapsibleInfoSection() {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _infoExpanded,
          onExpansionChanged: (expanded) =>
              setState(() => _infoExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(Icons.info, color: AppColors.primary, size: 22),
          title: const Text(
            'Thông Tin Hồ Sơ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            UserSession.isParent 
              ? 'Cơ bản, chẩn đoán bác sĩ, chẩn đoán tham khảo, giáo viên, chuyên gia'
              : 'Cơ bản, chẩn đoán bác sĩ, chẩn đoán tham khảo, chuyên gia',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          children: [
            const SizedBox(height: 8),
            _buildTableSection('Thông Tin Cơ Bản', [
              ['Họ và tên', widget.child.name],
              ['Tuổi', '${widget.child.age} tuổi'],
              ['Giới tính', widget.child.gender],
              ['Trạng thái', widget.child.getStatusText()],
              [
                'Ngày tham gia',
                '${widget.child.joinDate.day}/${widget.child.joinDate.month}/${widget.child.joinDate.year}',
              ],
            ]),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            _buildTableSection('Chẩn Đoán Bởi Bác Sĩ', [
              ['Rối loạn phát triển', 'Chưa có thông tin'],
              ['Tự kỉ', 'Chưa có thông tin'],
              ['Tăng động giảm chú ý', 'Chưa có thông tin'],
            ]),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            _buildDiagnosisSection('Chẩn Đoán Tham Khảo', [
              _buildDiagnosisRow('Rối loạn phát triển', 'DEVELOPMENTAL_SCREENING'),
              _buildDiagnosisRow('Tự kỉ', 'AUTISM_SCREENING'),
              _buildDiagnosisRow('Tăng động giảm chú ý', 'ADHD_SCREENING'),
            ]),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            // Chỉ hiển thị thông tin giáo viên nếu user là phụ huynh
            if (UserSession.isParent) ...[
              _buildTableSection(
                'Thông Tin Giáo Viên', 
                [
                  ['Tên giáo viên', 'Chưa có thông tin'], // TODO: Sẽ có API để lấy thông tin giáo viên
                  ['Số điện thoại', 'Chưa có thông tin'],
                  ['Email', 'Chưa có thông tin'],
                ]
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            _buildTableSection('Chuyên Gia Điều Trị', [
              [
                'Chuyên gia',
                widget.child.therapist.isNotEmpty
                    ? widget.child.therapist
                    : 'Chưa phân công',
              ],
            ]),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            _buildTableSection('Ghi Chú', [
              [
                'Ghi chú',
                widget.child.notes.isNotEmpty
                    ? widget.child.notes.join('\n')
                    : 'Không có ghi chú',
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTableSection(String title, List<List<String>> rows) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.primaryLight,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Table(
            columnWidths: const {0: FixedColumnWidth(140)},
            border: TableBorder.all(color: AppColors.borderLight, width: 1),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows.map((row) {
              final label = row.isNotEmpty ? row[0] : '';
              final value = row.length > 1 ? row[1] : '';
              return TableRow(
                children: [
                  Container(
                    color: AppColors.grey50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: SelectableTextWidget(
                      text: value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection(String title, List<Widget> rows) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.primaryLight,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDiagnosisRow(String diagnosis, String category) {
    final testResult = _testResults[category];
    final hasResult = testResult != null;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                diagnosis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isLoadingTestResults
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : hasResult
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${testResult!['totalScore']}/${testResult!['maxScore']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getResultLevelColor(testResult!['resultLevel']).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getResultLevelColor(testResult!['resultLevel']),
                                    ),
                                  ),
                                  child: Text(
                                    testResult!['resultLevel'] ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getResultLevelColor(testResult!['resultLevel']),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              testResult!['interpretation'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (testResult!['percentageScore'] > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${testResult!['percentageScore']}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        )
                      : const Text(
                          'Chưa có thông tin',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _navigateToTest(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                hasResult ? 'Làm lại' : 'Làm bài test',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultLevelColor(String? resultLevel) {
    switch (resultLevel?.toUpperCase()) {
      case 'EXCELLENT':
        return Colors.green;
      case 'GOOD':
        return Colors.lightGreen;
      case 'FAIR':
        return Colors.orange;
      case 'POOR':
        return Colors.red;
      case 'CRITICAL':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  void _navigateToTest(String category) async {
    // Calculate age in months from child's age (in years)
    final ageMonths = widget.child.age * 12;
    print('Child age: ${widget.child.age} years');
    print('Calculated age in months: $ageMonths');
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('Đang tải bài test $category...'),
            ],
          ),
        ),
      );
      
      // Call API to get tests for this category and age
      final api = ApiService();
      final response = await api.getTestsByAgeAndCategoryPaginated(
        ageMonths: ageMonths,
        category: category,
        page: 0,
        size: 10,
      );
      
      // Close loading dialog
      Navigator.pop(context);
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final tests = responseData['content'] as List<dynamic>? ?? [];
        
        if (tests.isNotEmpty) {
          // Navigate to TestDetailView with the first test
          final firstTest = tests.first;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestDetailView(
                testId: firstTest['id']?.toString() ?? '',
                testTitle: firstTest['name']?.toString() ?? 'Bài test',
                child: widget.child,
              ),
            ),
          );
          
          // Refresh test results after completing test
          if (result == true) {
            print('Test completed, refreshing results...');
            _loadTestResults();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tìm thấy bài test $category cho trẻ ${ageMonths} tháng tuổi'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải bài test: ${response.statusCode}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Error calling test API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải bài test: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              widget.child.name.split(' ').last[0],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.child.age} tuổi - ${widget.child.gender}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      widget.child.getStatusColor(),
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(widget.child.getStatusColor()),
                    ),
                  ),
                  child: Text(
                    widget.child.getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(widget.child.getStatusColor()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tiến Độ Chi Tiết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.child.progress.entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(entry.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: entry.value,
                        backgroundColor: AppColors.grey200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTrackingButton() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tracking Tình Trạng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Đánh giá tình trạng trẻ hôm nay thông qua bảng câu hỏi chấm điểm hằng ngày.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToTracking(context),
                  icon: const Icon(Icons.add_chart),
                  label: const Text(
                    'Bắt đầu tracking',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToTrackingHistory(context),
                  icon: const Icon(Icons.history),
                  label: const Text(
                    'Xem lịch sử',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToTracking(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildTrackingView(child: widget.child),
      ),
    );

    if (result != null && result is ChildTracking) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã lưu tracking cho ${widget.child.name} thành công!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToTrackingHistory(BuildContext context) {
    final trackingHistory = _generateDummyTrackingHistory();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildTrackingHistoryView(
          child: widget.child,
          trackingHistory: trackingHistory,
        ),
      ),
    );
  }

  List<ChildTracking> _generateDummyTrackingHistory() {
    final now = DateTime.now();
    final List<ChildTracking> history = [];

    // Dummy intervention goals
    final dummyGoals = [
      TrackingData.interventionGoals[0], // Giao tiếp bằng lời nói
      TrackingData.interventionGoals[1], // Tương tác xã hội
      TrackingData.interventionGoals[2], // Tự lập trong sinh hoạt
    ];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));

      // Generate random emotion and participation levels
      final emotionLevels = EmotionLevel.values;
      final participationLevels = ParticipationLevel.values;

      final randomEmotion = emotionLevels[i % emotionLevels.length];
      final randomParticipation =
          participationLevels[i % participationLevels.length];

      // Select 2-3 random goals for each tracking
      final selectedGoals = dummyGoals.take(2 + (i % 2)).toList();

      history.add(
        ChildTracking(
          id: 'track_${widget.child.id}_$i',
          childId: widget.child.id,
          date: DateTime(date.year, date.month, date.day, 9, 0),
          scores: {
            'comm_1': 1 + (i % 2),
            'comm_2': (i % 3),
            'social_1': 2 - (i % 2),
            'social_2': 1 + ((i + 1) % 2),
            'behavior_1': (i % 3),
            'behavior_2': 1 + (i % 2),
            'cognitive_1': 2 - (i % 2),
            'cognitive_2': (i % 3),
            'independence_1': 1 + ((i + 1) % 2),
            'independence_2': (i % 3),
          },
          notes: i == 0
              ? 'Ngày gần nhất: tinh thần tốt, hợp tác.'
              : i == 1
              ? 'Trẻ có tiến bộ trong giao tiếp.'
              : i == 2
              ? 'Cần hỗ trợ thêm trong kỹ năng tự lập.'
              : '',
          emotionLevel: randomEmotion,
          participationLevel: randomParticipation,
          selectedGoals: selectedGoals,
        ),
      );
    }
    return history;
  }

  Widget _buildTestsCard() {
    final int childAgeMonths = widget.child.age * 12;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTestsCardChildren(childAgeMonths),
      ),
    );
  }

  List<Widget> _buildTestsCardChildren(int childAgeMonths) {
    return [
      InkWell(
        onTap: () {
          setState(() {
            _isTestsExpanded = !_isTestsExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            const Icon(Icons.quiz, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Danh Sách Bài Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _isTestsExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () async {
          try {
            // Hiển thị loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            // Gọi API để lấy kết quả bài test đã làm
            final response = await _api.getTestResultsByChildId(
              widget.child.id,
            );

            // Đóng loading dialog
            Navigator.pop(context);

            if (response.statusCode >= 200 && response.statusCode < 300) {
              final dynamic responseData = jsonDecode(response.body);

              // Parse dữ liệu nhận được
              late List<dynamic> data;
              if (responseData is List) {
                data = responseData;
              } else if (responseData is Map<String, dynamic>) {
                data = responseData['content'] ?? responseData['data'] ?? [];
              } else {
                data = [];
              }

              // Chuyển đổi data từ API thành TestResult objects
              final List<TestResult> results = data.map((e) {
                int timeSpent = 0;
                if (e['startTime'] != null && e['endTime'] != null) {
                  try {
                    final startTime = DateTime.parse(e['startTime']);
                    final endTime = DateTime.parse(e['endTime']);
                    timeSpent = endTime.difference(startTime).inSeconds;
                  } catch (e) {
                    timeSpent = 0;
                  }
                }

                return TestResult(
                  id: e['id']?.toString() ?? '',
                  testId: e['testId']?.toString() ?? '',
                  userId: e['childId']?.toString() ?? '',
                  userName: widget.child.name,
                  score: (e['totalScore'] as num?)?.toDouble().toInt() ?? 0,
                  totalQuestions: (e['totalQuestions'] as num?)?.toInt() ?? 0,
                  answeredQuestions:
                      (e['correctAnswers'] as num?)?.toInt() ?? 0,
                  timeSpent: timeSpent,
                  completedAt: e['testDate'] != null
                      ? DateTime.parse(e['testDate'])
                      : DateTime.now(),
                  questionResults: [],
                  notes: e['notes'] ?? '',
                );
              }).toList();

              // Navigate to completed tests view
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildCompletedTestsView(
                      child: widget.child,
                      results: results,
                    ),
                  ),
                );
              }
            } else {
              // Hiển thị lỗi nếu API call thất bại
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Không thể tải kết quả bài test. Mã lỗi: ${response.statusCode}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            // Đóng loading dialog nếu có lỗi
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Hiển thị lỗi
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi kết nối: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.history),
        label: const Text('Xem đã làm'),
      ),
      const SizedBox(height: 12),
      _buildTestsFilter(),
      const SizedBox(height: 12),
    ]..addAll(_buildTestsContent(childAgeMonths));
  }

  List<Widget> _buildTestsContent(int childAgeMonths) {
    if (_isLoadingTests) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    } else if (_hasTestsError) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Có lỗi khi tải bài test',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _testsErrorMessage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadTests,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (_filteredTests.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(child: Text('Không có bài test phù hợp')),
        ),
      ];
    } else {
      return [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isTestsExpanded ? null : 0,
          child: _isTestsExpanded
              ? Column(
                  children: _filteredTests
                      .map(
                        (test) => _buildTestItem(
                          test,
                          _isRecommended(test, childAgeMonths),
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ];
    }
  }

  List<TestResult> _generateDummyTestResults() {
    // Prefer using loaded tests for names/ids if available
    final ids = _tests
        .take(3)
        .map((t) => t.id ?? 'test_${t.assessmentCode}')
        .toList();
    while (ids.length < 3) {
      ids.add('test_${ids.length + 1}');
    }

    final now = DateTime.now();
    return [
      TestResult(
        id: 'res_${widget.child.id}_1',
        testId: ids[0],
        userId: widget.child.id,
        userName: widget.child.name,
        score: 2,
        totalQuestions: 10,
        answeredQuestions: 10,
        timeSpent: 420,
        completedAt: now.subtract(const Duration(days: 1, hours: 2)),
        questionResults: [
          QuestionResult(
            questionId: 'q1',
            answer: true,
            timeSpent: 20,
            answeredAt: now.subtract(const Duration(days: 1, hours: 2)),
          ),
          QuestionResult(
            questionId: 'q2',
            answer: false,
            timeSpent: 30,
            answeredAt: now.subtract(const Duration(days: 1, hours: 2)),
          ),
        ],
        notes: 'Kết quả trong ngưỡng an toàn.',
      ),
      TestResult(
        id: 'res_${widget.child.id}_2',
        testId: ids[1],
        userId: widget.child.id,
        userName: widget.child.name,
        score: 4,
        totalQuestions: 12,
        answeredQuestions: 12,
        timeSpent: 610,
        completedAt: now.subtract(const Duration(days: 5, hours: 3)),
        questionResults: [
          QuestionResult(
            questionId: 'q1',
            answer: true,
            timeSpent: 25,
            answeredAt: now.subtract(const Duration(days: 5, hours: 3)),
          ),
          QuestionResult(
            questionId: 'q2',
            answer: true,
            timeSpent: 18,
            answeredAt: now.subtract(const Duration(days: 5, hours: 3)),
          ),
        ],
        notes: 'Một số dấu hiệu cần theo dõi.',
      ),
      TestResult(
        id: 'res_${widget.child.id}_3',
        testId: ids[2],
        userId: widget.child.id,
        userName: widget.child.name,
        score: 7,
        totalQuestions: 15,
        answeredQuestions: 15,
        timeSpent: 900,
        completedAt: now.subtract(const Duration(days: 12, hours: 1)),
        questionResults: [
          QuestionResult(
            questionId: 'q1',
            answer: false,
            timeSpent: 40,
            answeredAt: now.subtract(const Duration(days: 12, hours: 1)),
          ),
          QuestionResult(
            questionId: 'q2',
            answer: true,
            timeSpent: 35,
            answeredAt: now.subtract(const Duration(days: 12, hours: 1)),
          ),
        ],
        notes: 'Khuyến nghị trao đổi với chuyên gia.',
      ),
    ];
  }

  Widget _buildTestsFilter() {
    final List<Map<String, Object>> items = [
      {'label': 'Tất cả', 'icon': Icons.list_alt},
      {'label': 'Khuyến nghị', 'icon': Icons.recommend},
      {'label': 'Không khuyến nghị', 'icon': Icons.block},
    ];
    return Wrap(
      spacing: 8,
      children: List.generate(items.length, (index) {
        final String label = items[index]['label'] as String;
        final IconData icon = items[index]['icon'] as IconData;
        final selected = _filterIndex == index;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _filterIndex = index;
              _applyTestFilter();
            });
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.grey50,
          labelStyle: TextStyle(
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
        );
      }),
    );
  }

  Widget _buildTestItem(CDDTest test, bool recommended) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColor(test.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(test.category),
              color: _getCategoryColor(test.category),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        test.getName('vi'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.recommend,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Khuyến nghị',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.cake,
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
                    const SizedBox(width: 12),
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
                    const Spacer(),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _startTest(test),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          child: widget.child, // Truyền thông tin trẻ
        ),
      ),
    );
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return Colors.blue;
      case 'COMMUNICATION_ASSESSMENT':
        return Colors.green;
      case 'MOTOR_ASSESSMENT':
        return Colors.orange;
      case 'SOCIAL_ASSESSMENT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isActivitiesExpanded = !_isActivitiesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hoạt Động Can Thiệp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isActivitiesExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isActivitiesExpanded ? null : 0,
            child: _isActivitiesExpanded
                ? _buildDomainsContent()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainsContent() {
    if (_isLoadingDomains) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_hasDomainsError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Có lỗi khi tải lĩnh vực can thiệp',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _domainsErrorMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadDomains,
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
    } else if (_domains.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: Text('Không có lĩnh vực can thiệp nào')),
      );
    } else {
      return Column(
        children: _domains
            .map((domain) => _buildExpandableDomainCard(domain))
            .toList(),
      );
    }
  }

  Widget _buildExpandableDomainCard(InterventionDomainModel domain) {
    final bool isExpanded = _expandedDomains[domain.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedDomains[domain.id] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDomainIcon(domain.category),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domain.displayedName.vi.isNotEmpty
                              ? domain.displayedName.vi
                              : domain.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),
                        if (domain.description != null &&
                            domain.description!.vi.isNotEmpty) ...[
                          const Text(
                            'Mô tả:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Html(
                            data: domain.description!.vi,
                            style: {
                              "body": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textSecondary,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textSecondary,
                                margin: Margins.only(bottom: 8),
                              ),
                              "ul": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textSecondary,
                                margin: Margins.only(bottom: 8),
                              ),
                              "li": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textSecondary,
                                margin: Margins.only(bottom: 4),
                              ),
                              "strong": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              "em": Style(
                                fontSize: FontSize(12),
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            },
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _getDomainIcon(String category) {
    switch (category.toUpperCase()) {
      case 'COMMUNICATION':
      case 'GIAO_TIEP':
        return Icons.chat;
      case 'MOTOR':
      case 'VAN_DONG':
        return Icons.accessibility;
      case 'SOCIAL':
      case 'XAHOI':
        return Icons.people;
      case 'COGNITIVE':
      case 'NHAN_THUC':
        return Icons.psychology;
      case 'BEHAVIOR':
      case 'HANH_VI':
        return Icons.psychology;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildActivityCard(
    String title,
    String description,
    IconData icon,
    String duration,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Hoạt Động Gần Đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Hoàn thành bài tập giao tiếp',
            'Đạt 85% điểm số',
            '2 giờ trước',
            Icons.check_circle,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Tham gia buổi trị liệu nhóm',
            'Tương tác tốt với 3 bạn',
            '1 ngày trước',
            Icons.group,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Cập nhật tiến độ vận động',
            'Tăng 15% so với tuần trước',
            '3 ngày trước',
            Icons.trending_up,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ghi Chú',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.child.notes
              .map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
