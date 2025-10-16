import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class WebMainLayout extends StatefulWidget {
  const WebMainLayout({super.key});

  @override
  State<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends State<WebMainLayout> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

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
                                    'Người dùng',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'user@example.com',
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
                      child: _navigationItems[_selectedIndex].page,
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
class WebProfilePage extends StatelessWidget {
  const WebProfilePage({super.key});

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
                  'Người dùng',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'user@example.com',
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
              _buildSettingsCard('Thông tin cá nhân', Icons.person_outline, () {}),
              _buildSettingsCard('Cài đặt', Icons.settings_outlined, () {}),
              _buildSettingsCard('Thông báo', Icons.notifications_outlined, () {}),
              _buildSettingsCard('Trợ giúp', Icons.help_outline, () {}),
              _buildSettingsCard('Về ứng dụng', Icons.info_outline, () {}),
              _buildSettingsCard('Đăng xuất', Icons.logout, () {}, isDestructive: true),
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
}
