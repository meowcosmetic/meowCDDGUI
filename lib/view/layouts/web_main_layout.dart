import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../constants/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../../uiElement/fab_utility.dart';
import '../store_view.dart';
import '../donation_view.dart';
import '../policy_view.dart';
import '../../features/library_management/library_view.dart';
import '../../features/cdd_test_management/views/test_view.dart';
import '../children_list_view.dart';
import '../collaborator_search_view.dart';
import '../specialist_connect_view.dart';
import '../../features/intervention_goals/views/intervention_program_view.dart';
import '../../features/intervention_domains/views/domains_view.dart';
import '../../features/intervention_methods/views/method_groups_view.dart';
import '../../features/intervention_methods/views/methods_view.dart';
import '../../features/intervention_methods/models/method_group_models.dart';
import '../../features/intervention_domains/models/domain_item_models.dart' as di;
import '../../features/intervention_goals/views/criteria_list_view.dart';
import '../../features/intervention_goals/views/program_criteria_view.dart';
import '../../models/user_session.dart';
import '../auth_gate.dart';
import '../../models/api_service.dart';
import '../../models/user.dart';
import '../../features/child_management/views/child_detail_view.dart';
import '../../models/child.dart';
import '../../features/cdd_test_management/views/test_detail_view.dart';
import '../../features/cdd_test_management/views/test_taking_page.dart';
import '../../models/library_item.dart';
import '../../models/intervention_post.dart';
import '../../features/library_management/pages/post_detail_page.dart';
import '../../features/library_management/library_view.dart' as lib_view;

class WebMainLayout extends StatefulWidget {
  const WebMainLayout({super.key});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  
  // Navigation stack for child detail views
  Child? _selectedChild;
  bool _showingChildDetail = false;
  
  // Navigation for test detail
  String? _selectedTestId;
  String? _selectedTestTitle;
  bool _showingTestDetail = false;
  
  // Navigation for test taking
  dynamic _testForTaking; // Test object for taking
  Child? _childForTest; // Child taking the test
  bool _showingTestTaking = false;
  
  // Navigation for library items
  LibraryItem? _selectedLibraryItem;
  InterventionPost? _selectedPost;
  bool _showingLibraryDetail = false;
  
  // Navigation for intervention methods
  InterventionMethodGroupModel? _selectedMethodGroup;
  bool _showingMethodDetail = false;
  
  // Navigation for intervention program (multi-level)
  Map<String, dynamic>? _selectedProgram;
  String? _selectedProgramId;
  String? _selectedProgramName;
  di.DevelopmentalDomainItemModel? _selectedLargeGoal;
  String? _selectedLargeGoalId;
  String? _selectedLargeGoalName;
  bool _showingProgramDetail = false; // Level 2: Program's large goals
  bool _showingLargeGoalDetail = false; // Level 3: Large goal's small criteria
  
  // Current view type
  String _currentDetailType = ''; // 'child', 'test', 'test_taking', 'library_item', 'library_post', 'method', 'program', 'large_goal'
  
  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }
  
  void showChildDetail(Child child) {
    setState(() {
      _selectedChild = child;
      _showingChildDetail = true;
      _currentDetailType = 'child';
      // Hide other details
      _showingTestDetail = false;
    });
  }
  
  void showTestDetail(String testId, String testTitle) {
    setState(() {
      _selectedTestId = testId;
      _selectedTestTitle = testTitle;
      _showingTestDetail = true;
      _currentDetailType = 'test';
      // Hide other details
      _showingChildDetail = false;
      _showingLibraryDetail = false;
      _showingTestTaking = false;
    });
  }
  
  void showTestTaking(dynamic test, {Child? child}) {
    setState(() {
      _testForTaking = test;
      _childForTest = child;
      _showingTestTaking = true;
      _currentDetailType = 'test_taking';
      // Keep test detail info for breadcrumb
      // Other details remain hidden
    });
  }
  
  void backToTestDetail() {
    setState(() {
      _testForTaking = null;
      _childForTest = null;
      _showingTestTaking = false;
      _currentDetailType = 'test';
      // Go back to test detail, which should still have _selectedTestId and _selectedTestTitle
    });
  }
  
  void showLibraryItem(LibraryItem item) {
    setState(() {
      _selectedLibraryItem = item;
      _selectedPost = null;
      _showingLibraryDetail = true;
      _currentDetailType = 'library_item';
      // Hide other details
      _showingChildDetail = false;
      _showingTestDetail = false;
    });
  }
  
  void showLibraryPost(InterventionPost post) {
    setState(() {
      _selectedPost = post;
      _selectedLibraryItem = null;
      _showingLibraryDetail = true;
      _currentDetailType = 'library_post';
      // Hide other details
      _showingChildDetail = false;
      _showingTestDetail = false;
    });
  }
  
  void showMethodDetail(InterventionMethodGroupModel methodGroup) {
    setState(() {
      _selectedMethodGroup = methodGroup;
      _showingMethodDetail = true;
      _currentDetailType = 'method';
      // Hide other details
      _showingChildDetail = false;
      _showingTestDetail = false;
      _showingLibraryDetail = false;
    });
  }
  
  void showProgramDetail(Map<String, dynamic> program) {
    setState(() {
      _selectedProgram = program;
      _selectedProgramId = (program['id'] ?? '').toString();
      _selectedProgramName = (program['name'] ?? program['title'] ?? 'Chương trình').toString();
      _showingProgramDetail = true;
      _showingLargeGoalDetail = false;
      _currentDetailType = 'program';
      // Hide other details
      _showingChildDetail = false;
      _showingTestDetail = false;
      _showingLibraryDetail = false;
      _showingMethodDetail = false;
    });
  }
  
  void showLargeGoalDetail(di.DevelopmentalDomainItemModel largeGoal) {
    setState(() {
      _selectedLargeGoal = largeGoal;
      _selectedLargeGoalId = largeGoal.id;
      _selectedLargeGoalName = largeGoal.title?.vi ?? largeGoal.title?.en ?? largeGoal.name ?? 'Mục tiêu lớn';
      _showingLargeGoalDetail = true;
      _currentDetailType = 'large_goal';
      // Keep program detail visible in breadcrumb
      // Don't hide _showingProgramDetail
    });
  }
  
  void backToProgramDetail() {
    setState(() {
      _selectedLargeGoal = null;
      _selectedLargeGoalId = null;
      _selectedLargeGoalName = null;
      _showingLargeGoalDetail = false;
      _currentDetailType = 'program';
    });
  }
  
  void hideDetail() {
    setState(() {
      _selectedChild = null;
      _showingChildDetail = false;
      _selectedTestId = null;
      _selectedTestTitle = null;
      _showingTestDetail = false;
      _testForTaking = null;
      _childForTest = null;
      _showingTestTaking = false;
      _selectedLibraryItem = null;
      _selectedPost = null;
      _showingLibraryDetail = false;
      _selectedMethodGroup = null;
      _showingMethodDetail = false;
      _selectedProgram = null;
      _selectedProgramId = null;
      _selectedProgramName = null;
      _selectedLargeGoal = null;
      _selectedLargeGoalId = null;
      _selectedLargeGoalName = null;
      _showingProgramDetail = false;
      _showingLargeGoalDetail = false;
      _currentDetailType = '';
    });
  }
  
  // Backward compatibility
  void hideChildDetail() => hideDetail();
  
  String _getBreadcrumbDetailText() {
    switch (_currentDetailType) {
      case 'child':
        return 'Chi tiết: ${_selectedChild?.name ?? ""}';
      case 'test':
        return _selectedTestTitle ?? '';
      case 'library_item':
        return _selectedLibraryItem?.title ?? 'Chi tiết tài liệu';
      case 'library_post':
        return _selectedPost?.title ?? 'Chi tiết bài viết';
      case 'method':
        return _selectedMethodGroup?.displayedName.vi ?? _selectedMethodGroup?.displayedName.en ?? 'Chi tiết phương pháp';
      case 'program':
        return _selectedProgramName ?? 'Chương trình';
      case 'large_goal':
        return _selectedLargeGoalName ?? 'Mục tiêu lớn';
      default:
        return '';
    }
  }
  
  Widget _buildCurrentView() {
    // Show child detail
    if (_showingChildDetail && _selectedChild != null) {
      return ChildDetailView(child: _selectedChild!);
    }
    
    // Show test taking page
    if (_showingTestTaking && _testForTaking != null) {
      return TestTakingPage(
        test: _testForTaking,
        child: _childForTest,
      );
    }
    
    // Show test detail
    if (_showingTestDetail && _selectedTestId != null) {
      return _WebLayoutTestDetailWrapper(
        testId: _selectedTestId!,
        testTitle: _selectedTestTitle ?? '',
        onTestStart: showTestTaking,
      );
    }
    
    // Show library item detail (PDF/Book)
    if (_showingLibraryDetail && _selectedLibraryItem != null) {
      return lib_view.ItemReaderPage(
        item: _selectedLibraryItem!,
        showScaffold: false,
      );
    }
    
    // Show library post detail (Article)
    if (_showingLibraryDetail && _selectedPost != null) {
      return PostDetailPage(post: _selectedPost!);
    }
    
    // Show method detail
    if (_showingMethodDetail && _selectedMethodGroup != null) {
      return MethodsView(methodGroup: _selectedMethodGroup!);
    }
    
    // Show large goal detail (level 3: small criteria)
    if (_showingLargeGoalDetail && _selectedLargeGoal != null) {
      return CriteriaListView(
        domainItemId: _selectedLargeGoalId!,
        domainItemTitle: _selectedLargeGoalName!,
      );
    }
    
    // Show program detail (level 2: large goals)
    if (_showingProgramDetail && _selectedProgram != null) {
      return _WebLayoutProgramWrapper(
        child: ProgramCriteriaView(
          programId: int.parse(_selectedProgramId!),
          programData: _selectedProgram!,
        ),
        onLargeGoalSelected: showLargeGoalDetail,
      );
    }
    
    // Show default page with navigation provider
    return _WebLayoutPageWrapper(
      child: _navigationItems[_selectedIndex].page,
      onChildSelected: showChildDetail,
      onTestSelected: showTestDetail,
      onLibraryItemSelected: showLibraryItem,
      onLibraryPostSelected: showLibraryPost,
      onMethodSelected: showMethodDetail,
      onProgramSelected: showProgramDetail,
    );
  }
  
  Future<void> _loadUserSession() async {
    await UserSession.initFromPrefs();
    
    // Load user profile if not already loaded and user is logged in
    if (UserSession.userId != null && UserSession.currentUserProfile == null && !UserSession.isGuest) {
      try {
        final api = ApiService();
        final response = await api.getUserProfile(UserSession.userId!);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final userData = jsonDecode(response.body);
          final user = User.fromJson(userData);
          await UserSession.updateUserProfile(user);
        }
      } catch (e) {
        // Handle error silently
        print('Error loading user profile: $e');
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Trang Chủ',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      page: const WebHomePage(),
    ),
    NavigationItem(
      title: 'Bài Test',
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      page: const TestView(),
    ),
    NavigationItem(
      title: 'Thư Viện',
      icon: Icons.library_books_outlined,
      activeIcon: Icons.library_books,
      page: const LibraryView(),
    ),
    NavigationItem(
      title: 'Danh Sách Trẻ',
      icon: Icons.child_care_outlined,
      activeIcon: Icons.child_care,
      page: const ChildrenListView(),
    ),
    NavigationItem(
      title: 'Tìm Cộng Tác Viên',
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      page: const CollaboratorSearchView(),
    ),
    NavigationItem(
      title: 'Kết Nối Chuyên Gia',
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services,
      page: const SpecialistConnectView(),
    ),
    NavigationItem(
      title: 'Chương Trình Can Thiệp',
      icon: Icons.healing_outlined,
      activeIcon: Icons.healing,
      page: const InterventionProgramView(),
    ),
    NavigationItem(
      title: 'Lĩnh Vực Can Thiệp',
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      page: const DomainsView(),
    ),
    NavigationItem(
      title: 'Nhóm Phương Pháp',
      icon: Icons.group_work_outlined,
      activeIcon: Icons.group_work,
      page: const MethodGroupsView(),
    ),
    NavigationItem(
      title: 'Cửa Hàng',
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
      page: const StoreView(),
    ),
    NavigationItem(
      title: 'Đóng Góp',
      icon: Icons.volunteer_activism_outlined,
      activeIcon: Icons.volunteer_activism,
      page: const DonationView(),
    ),
    NavigationItem(
      title: 'Hồ Sơ',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      page: const WebProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FABUtility.buildSmartFAB(context),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarExpanded ? 280 : 80,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: 80,
                  padding: _isSidebarExpanded 
                    ? const EdgeInsets.all(16) 
                    : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: _isSidebarExpanded 
                    ? Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'lib/asset/new_logo_white_background.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'The Happiness Journey',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isSidebarExpanded = !_isSidebarExpanded;
                              });
                            },
                            icon: Icon(
                              Icons.chevron_left,
                              color: AppColors.white,
                              size: 20,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'lib/asset/new_logo_white_background.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isSidebarExpanded = !_isSidebarExpanded;
                              });
                            },
                            icon: Icon(
                              Icons.chevron_right,
                              color: AppColors.white,
                              size: 18,
                            ),
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ) : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                  if (_isSidebarExpanded) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer
                if (_isSidebarExpanded)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
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
                                    UserSession.isGuest 
                                      ? 'Khách' 
                                      : UserSession.currentUserProfile?.name ?? 'Người dùng',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    UserSession.isGuest 
                                      ? 'Chế độ khách' 
                                      : UserSession.currentUserProfile?.email ?? UserSession.userId ?? 'Chưa đăng nhập',
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
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Breadcrumb navigation
                      if (_currentDetailType.isNotEmpty)
                        Row(
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 20),
                              onPressed: _currentDetailType == 'test_taking' 
                                ? backToTestDetail 
                                : _currentDetailType == 'large_goal'
                                  ? backToProgramDetail
                                  : hideDetail,
                              tooltip: 'Quay lại',
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 8),
                            // Breadcrumb - Parent page
                            InkWell(
                              onTap: hideDetail,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  _navigationItems[_selectedIndex].title,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            // Middle breadcrumbs (for multi-level navigation)
                            if (_currentDetailType == 'test_taking') ...[
                              InkWell(
                                onTap: backToTestDetail,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    _selectedTestTitle ?? 'Bài test',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Làm bài',
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ] else if (_currentDetailType == 'large_goal') ...[
                              // Program breadcrumb (level 2)
                              InkWell(
                                onTap: backToProgramDetail,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    _selectedProgramName ?? 'Chương trình',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              // Large goal breadcrumb (level 3)
                              Text(
                                _selectedLargeGoalName ?? 'Mục tiêu lớn',
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ] else
                              // Current detail (for single-level navigation)
                              Text(
                                _getBreadcrumbDetailText(),
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                          ],
                        )
                      else
                        Text(
                          _navigationItems[_selectedIndex].title,
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notifications
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Profile
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.person, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildCurrentView(),
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
}

class NavigationItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}

// Web Home Page
class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ứng dụng hỗ trợ toàn diện cho trẻ tự kỷ và gia đình',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatCard('Trẻ đang theo dõi', '12', Icons.child_care),
                    const SizedBox(width: 16),
                    _buildStatCard('Bài tập hoàn thành', '45', Icons.assignment_turned_in),
                    const SizedBox(width: 16),
                    _buildStatCard('Tiến độ tuần này', '78%', Icons.trending_up),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          Text(
            'Tính năng chính',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                'Đánh giá phát triển',
                Icons.assessment,
                AppColors.primary,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 1; // Chuyển đến tab Bài Test
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Bài Test',
                Icons.quiz,
                Colors.purple,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 1; // Chuyển đến tab Bài Test
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Thư viện tài liệu',
                Icons.library_books,
                Colors.blue,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 2; // Chuyển đến tab Thư viện
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Danh sách trẻ',
                Icons.child_care,
                Colors.green,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 3; // Chuyển đến tab Danh sách trẻ
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Tìm cộng tác viên',
                Icons.people,
                Colors.orange,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 4; // Chuyển đến tab Tìm cộng tác viên
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Kết nối chuyên gia',
                Icons.medical_services,
                Colors.red,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 5; // Chuyển đến tab Kết nối chuyên gia
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Cửa hàng',
                Icons.store,
                Colors.indigo,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 9; // Chuyển đến tab Cửa hàng
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Chương trình can thiệp',
                Icons.healing,
                Colors.pink,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 6; // Chuyển đến tab Chương trình can thiệp
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Lĩnh vực can thiệp',
                Icons.category,
                Colors.deepPurple,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 7; // Chuyển đến tab Lĩnh vực can thiệp
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Nhóm phương pháp',
                Icons.group_work,
                Colors.brown,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 8; // Chuyển đến tab Nhóm phương pháp
                    });
                  }
                },
              ),
              _buildFeatureCard(
                'Đóng góp',
                Icons.volunteer_activism,
                Colors.teal,
                () {
                  // Tìm parent WebMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_WebMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._selectedIndex = 10; // Chuyển đến tab Đóng góp
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Web Profile Page
class WebProfilePage extends StatefulWidget {
  const WebProfilePage({super.key});

  @override
  State<WebProfilePage> createState() => _WebProfilePageState();
}

class _WebProfilePageState extends State<WebProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }
  
  Future<void> _loadUserSession() async {
    await UserSession.initFromPrefs();
    
    // Load user profile if not already loaded and user is logged in
    if (UserSession.userId != null && UserSession.currentUserProfile == null && !UserSession.isGuest) {
      try {
        final api = ApiService();
        final response = await api.getUserProfile(UserSession.userId!);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final userData = jsonDecode(response.body);
          final user = User.fromJson(userData);
          await UserSession.updateUserProfile(user);
        }
      } catch (e) {
        // Handle error silently
        print('Error loading user profile: $e');
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _logout() async {
    await UserSession.clearSession();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  UserSession.isGuest 
                    ? 'Khách' 
                    : UserSession.currentUserProfile?.name ?? 'Người dùng',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  UserSession.isGuest 
                    ? 'Chế độ khách' 
                    : UserSession.currentUserProfile?.email ?? UserSession.userId ?? 'Chưa đăng nhập',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileStat('Trẻ theo dõi', '12'),
                    const SizedBox(width: 32),
                    _buildProfileStat('Bài tập', '45'),
                    const SizedBox(width: 32),
                    _buildProfileStat('Tiến độ', '78%'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Settings Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5,
            children: [
              _buildSettingsCard('Thông tin cá nhân', Icons.person_outline, () {
                _showPersonalInfoDialog();
              }),
              _buildSettingsCard('Cài đặt', Icons.settings_outlined, () {
                _showSettingsDialog();
              }),
              _buildSettingsCard('Thông báo', Icons.notifications_outlined, () {
                _showNotificationsDialog();
              }),
              _buildSettingsCard('Trợ giúp', Icons.help_outline, () {
                _showHelpDialog();
              }),
              _buildSettingsCard('Về ứng dụng', Icons.info_outline, () {
                _showAboutDialog();
              }),
              _buildSettingsCard('Đăng xuất', Icons.logout, () {
                _showLogoutDialog();
              }, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsCard(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isDestructive ? Colors.red : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin cá nhân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (UserSession.currentUserProfile != null) ...[
              Text('Tên: ${UserSession.currentUserProfile!.name}'),
              const SizedBox(height: 8),
              Text('Email: ${UserSession.currentUserProfile!.email}'),
              const SizedBox(height: 8),
              Text('Số điện thoại: ${UserSession.currentUserProfile!.phone}'),
              const SizedBox(height: 8),
              Text('Giới tính: ${UserSession.currentUserProfile!.sex}'),
              const SizedBox(height: 8),
              Text('Năm sinh: ${UserSession.currentUserProfile!.yearOfBirth}'),
              const SizedBox(height: 8),
              Text('ID người dùng: ${UserSession.currentUserProfile!.customerId}'),
            ] else ...[
              Text('ID người dùng: ${UserSession.userId ?? 'Chưa có'}'),
              const SizedBox(height: 8),
              Text('Trạng thái: ${UserSession.isGuest ? 'Khách' : 'Đã đăng nhập'}'),
              const SizedBox(height: 8),
              Text('Token: ${UserSession.jwtToken != null ? 'Có' : 'Không có'}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt'),
        content: const Text('Tính năng cài đặt sẽ được phát triển trong tương lai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Tính năng thông báo sẽ được phát triển trong tương lai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trợ giúp'),
        content: const Text('Nếu bạn cần hỗ trợ, vui lòng liên hệ với đội ngũ phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: const Text('The Happiness Journey - Ứng dụng hỗ trợ toàn diện cho trẻ tự kỷ và gia đình.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Wrapper widget to provide navigation context to child pages
class _WebLayoutPageWrapper extends StatelessWidget {
  final Widget child;
  final Function(Child) onChildSelected;
  final Function(String testId, String testTitle) onTestSelected;
  final Function(LibraryItem) onLibraryItemSelected;
  final Function(InterventionPost) onLibraryPostSelected;
  final Function(InterventionMethodGroupModel) onMethodSelected;
  final Function(Map<String, dynamic>) onProgramSelected;

  const _WebLayoutPageWrapper({
    required this.child,
    required this.onChildSelected,
    required this.onTestSelected,
    required this.onLibraryItemSelected,
    required this.onLibraryPostSelected,
    required this.onMethodSelected,
    required this.onProgramSelected,
  });

  @override
  Widget build(BuildContext context) {
    return WebLayoutNavigationProvider(
      onChildSelected: onChildSelected,
      onTestSelected: onTestSelected,
      onLibraryItemSelected: onLibraryItemSelected,
      onLibraryPostSelected: onLibraryPostSelected,
      onMethodSelected: onMethodSelected,
      onProgramSelected: onProgramSelected,
      child: child,
    );
  }
}

// InheritedWidget to pass navigation callbacks down the tree
class WebLayoutNavigationProvider extends InheritedWidget {
  final Function(Child) onChildSelected;
  final Function(String testId, String testTitle) onTestSelected;
  final Function(LibraryItem) onLibraryItemSelected;
  final Function(InterventionPost) onLibraryPostSelected;
  final Function(InterventionMethodGroupModel) onMethodSelected;
  final Function(Map<String, dynamic>) onProgramSelected;

  const WebLayoutNavigationProvider({
    required this.onChildSelected,
    required this.onTestSelected,
    required this.onLibraryItemSelected,
    required this.onLibraryPostSelected,
    required this.onMethodSelected,
    required this.onProgramSelected,
    required super.child,
  });

  static WebLayoutNavigationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WebLayoutNavigationProvider>();
  }

  @override
  bool updateShouldNotify(WebLayoutNavigationProvider oldWidget) {
    return onChildSelected != oldWidget.onChildSelected ||
           onTestSelected != oldWidget.onTestSelected ||
           onLibraryItemSelected != oldWidget.onLibraryItemSelected ||
           onLibraryPostSelected != oldWidget.onLibraryPostSelected ||
           onMethodSelected != oldWidget.onMethodSelected ||
           onProgramSelected != oldWidget.onProgramSelected;
  }
}

// Wrapper for TestDetailView to intercept test start action
class _WebLayoutTestDetailWrapper extends StatelessWidget {
  final String testId;
  final String testTitle;
  final Function(dynamic test, {Child? child}) onTestStart;

  const _WebLayoutTestDetailWrapper({
    required this.testId,
    required this.testTitle,
    required this.onTestStart,
  });

  @override
  Widget build(BuildContext context) {
    return WebLayoutTestDetailProvider(
      onTestStart: onTestStart,
      child: TestDetailView(
        testId: testId,
        testTitle: testTitle,
      ),
    );
  }
}

// Provider to pass test start callback to TestDetailView
class WebLayoutTestDetailProvider extends InheritedWidget {
  final Function(dynamic test, {Child? child}) onTestStart;

  const WebLayoutTestDetailProvider({
    required this.onTestStart,
    required super.child,
  });

  static WebLayoutTestDetailProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WebLayoutTestDetailProvider>();
  }

  @override
  bool updateShouldNotify(WebLayoutTestDetailProvider oldWidget) {
    return onTestStart != oldWidget.onTestStart;
  }
}

// Wrapper for Program detail view to intercept large goal selection
class _WebLayoutProgramWrapper extends StatelessWidget {
  final Widget child;
  final Function(di.DevelopmentalDomainItemModel) onLargeGoalSelected;

  const _WebLayoutProgramWrapper({
    required this.child,
    required this.onLargeGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    return WebLayoutProgramNavigationProvider(
      onLargeGoalSelected: onLargeGoalSelected,
      child: child,
    );
  }
}

// InheritedWidget to pass large goal selection callback to ProgramCriteriaView
class WebLayoutProgramNavigationProvider extends InheritedWidget {
  final Function(di.DevelopmentalDomainItemModel) onLargeGoalSelected;

  const WebLayoutProgramNavigationProvider({
    required this.onLargeGoalSelected,
    required super.child,
  });

  static WebLayoutProgramNavigationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WebLayoutProgramNavigationProvider>();
  }

  @override
  bool updateShouldNotify(WebLayoutProgramNavigationProvider oldWidget) {
    return onLargeGoalSelected != oldWidget.onLargeGoalSelected;
  }
}
