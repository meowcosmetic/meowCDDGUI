import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'navigation_menu.dart';

class NavigationDemo extends StatefulWidget {
  final bool showAppBar;
  
  const NavigationDemo({super.key, this.showAppBar = true});

  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Navigation Menu Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Default Navigation Menu'),
            _buildDefaultMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Outlined Navigation Menu'),
            _buildOutlinedMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Filled Navigation Menu'),
            _buildFilledMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Minimal Navigation Menu'),
            _buildMinimalMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Vertical Navigation Menu'),
            _buildVerticalMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Navigation Menu with Submenu'),
            _buildMenuWithSubmenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Custom Styled Navigation Menu'),
            _buildCustomStyledMenu(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Different Sizes'),
            _buildDifferentSizes(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Interactive Demo'),
            _buildInteractiveDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDefaultMenu() {
    final items = [
      MenuItem(label: 'Dashboard', icon: Icons.dashboard, isActive: _selectedIndex == 0),
      MenuItem(label: 'Analytics', icon: Icons.analytics, isActive: _selectedIndex == 1),
      MenuItem(label: 'Settings', icon: Icons.settings, isActive: _selectedIndex == 2),
    ];

    return NavigationMenu(
      items: items,
      onItemSelected: (index) => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildOutlinedMenu() {
    final items = [
      MenuItem(label: 'Home', icon: Icons.home),
      MenuItem(label: 'Profile', icon: Icons.person),
      MenuItem(label: 'Messages', icon: Icons.message),
    ];

    return OutlinedNavigationMenu(
      items: items,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildFilledMenu() {
    final items = [
      MenuItem(label: 'Products', icon: Icons.shopping_bag),
      MenuItem(label: 'Orders', icon: Icons.shopping_cart),
      MenuItem(label: 'Customers', icon: Icons.people),
    ];

    return FilledNavigationMenu(
      items: items,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildMinimalMenu() {
    final items = [
      MenuItem(label: 'Overview', icon: Icons.dashboard),
      MenuItem(label: 'Reports', icon: Icons.assessment),
      MenuItem(label: 'Tools', icon: Icons.build),
    ];

    return MinimalNavigationMenu(
      items: items,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildVerticalMenu() {
    final items = [
      MenuItem(label: 'Dashboard', icon: Icons.dashboard),
      MenuItem(label: 'Analytics', icon: Icons.analytics),
      MenuItem(label: 'Settings', icon: Icons.settings),
    ];

    return NavigationMenu(
      items: items,
      orientation: MenuOrientation.vertical,
      expandable: true,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildMenuWithSubmenu() {
    final items = [
      MenuItem(
        label: 'Products',
        icon: Icons.shopping_bag,
        children: [
          MenuItem(label: 'All Products'),
          MenuItem(label: 'Categories'),
          MenuItem(label: 'Stock'),
        ],
      ),
      MenuItem(
        label: 'Sales',
        icon: Icons.trending_up,
        children: [
          MenuItem(label: 'Overview'),
          MenuItem(label: 'Reports'),
          MenuItem(label: 'Analytics'),
        ],
      ),
      MenuItem(label: 'Settings', icon: Icons.settings),
    ];

    return NavigationMenu(
      items: items,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildCustomStyledMenu() {
    final items = [
      MenuItem(label: 'Home', icon: Icons.home),
      MenuItem(label: 'About', icon: Icons.info),
      MenuItem(label: 'Contact', icon: Icons.contact_support),
    ];

    return NavigationMenu(
      items: items,
      activeColor: AppColors.secondary,
      inactiveColor: AppColors.textSecondary,
      backgroundColor: AppColors.surfaceVariant,
      borderRadius: 12,
      onItemSelected: (index) => debugPrint('Selected: $index'),
    );
  }

  Widget _buildDifferentSizes() {
    final items = [
      MenuItem(label: 'Small', icon: Icons.star),
      MenuItem(label: 'Medium', icon: Icons.star),
      MenuItem(label: 'Large', icon: Icons.star),
    ];

    return Column(
      children: [
        NavigationMenu(
          items: items,
          size: MenuSize.small,
          onItemSelected: (index) => debugPrint('Small selected: $index'),
        ),
        const SizedBox(height: 16),
        NavigationMenu(
          items: items,
          size: MenuSize.medium,
          onItemSelected: (index) => debugPrint('Medium selected: $index'),
        ),
        const SizedBox(height: 16),
        NavigationMenu(
          items: items,
          size: MenuSize.large,
          onItemSelected: (index) => debugPrint('Large selected: $index'),
        ),
      ],
    );
  }

  Widget _buildInteractiveDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Index: $_selectedIndex',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.dashboard, size: 64, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Welcome to your dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.info, size: 64, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Important information and updates',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.settings, size: 64, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Configure your application',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
