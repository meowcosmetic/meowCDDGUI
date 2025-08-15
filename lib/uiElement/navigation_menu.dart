import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum MenuSize {
  small,
  medium,
  large,
}

enum MenuStyle {
  default_,
  outlined,
  filled,
  minimal,
}

enum MenuOrientation {
  horizontal,
  vertical,
}

class MenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;
  final bool disabled;
  final List<MenuItem>? children; // For submenu
  final Map<String, dynamic>? extraData;

  const MenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isActive = false,
    this.disabled = false,
    this.children,
    this.extraData,
  });
}

class NavigationMenu extends StatefulWidget {
  final List<MenuItem> items;
  final MenuSize size;
  final MenuStyle style;
  final MenuOrientation orientation;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showIcons;
  final bool showLabels;
  final bool expandable; // For vertical menu
  final bool showSubmenu;
  final Function(int)? onItemSelected;
  final bool showIndicator;
  final Color? indicatorColor;
  final double? indicatorHeight;

  const NavigationMenu({
    super.key,
    required this.items,
    this.size = MenuSize.medium,
    this.style = MenuStyle.default_,
    this.orientation = MenuOrientation.horizontal,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showIcons = true,
    this.showLabels = true,
    this.expandable = false,
    this.showSubmenu = true,
    this.onItemSelected,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorHeight,
  });

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int? _selectedIndex;
  Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    // Find initial active item
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.items[i].isActive) {
        _selectedIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: widget.margin ?? _getMargin(),
      padding: widget.padding ?? _getPadding(),
      decoration: _getMenuDecoration(),
      child: widget.orientation == MenuOrientation.horizontal
          ? _buildHorizontalMenu()
          : _buildVerticalMenu(),
    );
  }

  Widget _buildHorizontalMenu() {
    return Row(
      children: _buildMenuItems(),
    );
  }

  Widget _buildVerticalMenu() {
    return Column(
      children: _buildMenuItems(),
    );
  }

  List<Widget> _buildMenuItems() {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isActive = index == _selectedIndex || item.isActive;
      final isExpanded = _expandedItems.contains(index);

      return _buildMenuItem(item, index, isActive, isExpanded);
    }).toList();
  }

  Widget _buildMenuItem(MenuItem item, int index, bool isActive, bool isExpanded) {
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isVertical = widget.orientation == MenuOrientation.vertical;

    Widget menuItem = GestureDetector(
      onTap: item.disabled ? null : () => _handleItemTap(item, index),
      child: Container(
        padding: _getItemPadding(),
        decoration: _getItemDecoration(isActive, item.disabled),
        child: isVertical ? _buildVerticalItemContent(item, isActive) : _buildHorizontalItemContent(item, isActive),
      ),
    );

    // Add submenu if has children and is expanded
    if (hasChildren && isExpanded && widget.showSubmenu) {
      final submenuItems = item.children!.asMap().entries.map((entry) {
        final subIndex = entry.key;
        final subItem = entry.value;
        final subIsActive = subItem.isActive;

        return _buildSubmenuItem(subItem, subIndex, subIsActive);
      }).toList();

      if (isVertical) {
        menuItem = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            menuItem,
            Padding(
              padding: EdgeInsets.only(left: _getSubmenuIndent()),
              child: Column(
                children: submenuItems,
              ),
            ),
          ],
        );
      } else {
        // Horizontal submenu (dropdown)
        menuItem = Stack(
          children: [
            menuItem,
            Positioned(
              top: _getItemHeight(),
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackWithOpacity10,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: submenuItems,
                ),
              ),
            ),
          ],
        );
      }
    }

    return menuItem;
  }

  Widget _buildSubmenuItem(MenuItem item, int index, bool isActive) {
    return GestureDetector(
      onTap: item.disabled ? null : () => _handleSubmenuItemTap(item, index),
      child: Container(
        padding: _getSubmenuItemPadding(),
        decoration: _getSubmenuItemDecoration(isActive, item.disabled),
        child: _buildSubmenuItemContent(item, isActive),
      ),
    );
  }

  Widget _buildHorizontalItemContent(MenuItem item, bool isActive) {
    final color = isActive 
        ? (widget.activeColor ?? AppColors.primary)
        : (item.disabled ? AppColors.primaryWithOpacity40 : (widget.inactiveColor ?? AppColors.primaryWithOpacity70));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcons && item.icon != null) ...[
          Icon(
            item.icon,
            size: _getIconSize(),
            color: color,
          ),
          if (widget.showLabels) SizedBox(width: _getIconSpacing()),
        ],
        if (widget.showLabels) ...[
          Text(
            item.label,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
        if (item.children != null && item.children!.isNotEmpty) ...[
          SizedBox(width: _getIconSpacing()),
          Icon(
            Icons.keyboard_arrow_down,
            size: _getIconSize() * 0.8,
            color: color,
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalItemContent(MenuItem item, bool isActive) {
    final color = isActive 
        ? (widget.activeColor ?? AppColors.primary)
        : (item.disabled ? AppColors.primaryWithOpacity40 : (widget.inactiveColor ?? AppColors.primaryWithOpacity70));

    return Row(
      children: [
        if (widget.showIcons && item.icon != null) ...[
          Icon(
            item.icon,
            size: _getIconSize(),
            color: color,
          ),
          if (widget.showLabels) SizedBox(width: _getIconSpacing()),
        ],
        if (widget.showLabels) ...[
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
        if (item.children != null && item.children!.isNotEmpty) ...[
          Icon(
            _expandedItems.contains(widget.items.indexOf(item)) 
                ? Icons.keyboard_arrow_up 
                : Icons.keyboard_arrow_right,
            size: _getIconSize() * 0.8,
            color: color,
          ),
        ],
      ],
    );
  }

  Widget _buildSubmenuItemContent(MenuItem item, bool isActive) {
    final color = isActive 
        ? (widget.activeColor ?? AppColors.primary)
        : (item.disabled ? AppColors.primaryWithOpacity40 : (widget.inactiveColor ?? AppColors.primaryWithOpacity70));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcons && item.icon != null) ...[
          Icon(
            item.icon,
            size: _getIconSize() * 0.9,
            color: color,
          ),
          if (widget.showLabels) SizedBox(width: _getIconSpacing()),
        ],
        if (widget.showLabels) ...[
          Text(
            item.label,
            style: TextStyle(
              fontSize: _getFontSize() * 0.9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  void _handleItemTap(MenuItem item, int index) {
    if (item.children != null && item.children!.isNotEmpty && widget.showSubmenu) {
      setState(() {
        if (_expandedItems.contains(index)) {
          _expandedItems.remove(index);
        } else {
          _expandedItems.add(index);
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
      item.onTap?.call();
      widget.onItemSelected?.call(index);
    }
  }

  void _handleSubmenuItemTap(MenuItem item, int index) {
    item.onTap?.call();
    widget.onItemSelected?.call(index);
  }

  BoxDecoration? _getMenuDecoration() {
    switch (widget.style) {
      case MenuStyle.default_:
        return null;
      case MenuStyle.outlined:
        return BoxDecoration(
          border: Border.all(
            color: widget.borderColor ?? AppColors.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        );
      case MenuStyle.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.grey100,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        );
      case MenuStyle.minimal:
        return null;
    }
  }

  BoxDecoration? _getItemDecoration(bool isActive, bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.primaryWithOpacity10,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
      );
    }

    switch (widget.style) {
      case MenuStyle.default_:
        if (isActive && widget.showIndicator) {
          return BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.indicatorColor ?? (widget.activeColor ?? AppColors.primary),
                width: widget.indicatorHeight ?? 2,
              ),
            ),
          );
        }
        return null;
      case MenuStyle.outlined:
        if (isActive) {
          return BoxDecoration(
            border: Border.all(
              color: widget.activeColor ?? AppColors.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
          );
        }
        return null;
      case MenuStyle.filled:
        if (isActive) {
          return BoxDecoration(
            color: widget.activeColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
          );
        }
        return null;
      case MenuStyle.minimal:
        if (isActive) {
          return BoxDecoration(
            color: (widget.activeColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
          );
        }
        return null;
    }
  }

  BoxDecoration? _getSubmenuItemDecoration(bool isActive, bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.primaryWithOpacity10,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 4),
      );
    }

    if (isActive) {
      return BoxDecoration(
        color: (widget.activeColor ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 4),
      );
    }

    return null;
  }

  // Helper methods for sizing
  EdgeInsets _getMargin() {
    switch (widget.size) {
      case MenuSize.small:
        return const EdgeInsets.all(4);
      case MenuSize.medium:
        return const EdgeInsets.all(8);
      case MenuSize.large:
        return const EdgeInsets.all(12);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case MenuSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case MenuSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case MenuSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  EdgeInsets _getItemPadding() {
    switch (widget.size) {
      case MenuSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
      case MenuSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case MenuSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  EdgeInsets _getSubmenuItemPadding() {
    switch (widget.size) {
      case MenuSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case MenuSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case MenuSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case MenuSize.small:
        return 12;
      case MenuSize.medium:
        return 14;
      case MenuSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case MenuSize.small:
        return 16;
      case MenuSize.medium:
        return 18;
      case MenuSize.large:
        return 20;
    }
  }

  double _getIconSpacing() {
    switch (widget.size) {
      case MenuSize.small:
        return 4;
      case MenuSize.medium:
        return 6;
      case MenuSize.large:
        return 8;
    }
  }

  double _getSubmenuIndent() {
    switch (widget.size) {
      case MenuSize.small:
        return 16;
      case MenuSize.medium:
        return 20;
      case MenuSize.large:
        return 24;
    }
  }

  double _getItemHeight() {
    switch (widget.size) {
      case MenuSize.small:
        return 32;
      case MenuSize.medium:
        return 40;
      case MenuSize.large:
        return 48;
    }
  }
}

// Convenience constructors
class OutlinedNavigationMenu extends NavigationMenu {
  const OutlinedNavigationMenu({
    super.key,
    required super.items,
    super.size = MenuSize.medium,
    super.orientation = MenuOrientation.horizontal,
    super.activeColor,
    super.inactiveColor,
    super.borderColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.expandable = false,
    super.showSubmenu = true,
    super.onItemSelected,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
  }) : super(style: MenuStyle.outlined);
}

class FilledNavigationMenu extends NavigationMenu {
  const FilledNavigationMenu({
    super.key,
    required super.items,
    super.size = MenuSize.medium,
    super.orientation = MenuOrientation.horizontal,
    super.activeColor,
    super.inactiveColor,
    super.backgroundColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.expandable = false,
    super.showSubmenu = true,
    super.onItemSelected,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
  }) : super(style: MenuStyle.filled);
}

class MinimalNavigationMenu extends NavigationMenu {
  const MinimalNavigationMenu({
    super.key,
    required super.items,
    super.size = MenuSize.medium,
    super.orientation = MenuOrientation.horizontal,
    super.activeColor,
    super.inactiveColor,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.expandable = false,
    super.showSubmenu = true,
    super.onItemSelected,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
  }) : super(style: MenuStyle.minimal);
} 
