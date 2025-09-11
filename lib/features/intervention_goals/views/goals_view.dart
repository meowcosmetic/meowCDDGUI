import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_config.dart';
import '../models/goal_models.dart';
import '../services/goal_service.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  final InterventionGoalService _service = InterventionGoalService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<InterventionGoalModel> _goals = [];
  int _page = 0;
  final int _size = 10;

  @override
  void initState() {
    super.initState();
    print('🎯 GoalsView initState called!'); // Debug log
    _load();
  }

  Future<void> _load() async {
    print('🚀 Starting to load goals...'); // Debug log
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      print('📞 Calling service.getGoals...'); // Debug log
      final paged = await _service.getGoals(page: _page, size: _size);
      print('✅ Service returned ${paged.content.length} goals'); // Debug log
      setState(() {
        _goals = paged.content;
      });
    } catch (e) {
      print('❌ Error in _load: $e'); // Debug log
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

  Future<void> _createOrEditGoal({InterventionGoalModel? goal}) async {
    final nameController = TextEditingController(text: goal?.name ?? '');
    final displayedNameViController = TextEditingController(text: goal?.displayedName.vi ?? '');
    final displayedNameEnController = TextEditingController(text: goal?.displayedName.en ?? '');
    final descViController = TextEditingController(text: goal?.description?.vi ?? '');
    final descEnController = TextEditingController(text: goal?.description?.en ?? '');
    final categoryController = TextEditingController(text: goal?.category ?? '');
    final isEdit = goal != null;

    final result = await showDialog<InterventionGoalModel>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Sửa mục tiêu can thiệp' : 'Thêm mục tiêu can thiệp',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên (name)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: displayedNameViController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (VI)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: displayedNameEnController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị (EN)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Danh mục (category)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descViController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả (VI) - Có thể dùng HTML',
                            border: OutlineInputBorder(),
                            hintText: 'Ví dụ: <p>Mô tả mục tiêu <strong>can thiệp</strong></p>\n<ul><li>Mục tiêu 1</li><li>Mục tiêu 2</li></ul>',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descEnController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả (EN) - Có thể dùng HTML',
                            border: OutlineInputBorder(),
                            hintText: 'Example: <p>Intervention goal <strong>description</strong></p>\n<ul><li>Goal 1</li><li>Goal 2</li></ul>',
                          ),
                          maxLines: 4,
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
                      onPressed: () {
                        if (nameController.text.trim().isEmpty || 
                            displayedNameViController.text.trim().isEmpty || 
                            displayedNameEnController.text.trim().isEmpty ||
                            categoryController.text.trim().isEmpty) return;
                        final payload = InterventionGoalModel(
                          id: isEdit ? goal!.id : '',
                          name: nameController.text.trim(),
                          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
                          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
                              ? null
                              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
                          category: categoryController.text.trim(),
                          targets: isEdit ? goal!.targets : [],
                          createdAt: isEdit ? goal!.createdAt : '',
                          updatedAt: isEdit ? goal!.updatedAt : '',
                        );
                        Navigator.pop(context, payload);
                      },
                      child: Text(isEdit ? 'Lưu' : 'Thêm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    try {
      if (isEdit) {
        final updated = await _service.updateGoal(
          goalId: goal!.id,
          name: nameController.text.trim(),
          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
              ? null
              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
          category: categoryController.text.trim(),
        );
        setState(() {
          _goals = _goals.map((g) => g.id == goal.id ? updated : g).toList();
        });
      } else {
        final created = await _service.createGoal(
          name: nameController.text.trim(),
          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
              ? null
              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
          category: categoryController.text.trim(),
        );
        setState(() {
          _goals = [created, ..._goals];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _deleteGoal(InterventionGoalModel goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu can thiệp'),
        content: Text('Bạn có chắc muốn xóa "${goal.displayedName.vi}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteGoal(goal.id);
      setState(() {
        _goals = _goals.where((g) => g.id != goal.id).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _viewGoalDetails(InterventionGoalModel goal) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.displayedName.vi),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh mục: ${goal.category}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (goal.description != null) ...[
                  Text(
                    'Mô tả:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Html(
                    data: goal.description!.vi,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                      ),
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Mục tiêu con (${goal.targets.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (goal.targets.isEmpty)
                  const Text('Chưa có mục tiêu con nào')
                else
                  ...goal.targets.map((target) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.displayedName.vi,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (target.description != null) ...[
                          const SizedBox(height: 4),
                          Html(
                            data: target.description!.vi,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(12),
                              ),
                            },
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(target.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(target.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ưu tiên: ${target.priority}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.warning;
      case 'pending':
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'pending':
      default:
        return 'Chờ thực hiện';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục Tiêu Can Thiệp'),
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
      floatingActionButton: AppConfig.enableInterventions
          ? FloatingActionButton(
              onPressed: () => _createOrEditGoal(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Lỗi: $_errorMessage'))
              : _goals.isEmpty
                  ? const Center(child: Text('Chưa có mục tiêu can thiệp nào'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        final goalTitle = goal.displayedName.vi.isNotEmpty ? goal.displayedName.vi : goal.displayedName.en;
                        final goalDesc = goal.description == null
                            ? null
                            : (goal.description!.vi.isNotEmpty ? goal.description!.vi : goal.description!.en);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Goal header
                              InkWell(
                                onTap: () => _viewGoalDetails(goal),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.flag,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              goalTitle,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.textSecondary,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              goal.category,
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${goal.targets.length} mục tiêu con',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (goalDesc != null) ...[
                                        const SizedBox(height: 8),
                                        Html(
                                          data: goalDesc,
                                          style: {
                                            "body": Style(
                                              margin: Margins.zero,
                                              padding: HtmlPaddings.zero,
                                              fontSize: FontSize(13),
                                              color: AppColors.textSecondary,
                                              lineHeight: LineHeight(1.3),
                                            ),
                                            "p": Style(
                                              margin: Margins.only(bottom: 6),
                                            ),
                                            "strong": Style(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            "em": Style(
                                              fontStyle: FontStyle.italic,
                                            ),
                                            "ul": Style(
                                              margin: Margins.only(left: 16, bottom: 6),
                                            ),
                                            "ol": Style(
                                              margin: Margins.only(left: 16, bottom: 6),
                                            ),
                                            "li": Style(
                                              margin: Margins.only(bottom: 2),
                                            ),
                                          },
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tạo: ${_formatDate(goal.createdAt)}',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Action buttons
                              if (AppConfig.enableInterventions)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _createOrEditGoal(goal: goal),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: BorderSide(color: AppColors.primary),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                          icon: const Icon(Icons.edit, size: 18),
                                          label: const Text('Sửa'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _deleteGoal(goal),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.error,
                                            side: BorderSide(color: AppColors.error),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                          icon: const Icon(Icons.delete_forever, size: 18),
                                          label: const Text('Xóa'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
