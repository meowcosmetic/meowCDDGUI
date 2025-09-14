import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';
import '../../intervention_domains/models/domain_models.dart';
import 'web_file_input.dart';

class AddBookPage extends StatefulWidget {
  final List<InterventionDomainModel> domains;
  final List<String> formats;

  const AddBookPage({
    Key? key,
    required this.domains,
    required this.formats,
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
  String? _selectedFilePath;
  final _filePathController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _languageController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  final _downloadUrlController = TextEditingController();
  final _previewUrlController = TextEditingController();

  String _selectedFormat = 'PDF';
  List<String> _selectedDomainIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.formats.isNotEmpty) {
      _selectedFormat = widget.formats.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _filePathController.dispose();
    _pageCountController.dispose();
    _languageController.dispose();
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
      final bookData = {
        'title': _titleController.text,
        'author': _authorController.text,
        'publisher': _publisherController.text,
        'isbn': _isbnController.text,
        'description': _descriptionController.text,
        'content': _selectedFilePath ?? _filePathController.text,
        'pageCount': int.tryParse(_pageCountController.text) ?? 0,
        'language': _languageController.text,
        'format': _selectedFormat,
        'coverImageUrl': _coverImageUrlController.text,
        'downloadUrl': _downloadUrlController.text,
        'previewUrl': _previewUrlController.text,
        'developmentalDomainIds': _selectedDomainIds,
      };

      final apiService = ApiService();
      final response = await apiService.createBook(bookData);

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
              _buildFilePathField(),
              _buildTextField(
                controller: _pageCountController,
                label: 'Số trang',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _languageController,
                label: 'Ngôn ngữ',
              ),
              _buildSectionTitle('Định dạng và lĩnh vực'),
              _buildFormatDropdown(),
              _buildDomainSelection(),
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

  Widget _buildFormatDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedFormat,
        decoration: InputDecoration(
          labelText: 'Định dạng *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        items: widget.formats.map((format) {
          return DropdownMenuItem<String>(
            value: format,
            child: Text(format),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedFormat = value!;
          });
        },
        validator: (value) => value?.isEmpty == true ? 'Vui lòng chọn định dạng' : null,
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
              onTap: _pickFile,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFileAny,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Chọn file bất kỳ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Chọn tài liệu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[700],
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilePathField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoặc nhập đường dẫn file thủ công',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _filePathController,
            decoration: InputDecoration(
              labelText: 'Đường dẫn file',
              hintText: 'C:/path/to/your/file.pdf',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
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
      onFileSelected: (fileName) {
        setState(() {
          _selectedFilePath = fileName;
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
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null && file.path!.isNotEmpty) {
          setState(() {
            _selectedFilePath = file.path;
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

  Future<void> _pickFile() async {
    if (kIsWeb) {
      _showWebFileNameInput();
    } else {
      await _pickDocumentForMobile();
    }
  }


  Future<void> _pickDocumentForMobile() async {
    try {
      // Thử khởi tạo FilePicker trước
      await FilePicker.platform.clearTemporaryFiles();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'mobi', 'txt', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null && file.path!.isNotEmpty) {
          setState(() {
            _selectedFilePath = file.path;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã chọn tài liệu: ${file.name}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể lấy đường dẫn file. Vui lòng nhập đường dẫn thủ công.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker không hoạt động. Vui lòng nhập đường dẫn file thủ công.\nLỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
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
                'Thêm Sách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
