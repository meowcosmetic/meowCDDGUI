import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../models/policy_service.dart';
import '../models/policy_data.dart';
import '../models/user_session.dart';
import '../services/messaging_service.dart';
import 'children_list_view.dart';
import '../features/library_management/library_view.dart';
import '../features/cdd_test_management/views/test_view.dart';
import 'collaborator_search_view.dart';
import 'expert_connect_view.dart';
import 'store_view.dart';
import 'donation_view.dart';
import '../uiElement/chat_dialog.dart';
import '../uiElement/fab_utility.dart';
import '../features/intervention_domains/views/domains_view.dart';
import '../features/intervention_goals/views/goals_view.dart';
import '../features/intervention_methods/views/method_groups_view.dart';
import 'login_view_html.dart';

class PolicyView extends StatefulWidget {
  const PolicyView({super.key});

  @override
  State<PolicyView> createState() => _PolicyViewState();
}

class _PolicyViewState extends State<PolicyView> {
  bool _hasAgreed = false;
  bool _isLoading = true;
  bool _isError = false;
  PolicyData? _policyData;
  String _language = 'vi'; // Default language

  static const String _kGuestMode = 'guest_mode_enabled';
  static const String _kGuestPolicyAccepted = 'guest_policy_accepted';
  static const String _kGuestPolicyAcceptedAt = 'guest_policy_accepted_at';

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      final policy = await PolicyService.getPolicy();

      if (mounted) {
        setState(() {
          _policyData = policy;
          _isLoading = false;
          _isError = policy == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    }
  }

  Future<void> _refreshPolicy() async {
    await _loadPolicy();
  }

  Future<void> _persistGuestAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_kGuestMode) ?? false;

    if (isGuest) {
      await prefs.setBool(_kGuestPolicyAccepted, true);
      await prefs.setString(
        _kGuestPolicyAcceptedAt,
        DateTime.now().toIso8601String(),
      );
    }

    // Nếu user đã đăng nhập và có policy data, gửi request mark policy
    final userToken = prefs.getString('user_token');
    if (userToken != null && userToken.isNotEmpty && _policyData != null) {
      await _markPolicyAsRead();
    }
  }

  Future<void> _markPolicyAsRead() async {
    try {
      final customerId = await PolicyService.getCustomerId();
      if (customerId != null && _policyData != null) {
        final success = await PolicyService.markPolicyAsRead(
          customerId: customerId,
          policyId: _policyData!.policyId,
        );

        if (success) {
          // Marked as read
        } else {
          // Failed to mark as read
        }
      }
    } catch (e) {
      // ignore
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.showPolicyScreen) {
      // If policy screen is disabled by config, jump to main
      return const MainAppView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FABUtility.buildSmartFAB(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          _policyData?.getTitle(_language) ?? 'Chính Sách & Điều Khoản',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_policyData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPolicy,
              tooltip: 'Làm mới',
            ),
          IconButton(
            icon: const Icon(Icons.web),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginViewHtml()),
              );
            },
            tooltip: 'Test HTML Form',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
          ? _buildErrorWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.security,
                          size: 48,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _policyData?.getTitle(_language) ??
                              'Chính Sách Bảo Mật & Sử Dụng',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ứng dụng hỗ trợ can thiệp rối loạn phát triển tại nhà',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Policy Sections from API
                  if (_policyData != null) ...[
                    ...(_policyData!.sections.toList()
                          ..sort((a, b) => a.order.compareTo(b.order)))
                        .map((section) => _buildPolicySectionFromAPI(section))
                        .toList(),
                  ] else ...[
                    // Fallback sections if API data is not available
                    _buildPolicySection(
                      icon: Icons.privacy_tip,
                      title: '1. Chính Sách Bảo Mật Thông Tin',
                      content: [
                        'Tất cả thông tin cá nhân của trẻ và gia đình được mã hóa và bảo vệ nghiêm ngặt',
                        'Chúng tôi không chia sẻ thông tin với bên thứ ba mà không có sự đồng ý rõ ràng',
                        'Dữ liệu được lưu trữ an toàn trên máy chủ được bảo vệ',
                        'Phụ huynh có quyền truy cập, chỉnh sửa hoặc xóa thông tin của con mình',
                        'Ứng dụng tuân thủ các quy định về bảo vệ dữ liệu cá nhân',
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Contact Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.contact_support,
                          size: 32,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Liên Hệ Hỗ Trợ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: support@autismcare.vn\nHotline: 1900-xxxx\nThời gian: 24/7',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Agreement Section
                  Container(
                    width: double.infinity,
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
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _hasAgreed,
                              onChanged: (value) {
                                setState(() {
                                  _hasAgreed = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: Text(
                                'Tôi đã đọc và đồng ý với tất cả chính sách và điều khoản sử dụng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _hasAgreed
                                ? () async {
                                    await _persistGuestAgreement();
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainAppView(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Đồng Ý & Tiếp Tục',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Last Updated
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Phiên bản: ${_policyData?.version ?? 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cập nhật lần cuối: ${_formatDate(_policyData?.metadata.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Không thể tải chính sách',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra kết nối mạng và thử lại',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshPolicy,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySectionFromAPI(PolicySection section) {
    final icon = _getSectionIcon(section.sectionType);
    final title = '${section.order}. ${section.getTitle(_language)}';
    final content = section.getContentList(_language);

    return Column(
      children: [
        _buildPolicySection(icon: icon, title: title, content: content),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getSectionIcon(String sectionType) {
    switch (sectionType) {
      case 'privacy':
        return Icons.privacy_tip;
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.psychology;
      case 'support':
        return Icons.support_agent;
      case 'payment':
        return Icons.payment;
      case 'terms':
        return Icons.gavel;
      default:
        return Icons.description;
    }
  }

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required List<String> content,
  }) {
    return Container(
      width: double.infinity,
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
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...content
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
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

// Main App View sau khi đồng ý chính sách
class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StoreView(),
    const DonationView(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang Chủ'),
    const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Cửa Hàng'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.volunteer_activism),
      label: 'Đóng Góp',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FABUtility.buildSmartFAB(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Hỗ Trợ Trẻ Tự Kỷ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey600,
        backgroundColor: AppColors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: _bottomNavItems,
      ),
    );
  }
}

// Dashboard Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AppConfig.getEnabledCategories();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          if (AppConfig.showWelcomeMessage) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology, size: 48, color: AppColors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Chào mừng trở lại!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy chọn danh mục bạn muốn sử dụng',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Categories Grid
          Text(
            'Danh Mục Chính',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          ),

          const SizedBox(height: 24),

          // Quick Stats Section
          if (AppConfig.showProgressTips) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thống Kê Nhanh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Trẻ đang theo dõi',
                          '5',
                          Icons.child_care,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Bài test đã làm',
                          '12',
                          Icons.quiz,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Tài liệu đã đọc',
                          '8',
                          Icons.book,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, DashboardCategory category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category page
        switch (category.id) {
          case 'library':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LibraryView()),
            );
            break;
          case 'tests':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TestView()),
            );
            break;
          case 'children':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChildrenListView()),
            );
            break;
          case 'collaborators':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CollaboratorSearchView(),
              ),
            );
            break;
          case 'experts':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExpertConnectView(),
              ),
            );
            break;
          case 'store':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoreView()),
            );
            break;
          case 'donation':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonationView()),
            );
            break;
          case 'interventions':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalsView()),
            );
            break;
          case 'intervention-domains':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DomainsView()),
            );
            break;
          case 'intervention-methods':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MethodGroupsView()),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đang chuyển đến ${category.title}...'),
                backgroundColor: AppColors.primary,
              ),
            );
            break;
        }
      },
      child: Container(
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
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(category.color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(category.icon),
                size: 32,
                color: Color(category.color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              category.subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'library_books':
        return Icons.library_books;
      case 'quiz':
        return Icons.quiz;
      case 'child_care':
        return Icons.child_care;
      case 'people':
        return Icons.people;
      case 'psychology':
        return Icons.psychology;
      case 'store':
        return Icons.store;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      default:
        return Icons.folder;
    }
  }
}

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 48, color: AppColors.white),
                const SizedBox(height: 12),
                Text(
                  'Hoạt Động Can Thiệp',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các bài tập và hoạt động hỗ trợ phát triển',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Activity Categories
          Text(
            'Danh Mục Hoạt Động',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildActivityCard(
            'Giao Tiếp',
            'Phát triển kỹ năng giao tiếp',
            Icons.chat,
          ),
          _buildActivityCard(
            'Vận Động',
            'Cải thiện khả năng vận động',
            Icons.directions_run,
          ),
          _buildActivityCard(
            'Nhận Thức',
            'Tăng cường nhận thức',
            Icons.psychology,
          ),
          _buildActivityCard(
            'Xã Hội',
            'Kỹ năng tương tác xã hội',
            Icons.people,
          ),
          _buildActivityCard('Cảm Xúc', 'Quản lý cảm xúc', Icons.favorite),
          _buildActivityCard('Tự Lập', 'Kỹ năng tự phục vụ', Icons.person),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.grey400, size: 16),
        ],
      ),
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.trending_up, size: 48, color: AppColors.white),
                const SizedBox(height: 12),
                Text(
                  'Theo Dõi Tiến Độ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biểu đồ và báo cáo tiến độ của trẻ',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress Overview
          Text(
            'Tổng Quan Tiến Độ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildProgressCard('Giao Tiếp', '75%', 0.75, Icons.chat),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  'Vận Động',
                  '60%',
                  0.60,
                  Icons.directions_run,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  'Nhận Thức',
                  '85%',
                  0.85,
                  Icons.psychology,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard('Xã Hội', '45%', 0.45, Icons.people),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activities
          Text(
            'Hoạt Động Gần Đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildActivityItem(
            'Hoàn thành bài tập giao tiếp',
            '2 giờ trước',
            Icons.check_circle,
          ),
          _buildActivityItem(
            'Làm bài test nhận thức',
            '1 ngày trước',
            Icons.quiz,
          ),
          _buildActivityItem(
            'Tham gia hoạt động nhóm',
            '2 ngày trước',
            Icons.group,
          ),
          _buildActivityItem(
            'Cập nhật hồ sơ tiến độ',
            '3 ngày trước',
            Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String percentage,
    double progress,
    IconData icon,
  ) {
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
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phụ huynh',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Profile Options
          Text(
            'Thông Tin Cá Nhân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildProfileOption('Thông tin cá nhân', Icons.person_outline),
          _buildProfileOption('Thay đổi mật khẩu', Icons.lock_outline),
          _buildProfileOption('Thông báo', Icons.notifications_outlined),
          _buildProfileOption('Bảo mật', Icons.security),

          const SizedBox(height: 24),

          Text(
            'Cài Đặt Ứng Dụng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildProfileOption('Ngôn ngữ', Icons.language),
          _buildProfileOption('Chủ đề', Icons.palette),
          _buildProfileOption('Đồng bộ dữ liệu', Icons.sync),
          _buildProfileOption('Xuất dữ liệu', Icons.download),

          const SizedBox(height: 24),

          Text(
            'Hỗ Trợ & Liên Hệ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildProfileOption('Trợ giúp', Icons.help_outline),
          _buildProfileOption('Liên hệ hỗ trợ', Icons.support_agent),
          _buildProfileOption('Đánh giá ứng dụng', Icons.star_outline),
          _buildProfileOption('Chính sách bảo mật', Icons.privacy_tip),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Đăng Xuất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.grey400, size: 16),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Đăng xuất'),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      // Clear user session
      await UserSession.clearSession();
      // Disconnect messaging socket on logout
      try {
        await MessagingService.instance.disconnect();
      } catch (_) {}

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đăng xuất thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate back to auth gate
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng xuất: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
