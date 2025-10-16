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

class MobileMainLayout extends StatefulWidget {
  const MobileMainLayout({super.key});

  @override
  State<MobileMainLayout> createState() => _MobileMainLayoutState();
}

class _MobileMainLayoutState extends State<MobileMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MobileHomePage(),
    const TestView(),
    const LibraryView(),
    const ChildrenListView(),
    const CollaboratorSearchView(),
    const SpecialistConnectView(),
    const InterventionProgramView(),
    const DomainsView(),
    const MethodGroupsView(),
    const StoreView(),
    const DonationView(),
    const MobileProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Trang Chủ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.quiz_outlined),
      activeIcon: Icon(Icons.quiz),
      label: 'Bài Test',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.library_books_outlined),
      activeIcon: Icon(Icons.library_books),
      label: 'Thư Viện',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.child_care_outlined),
      activeIcon: Icon(Icons.child_care),
      label: 'Danh Sách Trẻ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_outlined),
      activeIcon: Icon(Icons.people),
      label: 'Tìm Cộng Tác Viên',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.medical_services_outlined),
      activeIcon: Icon(Icons.medical_services),
      label: 'Kết Nối Chuyên Gia',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.healing_outlined),
      activeIcon: Icon(Icons.healing),
      label: 'Chương Trình Can Thiệp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      activeIcon: Icon(Icons.category),
      label: 'Lĩnh Vực Can Thiệp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.group_work_outlined),
      activeIcon: Icon(Icons.group_work),
      label: 'Nhóm Phương Pháp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.store_outlined),
      activeIcon: Icon(Icons.store),
      label: 'Cửa Hàng',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.volunteer_activism_outlined),
      activeIcon: Icon(Icons.volunteer_activism),
      label: 'Đóng Góp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Hồ Sơ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FABUtility.buildSmartFAB(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: _bottomNavItems,
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Trang Chủ';
      case 1:
        return 'Bài Test';
      case 2:
        return 'Thư Viện';
      case 3:
        return 'Danh Sách Trẻ';
      case 4:
        return 'Tìm Cộng Tác Viên';
      case 5:
        return 'Kết Nối Chuyên Gia';
      case 6:
        return 'Chương Trình Can Thiệp';
      case 7:
        return 'Lĩnh Vực Can Thiệp';
      case 8:
        return 'Nhóm Phương Pháp';
      case 9:
        return 'Cửa Hàng';
      case 10:
        return 'Đóng Góp';
      case 11:
        return 'Hồ Sơ';
      default:
        return 'The Happiness Journey';
    }
  }

}

// Mobile Home Page
class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hôm nay bạn muốn làm gì?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat('Trẻ theo dõi', '12', Icons.child_care),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStat('Tiến độ', '78%', Icons.trending_up),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Tính năng nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildQuickActionCard(
                'Đánh giá phát triển',
                Icons.assessment,
                AppColors.primary,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 1; // Chuyển đến tab Bài Test
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Bài Test',
                Icons.quiz,
                Colors.purple,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 1; // Chuyển đến tab Bài Test
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Thư viện tài liệu',
                Icons.library_books,
                Colors.blue,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 2; // Chuyển đến tab Thư viện
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Danh sách trẻ',
                Icons.child_care,
                Colors.green,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 3; // Chuyển đến tab Danh sách trẻ
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Tìm cộng tác viên',
                Icons.people,
                Colors.orange,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 4; // Chuyển đến tab Tìm cộng tác viên
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Kết nối chuyên gia',
                Icons.medical_services,
                Colors.red,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 5; // Chuyển đến tab Kết nối chuyên gia
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Cửa hàng',
                Icons.store,
                Colors.indigo,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 9; // Chuyển đến tab Cửa hàng
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Chương trình can thiệp',
                Icons.healing,
                Colors.pink,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 6; // Chuyển đến tab Chương trình can thiệp
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Lĩnh vực can thiệp',
                Icons.category,
                Colors.deepPurple,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 7; // Chuyển đến tab Lĩnh vực can thiệp
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Nhóm phương pháp',
                Icons.group_work,
                Colors.brown,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 8; // Chuyển đến tab Nhóm phương pháp
                    });
                  }
                },
              ),
              _buildQuickActionCard(
                'Đóng góp',
                Icons.volunteer_activism,
                Colors.teal,
                () {
                  // Tìm parent MobileMainLayout và chuyển tab
                  final parent = context.findAncestorStateOfType<_MobileMainLayoutState>();
                  if (parent != null) {
                    parent.setState(() {
                      parent._currentIndex = 10; // Chuyển đến tab Đóng góp
                    });
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(3, (index) => _buildActivityItem(
            'Bài tập hoàn thành',
            '2 giờ trước',
            Icons.check_circle,
            Colors.green,
          )),
        ],
      ),
    );
  }
  
  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
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
  
  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

// Mobile Profile Page
class MobileProfilePage extends StatelessWidget {
  const MobileProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Người dùng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat('Trẻ theo dõi', '12'),
                    _buildProfileStat('Bài tập', '45'),
                    _buildProfileStat('Tiến độ', '78%'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu Items
          _buildMenuItem('Thông tin cá nhân', Icons.person_outline, () {}),
          _buildMenuItem('Cài đặt', Icons.settings_outlined, () {}),
          _buildMenuItem('Thông báo', Icons.notifications_outlined, () {}),
          _buildMenuItem('Trợ giúp', Icons.help_outline, () {}),
          _buildMenuItem('Về ứng dụng', Icons.info_outline, () {}),
          
          const SizedBox(height: 24),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đăng xuất'),
            ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
