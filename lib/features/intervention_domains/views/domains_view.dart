import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_config.dart';
import '../models/domain_models.dart';
import '../services/domain_service.dart';

class DomainsView extends StatefulWidget {
  const DomainsView({super.key});

  @override
  State<DomainsView> createState() => _DomainsViewState();
}

class _DomainsViewState extends State<DomainsView> {
  final InterventionDomainService _service = InterventionDomainService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<InterventionDomainModel> _domains = [];
  int _page = 0;
  final int _size = 10;

  @override
  void initState() {
    super.initState();
    print('🎯 DomainsView initState called!'); // Debug log
    _load();
  }

  Future<void> _load() async {
    print('🚀 Starting to load domains...'); // Debug log
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      print('📞 Calling service.getDomains...'); // Debug log
      final paged = await _service.getDomains(page: _page, size: _size);
      print('✅ Service returned ${paged.content.length} domains'); // Debug log
      setState(() {
        _domains = paged.content;
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

  Future<void> _createOrEditDomain({InterventionDomainModel? domain}) async {
    final nameController = TextEditingController(text: domain?.name ?? '');
    final displayedNameViController = TextEditingController(text: domain?.displayedName.vi ?? '');
    final displayedNameEnController = TextEditingController(text: domain?.displayedName.en ?? '');
    final descViController = TextEditingController(text: domain?.description?.vi ?? '');
    final descEnController = TextEditingController(text: domain?.description?.en ?? '');
    final categoryController = TextEditingController(text: domain?.category ?? '');
    final isEdit = domain != null;

    final result = await showDialog<InterventionDomainModel>(
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
                  isEdit ? 'Sửa lĩnh vực' : 'Thêm lĩnh vực',
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
                            hintText: 'Ví dụ: <p>Mô tả <strong>in đậm</strong></p>\n<ul><li>Điểm 1</li><li>Điểm 2</li></ul>',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descEnController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả (EN) - Có thể dùng HTML',
                            border: OutlineInputBorder(),
                            hintText: 'Example: <p>Description with <strong>bold</strong> text</p>\n<ul><li>Point 1</li><li>Point 2</li></ul>',
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
                        final payload = InterventionDomainModel(
                          id: isEdit ? domain!.id : '',
                          name: nameController.text.trim(),
                          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
                          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
                              ? null
                              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
                          category: categoryController.text.trim(),
                          createdAt: isEdit ? domain!.createdAt : '',
                          updatedAt: isEdit ? domain!.updatedAt : '',
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
        final updated = await _service.updateDomain(
          domainId: domain!.id,
          name: nameController.text.trim(),
          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
              ? null
              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
          category: categoryController.text.trim(),
        );
        setState(() {
          _domains = _domains.map((d) => d.id == domain.id ? updated : d).toList();
        });
      } else {
        final created = await _service.createDomain(
          name: nameController.text.trim(),
          displayedName: LocalizedText(vi: displayedNameViController.text.trim(), en: displayedNameEnController.text.trim()),
          description: (descViController.text.trim().isEmpty && descEnController.text.trim().isEmpty)
              ? null
              : LocalizedText(vi: descViController.text.trim(), en: descEnController.text.trim()),
          category: categoryController.text.trim(),
        );
        setState(() {
          _domains = [created, ..._domains];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _deleteDomain(InterventionDomainModel domain) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lĩnh vực'),
        content: Text('Bạn có chắc muốn xóa "${domain.displayedName.vi}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteDomain(domain.id);
      setState(() {
        _domains = _domains.where((d) => d.id != domain.id).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lĩnh Vực Can Thiệp'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      floatingActionButton: AppConfig.enableInterventionDomains
          ? FloatingActionButton(
              onPressed: () => _createOrEditDomain(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Lỗi: $_errorMessage'))
              : _domains.isEmpty
                  ? const Center(child: Text('Chưa có lĩnh vực nào'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _domains.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final domain = _domains[index];
                        final domainTitle = domain.displayedName.vi.isNotEmpty ? domain.displayedName.vi : domain.displayedName.en;
                        final domainDesc = domain.description == null
                            ? null
                            : (domain.description!.vi.isNotEmpty ? domain.description!.vi : domain.description!.en);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                domainTitle,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              if (domainDesc != null) ...[
                                const SizedBox(height: 6),
                                Html(
                                  data: domainDesc,
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
                                    "h1": Style(
                                      fontSize: FontSize(16),
                                      fontWeight: FontWeight.bold,
                                      margin: Margins.only(bottom: 8),
                                      color: AppColors.textPrimary,
                                    ),
                                    "h2": Style(
                                      fontSize: FontSize(15),
                                      fontWeight: FontWeight.bold,
                                      margin: Margins.only(bottom: 6),
                                      color: AppColors.textPrimary,
                                    ),
                                    "h3": Style(
                                      fontSize: FontSize(14),
                                      fontWeight: FontWeight.bold,
                                      margin: Margins.only(bottom: 4),
                                      color: AppColors.textPrimary,
                                    ),
                                    "blockquote": Style(
                                      margin: Margins.only(left: 16, right: 16, bottom: 6),
                                      padding: HtmlPaddings.only(left: 8, top: 4, bottom: 4),
                                      border: Border(
                                        left: BorderSide(
                                          color: AppColors.primary,
                                          width: 3,
                                        ),
                                      ),
                                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                                    ),
                                  },
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Tạo: ${_formatDate(domain.createdAt)}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 10),
                              if (AppConfig.enableInterventionDomains)
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _createOrEditDomain(domain: domain),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Sửa'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () => _deleteDomain(domain),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: BorderSide(color: AppColors.error),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      icon: const Icon(Icons.delete_forever, size: 18),
                                      label: const Text('Xóa'),
                                    ),
                                  ],
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
