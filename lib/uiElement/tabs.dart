import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


enum TabSize {
  small,
  medium,
  large,
}

enum TabStyle {
  default_,
  outlined,
  filled,
  pills,
  underline,
}

enum TabPosition {
  top,
  bottom,
  left,
  right,
}

class TabItem {
  final String label;
  final IconData? icon;
  final Widget content;
  final bool disabled;
  final Map<String, dynamic>? extraData;

  const TabItem({
    required this.label,
    this.icon,
    required this.content,
    this.disabled = false,
    this.extraData,
  });
}

class MeowTabs extends StatefulWidget {
  final List<TabItem> tabs;
  final TabSize size;
  final TabStyle style;
  final TabPosition position;
  final int initialIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showIcons;
  final bool showLabels;
  final bool scrollable;
  final Function(int)? onTabChanged;
  final bool showIndicator;
  final Color? indicatorColor;
  final double? indicatorHeight;
  final double? indicatorWidth;

  const MeowTabs({
    super.key,
    required this.tabs,
    this.size = TabSize.medium,
    this.style = TabStyle.default_,
    this.position = TabPosition.top,
    this.initialIndex = 0,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showIcons = true,
    this.showLabels = true,
    this.scrollable = false,
    this.onTabChanged,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorWidth,
  });

  @override
  State<MeowTabs> createState() => _MeowTabsState();
}

class _MeowTabsState extends State<MeowTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      widget.onTabChanged?.call(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    final isVertical = widget.position == TabPosition.left || widget.position == TabPosition.right;

    if (isVertical) {
      return Row(
        children: [
          if (widget.position == TabPosition.left) ...[
            _buildTabBar(),
            const VerticalDivider(width: 1),
            Expanded(child: _buildTabView()),
          ] else ...[
            Expanded(child: _buildTabView()),
            const VerticalDivider(width: 1),
            _buildTabBar(),
          ],
        ],
      );
    }

    return Column(
      children: [
        if (widget.position == TabPosition.top) ...[
          _buildTabBar(),
          const Divider(height: 1),
          Expanded(child: _buildTabView()),
        ] else ...[
          Expanded(child: _buildTabView()),
          const Divider(height: 1),
          _buildTabBar(),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    final isVertical = widget.position == TabPosition.left || widget.position == TabPosition.right;

    return Container(
      margin: widget.margin ?? _getMargin(),
      padding: widget.padding ?? _getPadding(),
      decoration: _getTabBarDecoration(),
      child: isVertical ? _buildVerticalTabBar() : _buildHorizontalTabBar(),
    );
  }

  Widget _buildHorizontalTabBar() {
    if (widget.scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildTabItems(),
        ),
      );
    }

    return Row(
      children: _buildTabItems(),
    );
  }

  Widget _buildVerticalTabBar() {
    if (widget.scrollable) {
      return SingleChildScrollView(
        child: Column(
          children: _buildTabItems(),
        ),
      );
    }

    return Column(
      children: _buildTabItems(),
    );
  }

  List<Widget> _buildTabItems() {
    return widget.tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isActive = index == _currentIndex;
      final isDisabled = tab.disabled;

      return _buildTabItem(tab, index, isActive, isDisabled);
    }).toList();
  }

  Widget _buildTabItem(TabItem tab, int index, bool isActive, bool isDisabled) {
    final isVertical = widget.position == TabPosition.left || widget.position == TabPosition.right;
    final color = isActive 
        ? (widget.activeColor ?? AppColors.cardBorder)
        : (isDisabled ? AppColors.cardBorder.withValues(alpha: 0.4) : (widget.inactiveColor ?? AppColors.cardBorder.withValues(alpha: 0.7)));

    return GestureDetector(
      onTap: isDisabled ? null : () {
        setState(() {
          _currentIndex = index;
        });
        _tabController.animateTo(index);
        widget.onTabChanged?.call(index);
      },
      child: Container(
        padding: _getTabItemPadding(),
        decoration: _getTabItemDecoration(isActive, isDisabled),
        child: isVertical ? _buildVerticalTabContent(tab, color) : _buildHorizontalTabContent(tab, color),
      ),
    );
  }

  Widget _buildHorizontalTabContent(TabItem tab, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcons && tab.icon != null) ...[
          Icon(
            tab.icon,
            size: _getIconSize(),
            color: color,
          ),
          if (widget.showLabels) SizedBox(width: _getIconSpacing()),
        ],
        if (widget.showLabels) ...[
          Text(
            tab.label,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: _currentIndex == widget.tabs.indexOf(tab) ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalTabContent(TabItem tab, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showIcons && tab.icon != null) ...[
          Icon(
            tab.icon,
            size: _getIconSize(),
            color: color,
          ),
          if (widget.showLabels) SizedBox(height: _getIconSpacing()),
        ],
        if (widget.showLabels) ...[
          Text(
            tab.label,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: _currentIndex == widget.tabs.indexOf(tab) ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabView() {
    return IndexedStack(
      index: _currentIndex,
      children: widget.tabs.map((tab) => tab.content).toList(),
    );
  }

  BoxDecoration? _getTabBarDecoration() {
    switch (widget.style) {
      case TabStyle.default_:
        return null;
      case TabStyle.outlined:
        return BoxDecoration(
          border: Border.all(
            color: widget.borderColor ?? AppColors.cardBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        );
      case TabStyle.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.grey100,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        );
      case TabStyle.pills:
        return null;
      case TabStyle.underline:
        return const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey500, width: 1),
          ),
        );
    }
  }

  BoxDecoration? _getTabItemDecoration(bool isActive, bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.cardBorder.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
      );
    }

    switch (widget.style) {
      case TabStyle.default_:
        if (isActive && widget.showIndicator) {
          return BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.indicatorColor ?? (widget.activeColor ?? AppColors.cardBorder),
                width: widget.indicatorHeight ?? 2,
              ),
            ),
          );
        }
        return null;
      case TabStyle.outlined:
        if (isActive) {
          return BoxDecoration(
            border: Border.all(
              color: widget.activeColor ?? AppColors.cardBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
          );
        }
        return null;
      case TabStyle.filled:
        if (isActive) {
          return BoxDecoration(
            color: widget.activeColor ?? AppColors.cardBorder,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
          );
        }
        return null;
      case TabStyle.pills:
        if (isActive) {
          return BoxDecoration(
            color: widget.activeColor ?? AppColors.cardBorder,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
          );
        }
        return BoxDecoration(
          color: AppColors.cardBorder.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
        );
      case TabStyle.underline:
        if (isActive && widget.showIndicator) {
          return BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.indicatorColor ?? (widget.activeColor ?? AppColors.cardBorder),
                width: widget.indicatorHeight ?? 2,
              ),
            ),
          );
        }
        return null;
    }
  }

  // Helper methods for sizing
  EdgeInsets _getMargin() {
    switch (widget.size) {
      case TabSize.small:
        return const EdgeInsets.all(4);
      case TabSize.medium:
        return const EdgeInsets.all(8);
      case TabSize.large:
        return const EdgeInsets.all(12);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case TabSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case TabSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case TabSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  EdgeInsets _getTabItemPadding() {
    switch (widget.size) {
      case TabSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
      case TabSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case TabSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case TabSize.small:
        return 12;
      case TabSize.medium:
        return 14;
      case TabSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case TabSize.small:
        return 16;
      case TabSize.medium:
        return 18;
      case TabSize.large:
        return 20;
    }
  }

  double _getIconSpacing() {
    switch (widget.size) {
      case TabSize.small:
        return 4;
      case TabSize.medium:
        return 6;
      case TabSize.large:
        return 8;
    }
  }
}

// Convenience constructors
class OutlinedTabs extends MeowTabs {
  const OutlinedTabs({
    super.key,
    required super.tabs,
    super.size = TabSize.medium,
    super.position = TabPosition.top,
    super.initialIndex = 0,
    super.activeColor,
    super.inactiveColor,
    super.borderColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.scrollable = false,
    super.onTabChanged,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
    super.indicatorWidth,
  }) : super(style: TabStyle.outlined);
}

class FilledTabs extends MeowTabs {
  const FilledTabs({
    super.key,
    required super.tabs,
    super.size = TabSize.medium,
    super.position = TabPosition.top,
    super.initialIndex = 0,
    super.activeColor,
    super.inactiveColor,
    super.backgroundColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.scrollable = false,
    super.onTabChanged,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
    super.indicatorWidth,
  }) : super(style: TabStyle.filled);
}

class PillTabs extends MeowTabs {
  const PillTabs({
    super.key,
    required super.tabs,
    super.size = TabSize.medium,
    super.position = TabPosition.top,
    super.initialIndex = 0,
    super.activeColor,
    super.inactiveColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.scrollable = false,
    super.onTabChanged,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
    super.indicatorWidth,
  }) : super(style: TabStyle.pills);
}

class UnderlineTabs extends MeowTabs {
  const UnderlineTabs({
    super.key,
    required super.tabs,
    super.size = TabSize.medium,
    super.position = TabPosition.top,
    super.initialIndex = 0,
    super.activeColor,
    super.inactiveColor,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showLabels = true,
    super.scrollable = false,
    super.onTabChanged,
    super.showIndicator = true,
    super.indicatorColor,
    super.indicatorHeight,
    super.indicatorWidth,
  }) : super(style: TabStyle.underline);
} 
