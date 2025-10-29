import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/collaborator_models.dart';
import '../services/collaborator_service.dart';
import 'collaborator_form_dialog.dart';

class CollaboratorSearchView extends StatefulWidget {
  const CollaboratorSearchView({super.key});

  @override
  State<CollaboratorSearchView> createState() => _CollaboratorSearchViewState();
}

class _CollaboratorSearchViewState extends State<CollaboratorSearchView> {
  List<CollaboratorDetail> all = [];
  List<CollaboratorDetail> filtered = [];
  String q = '';
  String city = 'Tất cả';
  String spec = 'Tất cả';
  String ratingFilter = 'Tất cả';
  String statusFilter = 'Tất cả';
  bool isLoading = true;
  int currentPage = 0;
  int totalPages = 0;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await CollaboratorService.getCollaborators(
        page: currentPage,
        size: 10,
      );
      
      final List<dynamic> collaboratorsData = response['content'] ?? [];
      final List<CollaboratorDetail> collaborators = collaboratorsData
          .map((data) => CollaboratorDetail.fromJson(data))
          .toList();

      setState(() {
        if (currentPage == 0) {
          all = collaborators;
        } else {
          all.addAll(collaborators);
        }
        filtered = all;
        totalPages = response['totalPages'] ?? 0;
        hasMoreData = currentPage < totalPages - 1;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      Iterable<CollaboratorDetail> list = all;
      final query = q.trim().toLowerCase();
      if (query.isNotEmpty) {
        list = list.where(
          (c) =>
              c.specialization.toLowerCase().contains(query) ||
              c.organization.toLowerCase().contains(query) ||
              c.roleName.toLowerCase().contains(query) ||
              c.notes.vi.toLowerCase().contains(query) ||
              c.notes.en.toLowerCase().contains(query),
        );
      }
      if (statusFilter != 'Tất cả') {
        final status = statusFilter == 'Hoạt động'
            ? CollaboratorStatus.ACTIVE
            : statusFilter == 'Không hoạt động'
            ? CollaboratorStatus.INACTIVE
            : CollaboratorStatus.PENDING;
        list = list.where((c) => c.status == status);
      }
      filtered = list.toList();
    });
  }

  void _searchCollaborators() async {
    if (q.trim().isEmpty) {
      _load();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await CollaboratorService.searchCollaborators(
        keyword: q.trim(),
        page: 0,
        size: 10,
      );
      
      final List<dynamic> collaboratorsData = response['content'] ?? [];
      final List<CollaboratorDetail> collaborators = collaboratorsData
          .map((data) => CollaboratorDetail.fromJson(data))
          .toList();

      setState(() {
        all = collaborators;
        filtered = collaborators;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tìm kiếm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadMore() async {
    if (!hasMoreData || isLoading) return;

    setState(() {
      currentPage++;
    });

    try {
      final response = await CollaboratorService.getCollaborators(
        page: currentPage,
        size: 10,
      );
      
      final List<dynamic> collaboratorsData = response['content'] ?? [];
      final List<CollaboratorDetail> collaborators = collaboratorsData
          .map((data) => CollaboratorDetail.fromJson(data))
          .toList();

      setState(() {
        all.addAll(collaborators);
        filtered = all;
        totalPages = response['totalPages'] ?? 0;
        hasMoreData = currentPage < totalPages - 1;
      });
    } catch (e) {
      setState(() {
        currentPage--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải thêm dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addCollaborator() async {
    final result = await showDialog<CreateCollaboratorRequest>(
      context: context,
      builder: (context) => CollaboratorFormDialog(
        onCreate: (request) async {
          try {
            await CollaboratorService.createCollaborator(request);
            _load(); // Reload data
          } catch (e) {
            rethrow;
          }
        },
        onUpdate: (id, request) async {
          // This won't be called in add mode
        },
      ),
    );
  }

  void _editCollaborator(CollaboratorDetail collaborator) async {
    await showDialog(
      context: context,
      builder: (context) => CollaboratorFormDialog(
        collaborator: collaborator,
        onCreate: (request) async {
          // This won't be called in edit mode
        },
        onUpdate: (id, request) async {
          try {
            await CollaboratorService.updateCollaborator(id, request);
            _load(); // Reload data
          } catch (e) {
            rethrow;
          }
        },
      ),
    );
  }

  void _deleteCollaborator(CollaboratorDetail collaborator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa cộng tác viên "${collaborator.specialization}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CollaboratorService.deleteCollaborator(collaborator.collaboratorId);
        _load(); // Reload data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa cộng tác viên thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa cộng tác viên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Quản Lý Cộng Tác Viên'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCollaborator,
            tooltip: 'Thêm cộng tác viên',
          ),
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilters),
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) {
                      q = v;
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm theo chuyên môn, tổ chức, vai trò...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _searchCollaborators,
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          // Quick filters row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Tất cả', statusFilter == 'Tất cả', () {
                    statusFilter = 'Tất cả';
                    _applyFilters();
                  }),
                  const SizedBox(width: 8),
                  _chip('Hoạt động', statusFilter == 'Hoạt động', () {
                    statusFilter = 'Hoạt động';
                    _applyFilters();
                  }),
                  const SizedBox(width: 8),
                  _chip('Chờ duyệt', statusFilter == 'Chờ duyệt', () {
                    statusFilter = 'Chờ duyệt';
                    _applyFilters();
                  }),
                  const SizedBox(width: 8),
                  _chip('Không hoạt động', statusFilter == 'Không hoạt động', () {
                    statusFilter = 'Không hoạt động';
                    _applyFilters();
                  }),
                ],
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? _empty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length + (hasMoreData ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == filtered.length) {
                        return _loadMoreButton();
                      }
                      return _card(filtered[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _card(CollaboratorDetail c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    c.specialization.isNotEmpty 
                        ? c.specialization[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.specialization,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.getStatusColor().withValues(alpha: 0.1),
                              border: Border.all(color: c.getStatusColor()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c.getStatusText(),
                              style: TextStyle(
                                fontSize: 11,
                                color: c.getStatusColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.roleName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.organization,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.work,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${c.experienceYears} năm',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (c.certification.vi.isNotEmpty || c.certification.en.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chứng chỉ:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (c.certification.vi.isNotEmpty)
                      Text(
                        c.certification.vi,
                        style: const TextStyle(fontSize: 11),
                      ),
                    if (c.certification.en.isNotEmpty)
                      Text(
                        c.certification.en,
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (c.availability.vi.isNotEmpty || c.availability.en.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời gian khả dụng:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (c.availability.vi.isNotEmpty)
                      Text(
                        c.availability.vi,
                        style: const TextStyle(fontSize: 11),
                      ),
                    if (c.availability.en.isNotEmpty)
                      Text(
                        c.availability.en,
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editCollaborator(c),
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteCollaborator(c),
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('Không tìm thấy cộng tác viên phù hợp'),
        ],
      ),
    );
  }

  Widget _loadMoreButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: hasMoreData ? _loadMore : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Tải thêm'),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FilterSheet(
          status: statusFilter,
          onApply: (s) {
            statusFilter = s;
            _applyFilters();
          },
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String status;
  final void Function(String) onApply;

  const _FilterSheet({
    required this.status,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    'Trạng thái',
                    ['Tất cả', 'Hoạt động', 'Chờ duyệt', 'Không hoạt động'],
                    status,
                    (v) => setState(() => status = v),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(status);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Áp dụng'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final s = selected == opt;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: s ? AppColors.primary : AppColors.grey100,
                  border: Border.all(
                    color: s ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: s ? AppColors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
