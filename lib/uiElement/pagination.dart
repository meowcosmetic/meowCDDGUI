import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum PaginationType { numbers, dots, arrows, simple }

enum PaginationSize { small, medium, large }

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? totalItems;
  final int? itemsPerPage;
  final PaginationType type;
  final PaginationSize size;
  final Function(int)? onPageChanged;
  final bool showFirstLast;
  final bool showInfo;
  final Color? activeColor;
  final Color? inactiveColor;
  final int maxVisiblePages;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalItems,
    this.itemsPerPage,
    this.type = PaginationType.numbers,
    this.size = PaginationSize.medium,
    this.onPageChanged,
    this.showFirstLast = true,
    this.showInfo = false,
    this.activeColor,
    this.inactiveColor,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActiveColor = activeColor ?? theme.primaryColor;
    final defaultInactiveColor = inactiveColor ?? AppColors.grey400;

    return Column(
      children: [
        if (showInfo) _buildInfo(),
        const SizedBox(height: 8),
        _buildPagination(defaultActiveColor, defaultInactiveColor),
      ],
    );
  }

  Widget _buildInfo() {
    if (totalItems == null || itemsPerPage == null)
      return const SizedBox.shrink();

    final startItem = (currentPage - 1) * itemsPerPage! + 1;
    final endItem = currentPage * itemsPerPage! > totalItems!
        ? totalItems!
        : currentPage * itemsPerPage!;

    return Text(
      'Hiển thị $startItem-$endItem của $totalItems kết quả',
      style: TextStyle(fontSize: _getInfoSize(), color: AppColors.grey600),
    );
  }

  Widget _buildPagination(Color activeColor, Color inactiveColor) {
    switch (type) {
      case PaginationType.numbers:
        return _buildNumbersPagination(activeColor, inactiveColor);
      case PaginationType.dots:
        return _buildDotsPagination(activeColor, inactiveColor);
      case PaginationType.arrows:
        return _buildArrowsPagination(activeColor, inactiveColor);
      case PaginationType.simple:
        return _buildSimplePagination(activeColor, inactiveColor);
    }
  }

  Widget _buildNumbersPagination(Color activeColor, Color inactiveColor) {
    final pages = _getVisiblePages();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFirstLast && currentPage > 1)
          _buildPageButton(
            1,
            'Đầu',
            Icons.first_page,
            activeColor,
            inactiveColor,
          ),
        if (currentPage > 1)
          _buildPageButton(
            currentPage - 1,
            'Trước',
            Icons.chevron_left,
            activeColor,
            inactiveColor,
          ),
        ...pages.map((page) {
          if (page == -1) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: _getSpacing()),
              child: Text(
                '...',
                style: TextStyle(
                  fontSize: _getTextSize(),
                  color: inactiveColor,
                ),
              ),
            );
          }
          return _buildPageButton(
            page,
            page.toString(),
            null,
            activeColor,
            inactiveColor,
            isActive: page == currentPage,
          );
        }),
        if (currentPage < totalPages)
          _buildPageButton(
            currentPage + 1,
            'Sau',
            Icons.chevron_right,
            activeColor,
            inactiveColor,
          ),
        if (showFirstLast && currentPage < totalPages)
          _buildPageButton(
            totalPages,
            'Cuối',
            Icons.last_page,
            activeColor,
            inactiveColor,
          ),
      ],
    );
  }

  Widget _buildDotsPagination(Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final page = index + 1;
        final isActive = page == currentPage;

        return GestureDetector(
          onTap: () => onPageChanged?.call(page),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: _getDotSpacing()),
            width: _getDotSize(),
            height: _getDotSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildArrowsPagination(Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentPage > 1)
          _buildArrowButton(
            currentPage - 1,
            Icons.chevron_left,
            activeColor,
            inactiveColor,
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getSpacing()),
          child: Text(
            '$currentPage / $totalPages',
            style: TextStyle(
              fontSize: _getTextSize(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (currentPage < totalPages)
          _buildArrowButton(
            currentPage + 1,
            Icons.chevron_right,
            activeColor,
            inactiveColor,
          ),
      ],
    );
  }

  Widget _buildSimplePagination(Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentPage > 1)
          _buildSimpleButton(
            currentPage - 1,
            'Trước',
            activeColor,
            inactiveColor,
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getSpacing()),
          child: Text(
            'Trang $currentPage của $totalPages',
            style: TextStyle(
              fontSize: _getTextSize(),
              color: AppColors.grey600,
            ),
          ),
        ),
        if (currentPage < totalPages)
          _buildSimpleButton(
            currentPage + 1,
            'Sau',
            activeColor,
            inactiveColor,
          ),
      ],
    );
  }

  Widget _buildPageButton(
    int page,
    String text,
    IconData? icon,
    Color activeColor,
    Color inactiveColor, {
    bool isActive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getSpacing()),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          onTap: () => onPageChanged?.call(page),
          child: Container(
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: isActive ? activeColor : AppColors.transparent,
              border: Border.all(
                color: isActive ? activeColor : inactiveColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: _getIconSize(),
                    color: isActive ? AppColors.white : inactiveColor,
                  ),
                  SizedBox(width: _getIconSpacing()),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: _getTextSize(),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.white : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(
    int page,
    IconData icon,
    Color activeColor,
    Color inactiveColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getSpacing()),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          onTap: () => onPageChanged?.call(page),
          child: Container(
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            child: Icon(icon, size: _getIconSize(), color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton(
    int page,
    String text,
    Color activeColor,
    Color inactiveColor,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getSpacing()),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          onTap: () => onPageChanged?.call(page),
          child: Container(
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(_getBorderRadius()),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: _getTextSize(),
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<int> _getVisiblePages() {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final pages = <int>[];
    final halfVisible = (maxVisiblePages - 1) ~/ 2;

    if (currentPage <= halfVisible + 1) {
      // Near the beginning
      for (int i = 1; i <= maxVisiblePages - 1; i++) {
        pages.add(i);
      }
      pages.add(-1); // Ellipsis
      pages.add(totalPages);
    } else if (currentPage >= totalPages - halfVisible) {
      // Near the end
      pages.add(1);
      pages.add(-1); // Ellipsis
      for (int i = totalPages - maxVisiblePages + 2; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      // In the middle
      pages.add(1);
      pages.add(-1); // Ellipsis
      for (
        int i = currentPage - halfVisible;
        i <= currentPage + halfVisible;
        i++
      ) {
        pages.add(i);
      }
      pages.add(-1); // Ellipsis
      pages.add(totalPages);
    }

    return pages;
  }

  double _getBorderRadius() {
    switch (size) {
      case PaginationSize.small:
        return 4;
      case PaginationSize.medium:
        return 6;
      case PaginationSize.large:
        return 8;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case PaginationSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case PaginationSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case PaginationSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _getSpacing() {
    switch (size) {
      case PaginationSize.small:
        return 4;
      case PaginationSize.medium:
        return 6;
      case PaginationSize.large:
        return 8;
    }
  }

  double _getDotSpacing() {
    switch (size) {
      case PaginationSize.small:
        return 4;
      case PaginationSize.medium:
        return 6;
      case PaginationSize.large:
        return 8;
    }
  }

  double _getDotSize() {
    switch (size) {
      case PaginationSize.small:
        return 8;
      case PaginationSize.medium:
        return 10;
      case PaginationSize.large:
        return 12;
    }
  }

  double _getTextSize() {
    switch (size) {
      case PaginationSize.small:
        return 12;
      case PaginationSize.medium:
        return 14;
      case PaginationSize.large:
        return 16;
    }
  }

  double _getInfoSize() {
    switch (size) {
      case PaginationSize.small:
        return 12;
      case PaginationSize.medium:
        return 14;
      case PaginationSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PaginationSize.small:
        return 16;
      case PaginationSize.medium:
        return 18;
      case PaginationSize.large:
        return 20;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case PaginationSize.small:
        return 4;
      case PaginationSize.medium:
        return 6;
      case PaginationSize.large:
        return 8;
    }
  }
}

// Convenience constructors
class NumbersPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? totalItems;
  final int? itemsPerPage;
  final PaginationSize size;
  final Function(int)? onPageChanged;
  final bool showFirstLast;
  final bool showInfo;
  final Color? activeColor;
  final Color? inactiveColor;
  final int maxVisiblePages;

  const NumbersPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalItems,
    this.itemsPerPage,
    this.size = PaginationSize.medium,
    this.onPageChanged,
    this.showFirstLast = true,
    this.showInfo = false,
    this.activeColor,
    this.inactiveColor,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Pagination(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      type: PaginationType.numbers,
      size: size,
      onPageChanged: onPageChanged,
      showFirstLast: showFirstLast,
      showInfo: showInfo,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      maxVisiblePages: maxVisiblePages,
    );
  }
}

class DotsPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PaginationSize size;
  final Function(int)? onPageChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const DotsPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.size = PaginationSize.medium,
    this.onPageChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Pagination(
      currentPage: currentPage,
      totalPages: totalPages,
      type: PaginationType.dots,
      size: size,
      onPageChanged: onPageChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

class ArrowsPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PaginationSize size;
  final Function(int)? onPageChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const ArrowsPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.size = PaginationSize.medium,
    this.onPageChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Pagination(
      currentPage: currentPage,
      totalPages: totalPages,
      type: PaginationType.arrows,
      size: size,
      onPageChanged: onPageChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

class SimplePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PaginationSize size;
  final Function(int)? onPageChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const SimplePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.size = PaginationSize.medium,
    this.onPageChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Pagination(
      currentPage: currentPage,
      totalPages: totalPages,
      type: PaginationType.simple,
      size: size,
      onPageChanged: onPageChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}
