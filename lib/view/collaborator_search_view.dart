import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/collaborator_models.dart';

class CollaboratorSearchView extends StatefulWidget {
  const CollaboratorSearchView({super.key});

  @override
  State<CollaboratorSearchView> createState() => _CollaboratorSearchViewState();
}

class _CollaboratorSearchViewState extends State<CollaboratorSearchView> {
  List<Collaborator> all = [];
  List<Collaborator> filtered = [];
  String q = '';
  String city = 'Tất cả';
  String spec = 'Tất cả';
  String ratingFilter = 'Tất cả';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      all = SampleCollaborators.all();
      filtered = all;
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      Iterable<Collaborator> list = all;
      final query = q.trim().toLowerCase();
      if (query.isNotEmpty) {
        list = list.where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.title.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query));
      }
      if (city != 'Tất cả') {
        list = list.where((c) => c.city == city);
      }
      if (spec != 'Tất cả') {
        list = list.where((c) => c.specialties.contains(spec));
      }
      if (ratingFilter != 'Tất cả') {
        final min = ratingFilter == '4.5+' ? 4.5 : ratingFilter == '4.0+' ? 4.0 : 3.0;
        list = list.where((c) => c.rating >= min);
      }
      filtered = list.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Tìm Cộng Tác Viên'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              onChanged: (v) {
                q = v;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, chức danh, mô tả...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.grey50,
              ),
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
                  _chip('TP', city == 'Tất cả', () { city = 'Tất cả'; _applyFilters(); }),
                  ...SampleCollaborators.cities().where((c) => c != 'Tất cả').map((c) =>
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _chip(c, city == c, () { city = c; _applyFilters(); }),
                    ),
                  ),
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
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _card(filtered[i]),
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
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
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

  Widget _card(Collaborator c) {
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
                  child: Text(c.name.split(' ').last.characters.first.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(c.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                )),
                          ),
                          if (c.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text('Đã xác minh', style: TextStyle(fontSize: 11, color: Colors.green)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(c.title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: c.getRatingColor()),
                          const SizedBox(width: 4),
                          Text('${c.rating} (${c.reviews})', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.place, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(c.city, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const Spacer(),
                          Text(c.getPriceText(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: c.specialties.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(c.getSpecialtyText(s), style: const TextStyle(fontSize: 11)),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Placeholder for call action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gọi ${c.phone}')),
                      );
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Gọi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Placeholder for email action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email ${c.email}')),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Liên hệ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FilterSheet(
          city: city,
          spec: spec,
          rating: ratingFilter,
          onApply: (c, s, r) {
            city = c;
            spec = s;
            ratingFilter = r;
            _applyFilters();
          },
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String city;
  final String spec;
  final String rating;
  final void Function(String, String, String) onApply;

  const _FilterSheet({
    required this.city,
    required this.spec,
    required this.rating,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String city;
  late String spec;
  late String rating;

  @override
  void initState() {
    super.initState();
    city = widget.city;
    spec = widget.spec;
    rating = widget.rating;
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
                  _section('Thành phố', SampleCollaborators.cities(), city, (v) => setState(() => city = v)),
                  const SizedBox(height: 24),
                  _section('Chuyên môn', SampleCollaborators.specialties(), spec, (v) => setState(() => spec = v)),
                  const SizedBox(height: 24),
                  _section('Đánh giá', SampleCollaborators.ratings(), rating, (v) => setState(() => rating = v)),
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
                  widget.onApply(city, spec, rating);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Áp dụng'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _section(String title, List<String> options, String selected, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final s = selected == opt;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: s ? AppColors.primary : AppColors.grey100,
                  border: Border.all(color: s ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt,
                  style: TextStyle(color: s ? AppColors.white : AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
