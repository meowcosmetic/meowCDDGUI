import 'package:flutter/material.dart';
import '../uiElement/button_demo.dart';
import '../uiElement/card_demo.dart';
import '../uiElement/form_demo.dart';
import '../uiElement/navigation_demo.dart';
import '../uiElement/loading_demo.dart';
import '../uiElement/alert_demo.dart';
import '../uiElement/pagination_demo.dart';
import '../uiElement/heading_demo.dart';
import '../view/policy_view.dart';
import '../view/test_view.dart';
import '../constants/app_colors.dart';


class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Bài Test',
      icon: Icons.quiz,
      page: const TestView(),
    ),
    NavigationItem(
      title: 'Chính Sách',
      icon: Icons.security,
      page: const PolicyView(),
    ),
    NavigationItem(
      title: 'Buttons',
      icon: Icons.smart_button,
      page: const ButtonDemoWrapper(),
    ),
    NavigationItem(
      title: 'Cards',
      icon: Icons.credit_card,
      page: const CardDemoWrapper(),
    ),
    NavigationItem(
      title: 'Forms',
      icon: Icons.article,
      page: const FormDemoWrapper(),
    ),
    NavigationItem(
      title: 'Navigation',
      icon: Icons.navigation,
      page: const NavigationDemoWrapper(),
    ),
    NavigationItem(
      title: 'Loading',
      icon: Icons.hourglass_empty,
      page: const LoadingDemoWrapper(),
    ),
    NavigationItem(
      title: 'Alerts',
      icon: Icons.warning_amber_outlined,
      page: const AlertDemoWrapper(),
    ),
    NavigationItem(
      title: 'Pagination',
      icon: Icons.pages,
      page: const PaginationDemoWrapper(),
    ),
    NavigationItem(
      title: 'Headings',
      icon: Icons.text_fields,
      page: const HeadingDemoWrapper(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navigationItems[_currentIndex].title),
        backgroundColor: AppColors.cardBorder,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.cardBorder,
        unselectedItemColor: AppColors.grey600,
        backgroundColor: AppColors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.psychology,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hỗ Trợ Trẻ Tự Kỷ',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ứng dụng can thiệp tại nhà',
                  style: TextStyle(
                    color: AppColors.grey300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: _currentIndex == index ? AppColors.cardBorder : AppColors.grey600,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: _currentIndex == index ? AppColors.cardBorder : AppColors.grey800,
                      ),
                    ),
                    selected: _currentIndex == index,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(index);
                    },
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSettingsDialog();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The Happiness Journey'),
            SizedBox(height: 8),
            Text('A comprehensive UI component library built with Flutter.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Button System'),
            Text('• Card System'),
            Text('• Dynamic Form System'),
            Text('• Navigation System'),
            Text('• Loading System'),
            Text('• Alert System'),
            Text('• Pagination System'),
            Text('• Heading System'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings will be implemented here.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget page;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}

// Wrapper classes to remove AppBar from demo pages
class ButtonDemoWrapper extends StatelessWidget {
  const ButtonDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ButtonDemo(showAppBar: false);
  }
}

class CardDemoWrapper extends StatelessWidget {
  const CardDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const CardDemo(showAppBar: false);
  }
}

class FormDemoWrapper extends StatelessWidget {
  const FormDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const FormDemo(showAppBar: false);
  }
}

class NavigationDemoWrapper extends StatelessWidget {
  const NavigationDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationDemo(showAppBar: false);
  }
}

class LoadingDemoWrapper extends StatelessWidget {
  const LoadingDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingDemo(showAppBar: false);
  }
}

class AlertDemoWrapper extends StatelessWidget {
  const AlertDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDemo(showAppBar: false);
  }
}

class PaginationDemoWrapper extends StatelessWidget {
  const PaginationDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaginationDemo(showAppBar: false);
  }
}

class HeadingDemoWrapper extends StatelessWidget {
  const HeadingDemoWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HeadingDemo(showAppBar: false);
  }
} 
