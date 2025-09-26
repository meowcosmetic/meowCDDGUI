import 'package:flutter/material.dart';
import 'pagination.dart';
import '../constants/app_colors.dart';

class PaginationDemo extends StatefulWidget {
  final bool showAppBar;

  const PaginationDemo({super.key, this.showAppBar = true});

  @override
  State<PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<PaginationDemo> {
  int _currentPage = 1;
  int _totalPages = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Pagination Components Demo'),
              backgroundColor: AppColors.cardBorder,
              foregroundColor: AppColors.white,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Numbers Pagination',
              'Pagination với số trang và nút điều hướng',
              [
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  totalItems: 100,
                  itemsPerPage: 10,
                  showInfo: true,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  showFirstLast: false,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Dots Pagination',
              'Pagination dạng chấm tròn',
              [
                DotsPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DotsPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.large,
                  activeColor: AppColors.cardBorder,
                  inactiveColor: AppColors.cardBorder.withValues(alpha: 0.3),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Arrows Pagination',
              'Pagination với mũi tên điều hướng',
              [
                ArrowsPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ArrowsPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.large,
                  activeColor: AppColors.green,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Simple Pagination',
              'Pagination đơn giản với nút Trước/Sau',
              [
                SimplePagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SimplePagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.large,
                  activeColor: AppColors.purple,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Kích thước khác nhau',
              'Các kích thước pagination từ nhỏ đến lớn',
              [
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.small,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.medium,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  size: PaginationSize.large,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Pagination với nhiều trang',
              'Pagination với ellipsis khi có nhiều trang',
              [
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: 20,
                  maxVisiblePages: 5,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: 20,
                  maxVisiblePages: 7,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Điều khiển trang',
              'Thay đổi trang hiện tại và tổng số trang',
              [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trang hiện tại:'),
                          Slider(
                            value: _currentPage.toDouble(),
                            min: 1,
                            max: _totalPages.toDouble(),
                            divisions: _totalPages - 1,
                            onChanged: (value) {
                              setState(() {
                                _currentPage = value.round();
                              });
                            },
                          ),
                          Text('$_currentPage / $_totalPages'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng số trang:'),
                          Slider(
                            value: _totalPages.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                _totalPages = value.round();
                                if (_currentPage > _totalPages) {
                                  _currentPage = _totalPages;
                                }
                              });
                            },
                          ),
                          Text('$_totalPages trang'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  totalItems: _totalPages * 10,
                  itemsPerPage: 10,
                  showInfo: true,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              'Pagination tùy chỉnh màu sắc',
              'Pagination với màu sắc tùy chỉnh',
              [
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  activeColor: AppColors.cardBorder,
                  inactiveColor: AppColors.cardBorder.withValues(alpha: 0.3),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  activeColor: AppColors.green,
                  inactiveColor: AppColors.cardBorder.withValues(alpha: 0.3),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                const SizedBox(height: 16),
                NumbersPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  activeColor: AppColors.purple,
                  inactiveColor: AppColors.cardBorder.withValues(alpha: 0.3),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.cardBorder.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
