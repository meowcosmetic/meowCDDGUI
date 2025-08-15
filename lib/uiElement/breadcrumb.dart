import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


enum BreadcrumbSize {
  small,
  medium,
  large,
}

enum BreadcrumbStyle {
  default_,
  outlined,
  filled,
  minimal,
}

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;
  final Map<String, dynamic>? extraData;

  const BreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isActive = false,
    this.extraData,
  });
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final BreadcrumbSize size;
  final BreadcrumbStyle style;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showIcons;
  final bool showSeparators;
  final IconData? separatorIcon;

  const Breadcrumb({
    super.key,
    required this.items,
    this.size = BreadcrumbSize.medium,
    this.style = BreadcrumbStyle.default_,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showIcons = true,
    this.showSeparators = true,
    this.separatorIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: margin ?? _getMargin(),
      padding: padding ?? _getPadding(),
      decoration: _getDecoration(),
      child: Row(
        children: _buildBreadcrumbItems(),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems() {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      // Add separator if not first item and separators are enabled
      if (i > 0 && showSeparators) {
        widgets.add(_buildSeparator());
      }

      // Add breadcrumb item
      widgets.add(_buildBreadcrumbItem(item));
    }

    return widgets;
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item) {
    final isActive = item.isActive;
    final color = isActive 
        ? (activeColor ?? AppColors.cardBorder)
        : (inactiveColor ?? AppColors.cardBorder.withValues(alpha: 0.7));

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: _getItemPadding(),
        decoration: _getItemDecoration(isActive),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcons && item.icon != null) ...[
              Icon(
                item.icon,
                size: _getIconSize(),
                color: color,
              ),
              SizedBox(width: _getIconSpacing()),
            ],
            Text(
              item.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    final color = inactiveColor ?? AppColors.cardBorder.withValues(alpha: 0.5);
    final icon = separatorIcon ?? Icons.chevron_right;
    final size = _getIconSize() * 0.8;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getSeparatorSpacing()),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  BoxDecoration? _getDecoration() {
    switch (style) {
      case BreadcrumbStyle.default_:
        return null;
      case BreadcrumbStyle.outlined:
        return BoxDecoration(
          border: Border.all(
            color: borderColor ?? AppColors.cardBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        );
      case BreadcrumbStyle.filled:
        return BoxDecoration(
          color: backgroundColor ?? AppColors.grey100,
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        );
      case BreadcrumbStyle.minimal:
        return null;
    }
  }

  BoxDecoration? _getItemDecoration(bool isActive) {
    if (!isActive) return null;

    switch (style) {
      case BreadcrumbStyle.default_:
        return BoxDecoration(
          color: (activeColor ?? AppColors.cardBorder).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius ?? 6),
        );
      case BreadcrumbStyle.outlined:
        return BoxDecoration(
          border: Border.all(
            color: activeColor ?? AppColors.cardBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 6),
        );
      case BreadcrumbStyle.filled:
        return BoxDecoration(
          color: activeColor ?? AppColors.cardBorder,
          borderRadius: BorderRadius.circular(borderRadius ?? 6),
        );
      case BreadcrumbStyle.minimal:
        return null;
    }
  }

  // Helper methods for sizing
  EdgeInsets _getMargin() {
    switch (size) {
      case BreadcrumbSize.small:
        return const EdgeInsets.all(4);
      case BreadcrumbSize.medium:
        return const EdgeInsets.all(8);
      case BreadcrumbSize.large:
        return const EdgeInsets.all(12);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BreadcrumbSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BreadcrumbSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BreadcrumbSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  EdgeInsets _getItemPadding() {
    switch (size) {
      case BreadcrumbSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BreadcrumbSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BreadcrumbSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getFontSize() {
    switch (size) {
      case BreadcrumbSize.small:
        return 12;
      case BreadcrumbSize.medium:
        return 14;
      case BreadcrumbSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case BreadcrumbSize.small:
        return 14;
      case BreadcrumbSize.medium:
        return 16;
      case BreadcrumbSize.large:
        return 18;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case BreadcrumbSize.small:
        return 4;
      case BreadcrumbSize.medium:
        return 6;
      case BreadcrumbSize.large:
        return 8;
    }
  }

  double _getSeparatorSpacing() {
    switch (size) {
      case BreadcrumbSize.small:
        return 4;
      case BreadcrumbSize.medium:
        return 6;
      case BreadcrumbSize.large:
        return 8;
    }
  }
}

// Convenience constructors
class OutlinedBreadcrumb extends Breadcrumb {
  const OutlinedBreadcrumb({
    super.key,
    required super.items,
    super.size = BreadcrumbSize.medium,
    super.activeColor,
    super.inactiveColor,
    super.borderColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showSeparators = true,
    super.separatorIcon,
  }) : super(style: BreadcrumbStyle.outlined);
}

class FilledBreadcrumb extends Breadcrumb {
  const FilledBreadcrumb({
    super.key,
    required super.items,
    super.size = BreadcrumbSize.medium,
    super.activeColor,
    super.inactiveColor,
    super.backgroundColor,
    super.borderRadius,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showSeparators = true,
    super.separatorIcon,
  }) : super(style: BreadcrumbStyle.filled);
}

class MinimalBreadcrumb extends Breadcrumb {
  const MinimalBreadcrumb({
    super.key,
    required super.items,
    super.size = BreadcrumbSize.medium,
    super.activeColor,
    super.inactiveColor,
    super.padding,
    super.margin,
    super.showIcons = true,
    super.showSeparators = true,
    super.separatorIcon,
  }) : super(style: BreadcrumbStyle.minimal);
} 
