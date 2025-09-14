import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/models/domain_models.dart';

class AddVideoPage extends StatefulWidget {
  final List<InterventionDomainModel> domains;

  const AddVideoPage({
    Key? key,
    required this.domains,
  }) : super(key: key);

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _durationController = TextEditingController();
  final _languageController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _transcriptController = TextEditingController();

  List<String> _selectedDomainIds = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _durationController.dispose();
    _languageController.dispose();
    _thumbnailUrlController.dispose();
    _videoUrlController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final videoData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'content': _contentController.text,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'language': _languageController.text,
        'thumbnailUrl': _thumbnailUrlController.text,
        'videoUrl': _videoUrlController.text,
        'transcript': _transcriptController.text,
        'developmentalDomainIds': _selectedDomainIds,
      };

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
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
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
              _buildSectionTitle('Thông tin cơ bản'),
              _buildTextField(
                controller: _titleController,
                label: 'Tiêu đề *',
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả *',
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
              ),
              _buildTextField(
                controller: _contentController,
                label: 'Nội dung',
                maxLines: 5,
              ),
              _buildTextField(
                controller: _durationController,
                label: 'Thời lượng (giây)',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _languageController,
                label: 'Ngôn ngữ',
              ),
              _buildSectionTitle('Lĩnh vực phát triển'),
              _buildDomainSelection(),
              _buildSectionTitle('Liên kết'),
              _buildTextField(
                controller: _thumbnailUrlController,
                label: 'URL ảnh thumbnail',
              ),
              _buildTextField(
                controller: _videoUrlController,
                label: 'URL video *',
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập URL video' : null,
              ),
              _buildTextField(
                controller: _transcriptController,
                label: 'Transcript',
                maxLines: 5,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
