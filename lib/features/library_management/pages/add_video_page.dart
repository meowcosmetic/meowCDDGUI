import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/models/domain_models.dart';

class AddVideoPage extends StatefulWidget {
  final List<InterventionDomainModel> domains;

  const AddVideoPage({Key? key, required this.domains}) : super(key: key);

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final _formKey = GlobalKey<FormState>();
  // New schema controllers
  final _urlController = TextEditingController();
  final _titleViController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _descriptionViController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _keywordsController = TextEditingController(); // comma-separated
  final _tagsController = TextEditingController(); // comma-separated
  final _languageController = TextEditingController(text: 'vi');
  final _priorityController = TextEditingController(text: '0');
  final _minAgeController = TextEditingController(); // months
  final _maxAgeController = TextEditingController(); // months
  final _publishedAtController = TextEditingController(); // ISO-8601 string

  List<String> _selectedDomainIds = [];
  bool _isLoading = false;
  bool _isActive = true;
  bool _isFeatured = false;

  // Dropdowns
  String _ageGroup = 'PRESCHOOL';
  String _contentRating = 'G';

  @override
  void dispose() {
    _urlController.dispose();
    _titleViController.dispose();
    _titleEnController.dispose();
    _descriptionViController.dispose();
    _descriptionEnController.dispose();
    _keywordsController.dispose();
    _tagsController.dispose();
    _languageController.dispose();
    _priorityController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _publishedAtController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDomainIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một lĩnh vực')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> tags = _tagsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final String keywords = _keywordsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(', ');

      // Trimmed fields
      final String url = _urlController.text.trim();
      final String titleVi = _titleViController.text.trim();
      final String titleEn = _titleEnController.text.trim();
      final String descriptionVi = _descriptionViController.text.trim();
      final String descriptionEn = _descriptionEnController.text.trim();
      final String language = _languageController.text.trim().isEmpty
          ? 'vi'
          : _languageController.text.trim();

      // Build base payload using nested structures for title/description
      final Map<String, dynamic> videoData = {
        'url': url,
        'title': {'vi': titleVi, 'en': titleEn},
        'description': {'vi': descriptionVi, 'en': descriptionEn},
        'supportedFormatId': 2,
        'developmentalDomainIds': _selectedDomainIds,
        'keywords': keywords,
        'tags': tags,
        'language': language,
        'isActive': _isActive,
      };

      // Optionals - include only when meaningful
      if (_isFeatured) videoData['isFeatured'] = true;
      final int? priority = int.tryParse(_priorityController.text);
      if (priority != null) videoData['priority'] = priority;
      final int? minAge = int.tryParse(_minAgeController.text);
      if (minAge != null) videoData['minAge'] = minAge;
      final int? maxAge = int.tryParse(_maxAgeController.text);
      if (maxAge != null) videoData['maxAge'] = maxAge;
      if (_ageGroup.isNotEmpty) videoData['ageGroup'] = _ageGroup;
      if (_contentRating.isNotEmpty)
        videoData['contentRating'] = _contentRating;
      final String publishedAt = _publishedAtController.text.trim();
      if (publishedAt.isNotEmpty) videoData['publishedAt'] = publishedAt;

      final apiService = ApiService();
      final response = await apiService.createVideo(videoData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm video thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${response.statusCode} - ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('Thêm Video Mới'),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin Video'),
              _buildTextField(
                controller: _urlController,
                label: 'URL Video *',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Vui lòng nhập URL' : null,
              ),

              _buildSectionTitle('Tiêu đề & Mô tả'),
              _buildTextField(
                controller: _titleViController,
                label: 'Tiêu đề (VI) *',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề VI' : null,
              ),
              _buildTextField(
                controller: _titleEnController,
                label: 'Title (EN) *',
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter English title'
                    : null,
              ),
              _buildTextField(
                controller: _descriptionViController,
                label: 'Mô tả (VI) *',
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Vui lòng nhập mô tả VI' : null,
              ),
              _buildTextField(
                controller: _descriptionEnController,
                label: 'Description (EN) *',
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter English description'
                    : null,
              ),

              _buildSectionTitle('Ngôn ngữ'),
              _buildTextField(
                controller: _languageController,
                label: 'Ngôn ngữ nội dung (vi/en)',
              ),

              _buildSectionTitle('Lĩnh vực phát triển'),
              _buildDomainSelection(),

              _buildSectionTitle('Từ khóa & Thẻ'),
              _buildTextField(
                controller: _keywordsController,
                label: 'Keywords (phân tách bằng dấu phẩy)',
              ),
              _buildTextField(
                controller: _tagsController,
                label: 'Tags (phân tách bằng dấu phẩy)',
              ),

              _buildSectionTitle('Thiết lập hiển thị'),
              _buildSwitchRow(
                'Kích hoạt',
                _isActive,
                (v) => setState(() => _isActive = v),
              ),
              _buildSwitchRow(
                'Nổi bật',
                _isFeatured,
                (v) => setState(() => _isFeatured = v),
              ),
              _buildTextField(
                controller: _priorityController,
                label: 'Độ ưu tiên (số nguyên)',
                keyboardType: TextInputType.number,
              ),

              _buildSectionTitle('Độ tuổi & Phân loại'),
              _buildTextField(
                controller: _minAgeController,
                label: 'Tuổi tối thiểu (tháng)',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _maxAgeController,
                label: 'Tuổi tối đa (tháng)',
                keyboardType: TextInputType.number,
              ),
              _buildAgeGroupDropdown(),
              _buildContentRatingDropdown(),

              _buildSectionTitle('Xuất bản'),
              _buildDateTimeField(
                controller: _publishedAtController,
                label: 'Ngày xuất bản (chọn ngày & giờ)',
              ),

              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onTap: () async {
          final now = DateTime.now();
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate == null) return;
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(now),
          );
          if (pickedTime == null) return;
          final combined = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text = combined.toIso8601String();
        },
      ),
    );
  }

  Widget _buildDomainSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lĩnh vực phát triển *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.domains.map((domain) {
              final isSelected = _selectedDomainIds.contains(domain.id);
              return FilterChip(
                label: Text(domain.displayedName.vi),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDomainIds.add(domain.id);
                    } else {
                      _selectedDomainIds.remove(domain.id);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          if (_selectedDomainIds.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Vui lòng chọn ít nhất một lĩnh vực',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // Supported format fixed to 2. No UI needed.

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildAgeGroupDropdown() {
    const groups = [
      'INFANT',
      'TODDLER',
      'PRESCHOOL',
      'SCHOOL_AGE',
      'ADOLESCENT',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _ageGroup,
        items: groups
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (v) => setState(() => _ageGroup = v ?? _ageGroup),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelText: 'Nhóm tuổi',
        ),
      ),
    );
  }

  Widget _buildContentRatingDropdown() {
    const ratings = ['G', 'PG', 'PG-13', 'R', 'NC-17'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _contentRating,
        items: ratings
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => setState(() => _contentRating = v ?? _contentRating),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelText: 'Phân loại nội dung',
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Thêm Video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
