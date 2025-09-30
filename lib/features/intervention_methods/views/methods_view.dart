import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../models/method_group_models.dart';
import '../services/method_service.dart';

class MethodsView extends StatefulWidget {
  final InterventionMethodGroupModel methodGroup;

  const MethodsView({super.key, required this.methodGroup});

  @override
  State<MethodsView> createState() => _MethodsViewState();
}

class _MethodsViewState extends State<MethodsView> {
  final InterventionMethodService _service = InterventionMethodService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<InterventionMethodModel> _methods = [];
  int _page = 0;
  final int _size = 5;
  int _totalElements = 0;
  int _totalPages = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final paged = await _service.getMethodsByGroup(
        groupId: widget.methodGroup.id,
        page: _page,
        size: _size,
      );

      setState(() {
        _methods = paged.content;
        _totalElements = paged.totalElements;
        _totalPages = paged.totalPages;
        _hasNext = paged.hasNext;
        _hasPrevious = paged.hasPrevious;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      _page = page;
    });
    await _load();
  }

  Future<void> _createOrEditMethod({InterventionMethodModel? method}) async {
    final codeController = TextEditingController(text: method?.code ?? '');
    final displayedNameViController = TextEditingController(
      text: method?.displayedName.vi ?? '',
    );
    final displayedNameEnController = TextEditingController(
      text: method?.displayedName.en ?? '',
    );
    final descViController = TextEditingController(
      text: method?.description?.vi ?? '',
    );
    final descEnController = TextEditingController(
      text: method?.description?.en ?? '',
    );
    final minAgeController = TextEditingController(
      text: method?.minAgeMonths.toString() ?? '12',
    );
    final maxAgeController = TextEditingController(
      text: method?.maxAgeMonths.toString() ?? '60',
    );
    final isEdit = method != null;

    final result = await showDialog<InterventionMethodModel>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Chỉnh sửa phương pháp' : 'Tạo phương pháp mới',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trong nhóm: ${widget.methodGroup.displayedName.vi}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: codeController,
                          decoration: const InputDecoration(
                            labelText: 'Mã phương pháp',
                            border: OutlineInputBorder(),
                            hintText: 'VD: ABA_THERAPY',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: displayedNameViController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (Tiếng Việt)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: Trị liệu bằng trò chơi',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: displayedNameEnController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (Tiếng Anh)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: Play Therapy',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: minAgeController,
                          decoration: const InputDecoration(
                            labelText: 'Độ tuổi tối thiểu (tháng)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: 12',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: maxAgeController,
                          decoration: const InputDecoration(
                            labelText: 'Độ tuổi tối đa (tháng)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: 60',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mô tả (Tiếng Việt) - Hỗ trợ HTML:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descViController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:
                                'VD: <p>Phương pháp trị liệu sử dụng trò chơi...</p>',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mô tả (Tiếng Anh) - Hỗ trợ HTML:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descEnController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:
                                'VD: <p>Therapeutic method using play...</p>',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final minAgeMonths =
                              int.tryParse(minAgeController.text) ?? 12;
                          final maxAgeMonths =
                              int.tryParse(maxAgeController.text) ?? 60;

                          final displayedName = LocalizedText(
                            vi: displayedNameViController.text.trim(),
                            en: displayedNameEnController.text.trim(),
                          );

                          LocalizedText? description;
                          if (descViController.text.trim().isNotEmpty ||
                              descEnController.text.trim().isNotEmpty) {
                            description = LocalizedText(
                              vi: descViController.text.trim(),
                              en: descEnController.text.trim(),
                            );
                          }

                          InterventionMethodModel result;
                          if (isEdit) {
                            result = await _service.updateMethod(
                              methodId: method.id,
                              code: codeController.text.trim(),
                              displayedName: displayedName,
                              description: description,
                              minAgeMonths: minAgeMonths,
                              maxAgeMonths: maxAgeMonths,
                              groupId: widget.methodGroup.id,
                            );
                          } else {
                            result = await _service.createMethod(
                              code: codeController.text.trim(),
                              displayedName: displayedName,
                              description: description,
                              minAgeMonths: minAgeMonths,
                              maxAgeMonths: maxAgeMonths,
                              groupId: widget.methodGroup.id,
                            );
                          }

                          Navigator.pop(context, result);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(isEdit ? 'Cập nhật' : 'Tạo mới'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      _load();
    }
  }

  Future<void> _deleteMethod(InterventionMethodModel method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa phương pháp "${method.displayedName.vi}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('Attempting to delete method with ID: ${method.id}');
        await _service.deleteMethod(method.id);
        print('Delete method call completed successfully');
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa phương pháp thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting method: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupDisplayName = widget.methodGroup.displayedName.vi.isNotEmpty
        ? widget.methodGroup.displayedName.vi
        : widget.methodGroup.displayedName.en;

    return Scaffold(
      appBar: AppBar(
        title: Text('Phương pháp: $groupDisplayName'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrEditMethod(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_methods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có phương pháp nào',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Trong nhóm: ${widget.methodGroup.displayedName.vi.isNotEmpty ? widget.methodGroup.displayedName.vi : widget.methodGroup.displayedName.en}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút + để tạo phương pháp đầu tiên',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pagination info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiển thị ${_methods.length} / $_totalElements phương pháp',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Trang ${_page + 1} / $_totalPages',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        // Methods list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _methods.length,
            itemBuilder: (context, index) {
              final method = _methods[index];
              return _buildMethodCard(method);
            },
          ),
        ),
        // Pagination controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _hasPrevious ? () => _loadPage(_page - 1) : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Trang trước',
              ),
              const SizedBox(width: 16),
              // Page numbers
              ...List.generate(_totalPages, (index) {
                if (_totalPages <= 7 ||
                    index == 0 ||
                    index == _totalPages - 1 ||
                    (index >= _page - 1 && index <= _page + 1)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _loadPage(index),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: index == _page
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == _page
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: index == _page
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (index == _page - 2 || index == _page + 2) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...'),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _hasNext ? () => _loadPage(_page + 1) : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Trang sau',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(InterventionMethodModel method) {
    final displayedName = method.displayedName.vi.isNotEmpty
        ? method.displayedName.vi
        : method.displayedName.en;
    final displayedDesc =
        method.description?.vi ?? method.description?.en ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (method.code.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          method.code,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${method.minAgeMonths}-${method.maxAgeMonths} tháng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _createOrEditMethod(method: method);
                            break;
                          case 'delete':
                            _deleteMethod(method);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.child_care, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Độ tuổi: ${method.minAgeMonths}-${method.maxAgeMonths} tháng',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (displayedDesc.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Html(
                  data: displayedDesc,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(13),
                      color: AppColors.textSecondary,
                      lineHeight: LineHeight(1.3),
                    ),
                    "p": Style(margin: Margins.only(bottom: 6)),
                    "strong": Style(fontWeight: FontWeight.bold),
                    "em": Style(fontStyle: FontStyle.italic),
                    "ul": Style(margin: Margins.only(left: 16)),
                    "ol": Style(margin: Margins.only(left: 16)),
                    "li": Style(margin: Margins.only(bottom: 4)),
                    "h1": Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 8),
                    ),
                    "h2": Style(
                      fontSize: FontSize(15),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 6),
                    ),
                    "h3": Style(
                      fontSize: FontSize(14),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 4),
                    ),
                    "blockquote": Style(
                      padding: HtmlPaddings.only(left: 12),
                      margin: Margins.only(bottom: 8),
                    ),
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
