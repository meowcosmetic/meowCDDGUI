import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/models/domain_models.dart';
import 'web_file_input.dart';

class AddBookPage extends StatefulWidget {
  final List<InterventionDomainModel> domains;

  const AddBookPage({
    Key? key,
    required this.domains,
  }) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _summaryController = TextEditingController();
  String? _selectedFilePath;
  final _filePathController = TextEditingController();
  dynamic _selectedFile; // Lưu trữ file thực tế
  final _pageCountController = TextEditingController();
  final _languageController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _contentUploadedByController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  final _downloadUrlController = TextEditingController();
  final _previewUrlController = TextEditingController();

  List<String> _selectedDomainIds = [];
  bool _isLoading = false;
  bool _isActive = true;
  String _ageGroupValue = '7-12';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
    _filePathController.dispose();
    _pageCountController.dispose();
    _languageController.dispose();
    _publicationYearController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _tagsController.dispose();
    _contentUploadedByController.dispose();
    _coverImageUrlController.dispose();
    _downloadUrlController.dispose();
    _previewUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate selected file and size to avoid 413 (Request Entity Too Large)
      if (_selectedFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn file nội dung sách'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Determine file size (bytes)
      int fileSizeBytes = 0;
      try {
        if (kIsWeb) {
          // html.File has .size
          fileSizeBytes = (_selectedFile.size as int);
        } else {
          // PlatformFile has .size
          fileSizeBytes = (_selectedFile.size as int);
        }
      } catch (_) {
        fileSizeBytes = 0;
      }

      // Enforce a client-side max to prevent server 413. Adjust as needed.
      const int maxUploadBytes = 15 * 1024 * 1024; // 15 MB
      if (fileSizeBytes > maxUploadBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File quá lớn (${(fileSizeBytes / (1024*1024)).toStringAsFixed(1)} MB). Giới hạn hiện tại là 15 MB.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final bookData = {
        // Basic fields
        'title': _titleController.text,
        'author': _authorController.text,
        'description': _descriptionController.text,
        'isbn': _isbnController.text,
        'publicationYear': int.tryParse(_publicationYearController.text) ?? DateTime.now().year,
        'pageCount': int.tryParse(_pageCountController.text) ?? 0,
        'language': _languageController.text,
        // Sample-specific fields
        'ageGroup': _ageGroupValue, // e.g., '7-12'
        'minAge': int.tryParse(_minAgeController.text) ?? 0,
        'maxAge': int.tryParse(_maxAgeController.text) ?? 0,
        'summary': _summaryController.text,
        'tags': _tagsController.text, // comma-separated string
        'isActive': _isActive,
        'supportedFormatId': 1,
        'developmentalDomainIds': _selectedDomainIds.join(','),
        'contentUploadedBy': _contentUploadedByController.text,
        // Optional legacy fields for server compatibility (may be ignored)
        'contentMimeType': 'application/pdf',
      };

      final apiService = ApiService();
      final response = await apiService.createBookWithFile(bookData, _selectedFile);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm sách thành công!'),
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
        title: const Text('Thêm Sách Mới'),
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
                controller: _authorController,
                label: 'Tác giả *',
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tác giả' : null,
              ),
              _buildTextField(
                controller: _publisherController,
                label: 'Nhà xuất bản',
              ),
              _buildTextField(
                controller: _isbnController,
                label: 'ISBN',
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả *',
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
              ),
              _buildFileUploadField(),
              _buildTextField(
                controller: _pageCountController,
                label: 'Số trang',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _summaryController,
                label: 'Tóm tắt',
                maxLines: 3,
              ),
              _buildTextField(
                controller: _languageController,
                label: 'Ngôn ngữ',
              ),
              _buildTextField(
                controller: _publicationYearController,
                label: 'Năm xuất bản',
                keyboardType: TextInputType.number,
              ),
              _buildAgeGroupAndRange(),
              _buildTextField(
                controller: _minAgeController,
                label: 'Min age',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _maxAgeController,
                label: 'Max age',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _tagsController,
                label: 'Tags (phân tách bằng dấu phẩy)',
                hintText: 'thiếu_nhi,kinh_điển',
              ),
              _buildSectionTitle('Lĩnh vực'),
              _buildDomainSelection(),
              SwitchListTile(
                title: const Text('Kích hoạt (isActive)'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              _buildSectionTitle('Liên kết'),
              _buildTextField(
                controller: _coverImageUrlController,
                label: 'URL ảnh bìa',
              ),
              _buildTextField(
                controller: _downloadUrlController,
                label: 'URL tải xuống',
              ),
              _buildTextField(
                controller: _previewUrlController,
                label: 'URL xem trước',
              ),
              _buildTextField(
                controller: _contentUploadedByController,
                label: 'Uploaded by (email)',
                hintText: 'admin@example.com',
              ),
              const SizedBox(height: 32),
              _buildActionButtons(),
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

  Widget _buildFileUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Nội dung (File)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kIsWeb ? Colors.blue[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kIsWeb ? 'Web' : 'Mobile',
                  style: TextStyle(
                    fontSize: 10,
                    color: kIsWeb ? Colors.blue[700] : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _pickFileAny,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFilePath != null 
                            ? _selectedFilePath!.split('/').last
                            : 'Chọn file nội dung sách',
                        style: TextStyle(
                          color: _selectedFilePath != null 
                              ? Colors.black 
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_selectedFilePath != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilePath = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAgeGroupAndRange() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _ageGroupValue,
              items: const [
                DropdownMenuItem(value: '3-6', child: Text('3-6')),
                DropdownMenuItem(value: '7-12', child: Text('7-12')),
                DropdownMenuItem(value: '13-18', child: Text('13-18')),
              ],
              onChanged: (v) => setState(() => _ageGroupValue = v ?? '7-12'),
              decoration: InputDecoration(
                labelText: 'Age group',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              controller: _minAgeController,
              label: 'Min age',
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              controller: _maxAgeController,
              label: 'Max age',
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickFileAny() async {
    if (kIsWeb) {
      _showWebFileNameInput();
    } else {
      await _pickFileForMobile(FileType.any);
    }
  }




  void _showWebFileNameInput() {
    if (!kIsWeb) return;
    
    // Sử dụng HTML input thực sự để mở dialog chọn file của browser
    WebFileInput.openFileDialog(
      onFileSelected: (fileName, file) {
        // Giới hạn kích thước file phía client để tránh 413
        const int maxUploadBytes = 15 * 1024 * 1024; // 15 MB
        if (file.size > maxUploadBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File quá lớn (${(file.size / (1024*1024)).toStringAsFixed(1)} MB). Giới hạn hiện tại là 15 MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        setState(() {
          _selectedFilePath = fileName;
          _selectedFile = file; // Lưu trữ file thực tế cho web
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã chọn file: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      accept: '.pdf,.epub,.mobi,.doc,.docx,.txt', // Các định dạng sách
    );
  }

  Future<void> _pickFileForMobile(FileType fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: false,
        withData: true, // Lấy dữ liệu file
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Giới hạn kích thước file phía client để tránh 413
        const int maxUploadBytes = 15 * 1024 * 1024; // 15 MB
        if (file.size > maxUploadBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File quá lớn (${(file.size / (1024*1024)).toStringAsFixed(1)} MB). Giới hạn hiện tại là 15 MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        if (file.path != null && file.path!.isNotEmpty) {
          setState(() {
            _selectedFilePath = file.path;
            _selectedFile = file; // Lưu trữ file thực tế
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã chọn file: ${file.name}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn file: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }




  Widget _buildActionButtons() {
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
                'Thêm Sách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

}
