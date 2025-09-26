import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../../models/intervention_post.dart';
import '../../intervention_domains/models/domain_models.dart';

class AddPostPage extends StatefulWidget {
  final List<InterventionDomainModel> domains;

  const AddPostPage({Key? key, required this.domains}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _authorController = TextEditingController();
  final _versionController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _targetAgeMinController = TextEditingController();
  final _targetAgeMaxController = TextEditingController();
  final _durationController = TextEditingController();

  // Linked selections
  String? _selectedCriteriaId; // store raw id as string for flexibility
  String? _selectedProgramId; // store raw id as string for flexibility
  List<Map<String, dynamic>> _criteriaOptions = [];
  List<Map<String, dynamic>> _programOptions = [];
  bool _isLoadingCriteria = false;
  bool _isLoadingPrograms = false;

  PostType _selectedPostType = PostType.INTERVENTION_METHOD;
  bool _isPublished = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _authorController.dispose();
    _versionController.dispose();
    _difficultyController.dispose();
    _targetAgeMinController.dispose();
    _targetAgeMaxController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDomainOptions();
    _loadProgramOptions();
  }

  Future<void> _loadDomainOptions() async {
    if (mounted) setState(() => _isLoadingCriteria = true);
    try {
      final api = ApiService();
      final resp = await api.getDevelopmentalDomains();
      if (resp.statusCode == 200) {
        final dynamic data = jsonDecode(resp.body);
        final List<dynamic> list = data is List
            ? data
            : (data is Map<String, dynamic> && data['content'] is List)
            ? data['content'] as List
            : <dynamic>[];
        final options = list
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        if (mounted) {
          setState(() {
            _criteriaOptions = options;
          });
        }
      } else {
        if (mounted) setState(() => _criteriaOptions = []);
      }
    } catch (_) {
      if (mounted) setState(() => _criteriaOptions = []);
    } finally {
      if (mounted) setState(() => _isLoadingCriteria = false);
    }
  }

  Future<void> _loadProgramOptions() async {
    if (mounted) setState(() => _isLoadingPrograms = true);
    try {
      final api = ApiService();
      final resp = await api.getDevelopmentalPrograms();
      if (resp.statusCode == 200) {
        final dynamic data = jsonDecode(resp.body);
        final List<dynamic> list = data is List
            ? data
            : (data is Map<String, dynamic> && data['content'] is List)
            ? data['content'] as List
            : <dynamic>[];
        final options = list
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        if (mounted) {
          setState(() {
            _programOptions = options;
          });
        }
      } else {
        if (mounted) setState(() => _programOptions = []);
      }
    } catch (_) {
      if (mounted) setState(() => _programOptions = []);
    } finally {
      if (mounted) setState(() => _isLoadingPrograms = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo content JSON từ nội dung
      final content = {
        'text': _contentController.text,
        'type': 'text',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final interventionPost = InterventionPost(
        title: _titleController.text,
        content: content,
        postType: _selectedPostType,
        difficultyLevel: int.tryParse(_difficultyController.text),
        targetAgeMinMonths: int.tryParse(_targetAgeMinController.text),
        targetAgeMaxMonths: int.tryParse(_targetAgeMaxController.text),
        estimatedDurationMinutes: int.tryParse(_durationController.text),
        tags: _tagsController.text.isNotEmpty ? _tagsController.text : null,
        isPublished: _isPublished,
        author: _authorController.text.isNotEmpty
            ? _authorController.text
            : null,
        version: _versionController.text.isNotEmpty
            ? _versionController.text
            : null,
        criteriaId: int.tryParse(_selectedCriteriaId ?? ''),
        programId: int.tryParse(_selectedProgramId ?? ''),
      );

      final apiService = ApiService();
      final response = await apiService.createInterventionPost(
        interventionPost.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm bài post can thiệp thành công!'),
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
        title: const Text('Thêm Bài Post Can Thiệp'),
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
              _buildSectionTitle('Thông tin cơ bản'),
              _buildTextField(
                controller: _titleController,
                label: 'Tiêu đề *',
                validator: (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
              ),
              _buildTextField(
                controller: _contentController,
                label: 'Nội dung *',
                maxLines: 10,
                validator: (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập nội dung' : null,
              ),
              _buildTextField(controller: _authorController, label: 'Tác giả'),
              _buildTextField(
                controller: _versionController,
                label: 'Phiên bản *',
                hintText: 'Ví dụ: 1.0',
                validator: (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập phiên bản' : null,
              ),
              _buildTextField(
                controller: _tagsController,
                label: 'Tags (phân cách bằng dấu phẩy)',
                hintText: 'Ví dụ: giáo dục, trẻ em, phát triển',
              ),

              _buildSectionTitle('Loại bài post'),
              _buildPostTypeSelection(),

              _buildSectionTitle('Thông tin can thiệp'),
              _buildTextField(
                controller: _difficultyController,
                label: 'Mức độ khó (1-5)',
                keyboardType: TextInputType.number,
                hintText: '1 = Dễ, 5 = Khó',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _targetAgeMinController,
                      label: 'Độ tuổi tối thiểu (tháng)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _targetAgeMaxController,
                      label: 'Độ tuổi tối đa (tháng)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _durationController,
                label: 'Thời gian ước tính (phút)',
                keyboardType: TextInputType.number,
                hintText: 'Ví dụ: 30',
              ),

              _buildSectionTitle('Liên kết'),
              Row(
                children: [
                  Expanded(child: _buildCriteriaDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProgramDropdown()),
                ],
              ),

              _buildSectionTitle('Trạng thái'),
              _buildPublishedToggle(),

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
    String? hintText,
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
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại bài post *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PostType.values.map((postType) {
              final isSelected = _selectedPostType == postType;
              return FilterChip(
                label: Text(postType.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPostType = postType;
                    });
                  }
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedToggle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: _isPublished,
            onChanged: (value) {
              setState(() {
                _isPublished = value ?? false;
              });
            },
            activeColor: AppColors.primary,
          ),
          const Text(
            'Xuất bản ngay',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
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
                'Thêm Bài Post Can Thiệp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCriteriaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Tiêu chí (developmental-domain)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DropdownButtonFormField<String>(
          value:
              (_criteriaOptions
                  .map((e) => (e['id'] ?? '').toString())
                  .toSet()
                  .contains(_selectedCriteriaId))
              ? _selectedCriteriaId
              : null,
          isExpanded: true,
          items: _criteriaOptions.map((opt) {
            final idStr = (opt['id'] ?? '').toString();
            final dnRaw = opt['displayedName'];
            Map<String, dynamic>? dn;
            if (dnRaw is Map) {
              dn = dnRaw.cast<String, dynamic>();
            } else if (dnRaw is String) {
              try {
                final parsed = jsonDecode(dnRaw);
                if (parsed is Map<String, dynamic>) dn = parsed;
              } catch (_) {}
            }
            String label = (dn?['vi'] ?? '').toString();
            if (label.isEmpty) label = (dn?['en'] ?? '').toString();
            return DropdownMenuItem<String>(value: idStr, child: Text(label));
          }).toList(),
          onChanged: (v) => setState(() => _selectedCriteriaId = v),
          hint: const Text('Chọn tiêu chí'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          iconEnabledColor: AppColors.primary,
          style: const TextStyle(color: AppColors.textPrimary),
          menuMaxHeight: 320,
        ),
        if (_isLoadingCriteria)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildProgramDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Chương trình (developmental-program)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DropdownButtonFormField<String>(
          value:
              (_programOptions
                  .map((e) => (e['id'] ?? '').toString())
                  .toSet()
                  .contains(_selectedProgramId))
              ? _selectedProgramId
              : null,
          isExpanded: true,
          items: _programOptions.map((opt) {
            final idStr = (opt['id'] ?? '').toString();
            final dn = opt['name'];
            String label = (dn?['vi'] ?? '').toString();
            if (label.isEmpty) label = (dn?['en'] ?? '').toString();
            return DropdownMenuItem<String>(value: idStr, child: Text(label));
          }).toList(),
          onChanged: (v) => setState(() => _selectedProgramId = v),
          hint: const Text('Chọn chương trình'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          iconEnabledColor: AppColors.primary,
          style: const TextStyle(color: AppColors.textPrimary),
          menuMaxHeight: 320,
        ),
        if (_isLoadingPrograms)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
