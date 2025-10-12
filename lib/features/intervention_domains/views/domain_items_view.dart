import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../models/domain_item_models.dart';
import '../services/domain_item_service.dart';

class DomainItemsView extends StatefulWidget {
  const DomainItemsView({super.key});

  @override
  State<DomainItemsView> createState() => _DomainItemsViewState();
}

class _DomainItemsViewState extends State<DomainItemsView> {
  final DevelopmentalDomainItemService _service =
      DevelopmentalDomainItemService();

  bool _isLoading = false;
  PaginatedDomainItems? _page;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getItems(page: _pageIndex, size: 10);
      setState(() => _page = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openEditor({DevelopmentalDomainItemModel? item}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _DomainItemEditPage(item: item)),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục'),
        content: const Text('Bạn có chắc chắn muốn xóa mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.deleteItem(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa'), backgroundColor: Colors.green),
      );
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developmental Domain Items'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _page == null
          ? const Center(child: Text('Không có dữ liệu'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _page!.content.length,
                itemBuilder: (context, index) {
                  final item = _page!.content[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('VI: ${item.displayedName.vi}'),
                                Text('EN: ${item.displayedName.en}'),
                                if (item.category != null &&
                                    item.category!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text('Category: ${item.category}'),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openEditor(item: item),
                                tooltip: 'Sửa',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(item.id),
                                tooltip: 'Xóa',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _DomainItemEditPage extends StatefulWidget {
  final DevelopmentalDomainItemModel? item;
  const _DomainItemEditPage({this.item});

  @override
  State<_DomainItemEditPage> createState() => _DomainItemEditPageState();
}

class _DomainItemEditPageState extends State<_DomainItemEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _vi = TextEditingController();
  final _en = TextEditingController();
  final _descVi = TextEditingController();
  final _descEn = TextEditingController();
  final _category = TextEditingController();

  bool _submitting = false;
  final DevelopmentalDomainItemService _service =
      DevelopmentalDomainItemService();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _name.text = item.name;
      _vi.text = item.displayedName.vi;
      _en.text = item.displayedName.en;
      _descVi.text = item.description?.vi ?? '';
      _descEn.text = item.description?.en ?? '';
      _category.text = item.category ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _vi.dispose();
    _en.dispose();
    _descVi.dispose();
    _descEn.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final name = _name.text.trim();
      final displayed = LocalizedText(vi: _vi.text.trim(), en: _en.text.trim());
      final hasDesc =
          _descVi.text.trim().isNotEmpty || _descEn.text.trim().isNotEmpty;
      final desc = hasDesc
          ? LocalizedText(vi: _descVi.text.trim(), en: _descEn.text.trim())
          : null;
      final category = _category.text.trim().isEmpty
          ? null
          : _category.text.trim();

      if (widget.item == null) {
        await _service.createItem(
          name: name,
          displayedName: displayed,
          description: desc,
          category: category,
        );
      } else {
        await _service.updateItem(
          id: widget.item!.id,
          name: name,
          displayedName: displayed,
          description: desc,
          category: category,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Thêm mục' : 'Sửa mục'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name (unique)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vi,
                decoration: const InputDecoration(
                  labelText: 'Displayed Name - VI',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _en,
                decoration: const InputDecoration(
                  labelText: 'Displayed Name - EN',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descVi,
                minLines: 2,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Description VI',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descEn,
                minLines: 2,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Description EN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
