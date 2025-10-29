import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../models/method_group_models.dart';
import '../services/method_group_service.dart';
import 'methods_view.dart';
import '../../../view/layouts/web_main_layout.dart';

class MethodGroupsView extends StatefulWidget {
  const MethodGroupsView({super.key});

  @override
  State<MethodGroupsView> createState() => _MethodGroupsViewState();
}

class _MethodGroupsViewState extends State<MethodGroupsView> {
  final InterventionMethodGroupService _service =
      InterventionMethodGroupService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<InterventionMethodGroupModel> _methodGroups = [];
  int _page = 0;
  final int _size = 10;

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
      final paged = await _service.getMethodGroups(page: _page, size: _size);

      setState(() {
        _methodGroups = paged.content;
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

  Future<void> _createOrEditMethodGroup({
    InterventionMethodGroupModel? methodGroup,
  }) async {
    final codeController = TextEditingController(text: methodGroup?.code ?? '');
    final displayedNameViController = TextEditingController(
      text: methodGroup?.displayedName.vi ?? '',
    );
    final displayedNameEnController = TextEditingController(
      text: methodGroup?.displayedName.en ?? '',
    );
    final descViController = TextEditingController(
      text: methodGroup?.description?.vi ?? '',
    );
    final descEnController = TextEditingController(
      text: methodGroup?.description?.en ?? '',
    );
    final minAgeController = TextEditingController(
      text: methodGroup?.minAgeMonths.toString() ?? '12',
    );
    final maxAgeController = TextEditingController(
      text: methodGroup?.maxAgeMonths.toString() ?? '24',
    );
    final isEdit = methodGroup != null;

    final result = await showDialog<InterventionMethodGroupModel>(
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
                  isEdit
                      ? 'Chỉnh sửa nhóm phương pháp'
                      : 'Tạo nhóm phương pháp mới',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                            labelText: 'Mã nhóm phương pháp',
                            border: OutlineInputBorder(),
                            hintText: 'VD: SPEECH_EARLY_LEVEL1',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: displayedNameViController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (Tiếng Việt)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: Phát triển nhận thức',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: displayedNameEnController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (Tiếng Anh)',
                            border: OutlineInputBorder(),
                            hintText: 'VD: Cognitive Development',
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
                            hintText: 'VD: 24',
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
                                'VD: <p>Nhóm phương pháp hỗ trợ phát triển nhận thức...</p>',
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
                                'VD: <p>Methods group supporting cognitive development...</p>',
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
                              int.tryParse(maxAgeController.text) ?? 24;

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

                          InterventionMethodGroupModel result;
                          if (isEdit) {
                            result = await _service.updateMethodGroup(
                              groupId: methodGroup.id,
                              code: codeController.text.trim(),
                              displayedName: displayedName,
                              description: description,
                              minAgeMonths: minAgeMonths,
                              maxAgeMonths: maxAgeMonths,
                            );
                          } else {
                            result = await _service.createMethodGroup(
                              code: codeController.text.trim(),
                              displayedName: displayedName,
                              description: description,
                              minAgeMonths: minAgeMonths,
                              maxAgeMonths: maxAgeMonths,
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

  Future<void> _deleteMethodGroup(
    InterventionMethodGroupModel methodGroup,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhóm phương pháp "${methodGroup.displayedName.vi}"?',
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
        await _service.deleteMethodGroup(methodGroup.id);
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa nhóm phương pháp thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhóm phương pháp can thiệp'),
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
        onPressed: () => _createOrEditMethodGroup(),
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

    if (_methodGroups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có nhóm phương pháp nào',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo nhóm phương pháp đầu tiên',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _methodGroups.length,
      itemBuilder: (context, index) {
        final methodGroup = _methodGroups[index];
        return _buildMethodGroupCard(methodGroup);
      },
    );
  }

  Widget _buildMethodGroupCard(InterventionMethodGroupModel methodGroup) {
    final displayedName = methodGroup.displayedName.vi.isNotEmpty
        ? methodGroup.displayedName.vi
        : methodGroup.displayedName.en;
    final displayedDesc =
        methodGroup.description?.vi ?? methodGroup.description?.en ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Check if we're in a web layout context
          final webLayoutProvider = WebLayoutNavigationProvider.of(context);
          
          if (webLayoutProvider != null) {
            // Use web layout navigation (in-place)
            webLayoutProvider.onMethodSelected(methodGroup);
          } else {
            // Use traditional navigation (mobile)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MethodsView(methodGroup: methodGroup),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
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
                        if (methodGroup.code.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            methodGroup.code,
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
                          '${methodGroup.minAgeMonths}-${methodGroup.maxAgeMonths} tháng',
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
                              _createOrEditMethodGroup(
                                methodGroup: methodGroup,
                              );
                              break;
                            case 'delete':
                              _deleteMethodGroup(methodGroup);
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
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
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
                    'Độ tuổi: ${methodGroup.minAgeMonths}-${methodGroup.maxAgeMonths} tháng',
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
      ),
    );
  }
}
