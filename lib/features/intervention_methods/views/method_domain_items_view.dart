import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../models/method_group_models.dart';
import '../../intervention_domains/models/domain_item_models.dart' as di;
import '../../intervention_domains/services/domain_item_service.dart';
import '../../../models/api_service.dart';
import '../../intervention_goals/views/criteria_list_view.dart';

class MethodDomainItemsView extends StatefulWidget {
  final InterventionMethodModel method;
  const MethodDomainItemsView({super.key, required this.method});

  @override
  State<MethodDomainItemsView> createState() => _MethodDomainItemsViewState();
}

class _MethodDomainItemsViewState extends State<MethodDomainItemsView> {
  final DevelopmentalDomainItemService _service =
      DevelopmentalDomainItemService();
  bool _loading = false;
  String? _error;
  List<di.DevelopmentalDomainItemModel> _items = [];
  Map<String, String> _domainNames = {};

  @override
  void initState() {
    super.initState();
    _loadDomains();
    _load();
  }

  Future<void> _loadDomains() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDomains = prefs.getString('cached_domains');

      if (cachedDomains != null) {
        final domains = jsonDecode(cachedDomains) as List<dynamic>;
        final domainMap = <String, String>{};
        for (final domain in domains) {
          final id = domain['id']?.toString() ?? '';
          final displayedName = domain['displayedName'];
          String name = '';
          if (displayedName is Map) {
            final m = displayedName.cast<String, dynamic>();
            name = (m['vi'] ?? m['en'] ?? '').toString();
          } else if (displayedName != null) {
            name = displayedName.toString();
          }
          if (id.isNotEmpty && name.isNotEmpty) {
            domainMap[id] = name;
          }
        }
        setState(() => _domainNames = domainMap);
      } else {
        // Load from API and cache
        final api = ApiService();
        final resp = await api.getNeonDevelopmentalDomainsPaginated(
          page: 0,
          size: 50,
        );
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          List<dynamic> list;
          if (body is Map<String, dynamic> && body['content'] is List) {
            list = body['content'] as List<dynamic>;
          } else if (body is List) {
            list = body;
          } else {
            list = [];
          }

          // Cache domains
          await prefs.setString('cached_domains', jsonEncode(list));

          // Build domain names map
          final domainMap = <String, String>{};
          for (final domain in list) {
            final id = domain['id']?.toString() ?? '';
            final displayedName = domain['displayedName'];
            String name = '';
            if (displayedName is Map) {
              final m = displayedName.cast<String, dynamic>();
              name = (m['vi'] ?? m['en'] ?? '').toString();
            } else if (displayedName != null) {
              name = displayedName.toString();
            }
            if (id.isNotEmpty && name.isNotEmpty) {
              domainMap[id] = name;
            }
          }
          setState(() => _domainNames = domainMap);
        }
      }
    } catch (e) {
      // Ignore errors, fallback to showing domainId
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _service.getItems(page: 0, size: 50);
      setState(() => _items = page.content);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openEditor({di.DevelopmentalDomainItemModel? item}) async {
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
        title: const Text('Xóa mục tiêu lớn'),
        content: const Text('Bạn có chắc muốn xóa mục này?'),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa'), backgroundColor: Colors.green),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToCriteria(di.DevelopmentalDomainItemModel item) async {
    print('Clicked large goal ID: ${item.id}');
    print(
      'Large goal title: ${item.title?.vi ?? item.title?.en ?? item.name ?? 'Mục tiêu lớn'}',
    );
    print('Large goal domainId: ${item.domainId}');

    final title = item.title?.vi.isNotEmpty == true
        ? item.title!.vi
        : (item.title?.en ?? item.name ?? 'Mục tiêu lớn');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CriteriaListView(domainItemId: item.id, domainItemTitle: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.method.displayedName.vi.isNotEmpty
        ? widget.method.displayedName.vi
        : widget.method.displayedName.en;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mục tiêu lớn - ${title}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            tooltip: 'Thêm mục tiêu lớn',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const _DomainItemEditPage()),
              );
              if (created == true) {
                _load();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: InkWell(
                      onTap: () => _navigateToCriteria(item),
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
                                    (item.title?.vi.isNotEmpty == true
                                        ? item.title!.vi
                                        : (item.title?.en ?? item.name ?? '')),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if ((item.domainId ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Domain: ${_domainNames[item.domainId] ?? item.domainId}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final updated = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            _DomainItemEditPage(item: item),
                                      ),
                                    );
                                    if (updated == true) {
                                      _load();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(item.id),
                                ),
                              ],
                            ),
                          ],
                        ),
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
  final di.DevelopmentalDomainItemModel? item;
  const _DomainItemEditPage({this.item});

  @override
  State<_DomainItemEditPage> createState() => _DomainItemEditPageState();
}

class _DomainItemEditPageState extends State<_DomainItemEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleVi = TextEditingController();
  final _titleEn = TextEditingController();
  String? _selectedDomainId;
  List<Map<String, dynamic>> _domains = [];
  bool _loadingDomains = false;
  bool _submitting = false;
  final DevelopmentalDomainItemService _service =
      DevelopmentalDomainItemService();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleVi.text = item.title?.vi ?? '';
      _titleEn.text = item.title?.en ?? '';
      _selectedDomainId = item.domainId;
    }
    _loadDomains();
  }

  Future<void> _loadDomains() async {
    if (_loadingDomains) return;
    setState(() => _loadingDomains = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDomains = prefs.getString('cached_domains');

      if (cachedDomains != null) {
        final domains = jsonDecode(cachedDomains) as List<dynamic>;
        setState(() {
          _domains = domains
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
        });
      } else {
        // Load from API and cache
        final resp = await _api.getNeonDevelopmentalDomainsPaginated(
          page: 0,
          size: 50,
        );
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          List<dynamic> list;
          if (body is Map<String, dynamic> && body['content'] is List) {
            list = body['content'] as List<dynamic>;
          } else if (body is List) {
            list = body;
          } else {
            list = [];
          }

          // Cache domains
          await prefs.setString('cached_domains', jsonEncode(list));

          setState(() {
            _domains = list
                .map((e) => (e as Map).cast<String, dynamic>())
                .toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingDomains = false);
    }
  }

  @override
  void dispose() {
    _titleVi.dispose();
    _titleEn.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final title = di.LocalizedText(
        vi: _titleVi.text.trim(),
        en: _titleEn.text.trim(),
      );
      final domainId = _selectedDomainId;
      if (domainId == null || domainId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn Domain'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (widget.item == null) {
        await _service.createItem(title: title, domainId: domainId);
      } else {
        await _service.updateItem(
          id: widget.item!.id,
          title: title,
          domainId: domainId,
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
        title: Text(
          widget.item == null ? 'Thêm mục tiêu lớn' : 'Sửa mục tiêu lớn',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: const Text(
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
                controller: _titleVi,
                decoration: const InputDecoration(
                  labelText: 'Title - VI',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleEn,
                decoration: const InputDecoration(
                  labelText: 'Title - EN',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                ),
                child: _loadingDomains
                    ? const SizedBox(
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          items: _domains.map((d) {
                            final id = (d['id'] ?? '').toString();
                            String label = '';
                            final dn = d['displayedName'];
                            if (dn is Map) {
                              final m = dn.cast<String, dynamic>();
                              label = (m['vi'] ?? m['en'] ?? '').toString();
                            } else if (dn != null) {
                              label = dn.toString();
                            }
                            return DropdownMenuItem<String?>(
                              value: id,
                              child: Text(
                                label.isNotEmpty ? label : 'Domain $id',
                              ),
                            );
                          }).toList(),
                          value: _selectedDomainId,
                          hint: const Text('Chọn domain'),
                          onChanged: (val) =>
                              setState(() => _selectedDomainId = val),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
