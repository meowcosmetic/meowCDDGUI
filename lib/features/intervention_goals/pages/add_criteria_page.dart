import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../models/api_service.dart';

class AddCriteriaPage extends StatefulWidget {
  const AddCriteriaPage({super.key});

  @override
  State<AddCriteriaPage> createState() => _AddCriteriaPageState();
}

class _AddCriteriaPageState extends State<AddCriteriaPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _contentController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  
  // State variables
  bool _isGeneratingDescription = false;
  bool _isSaving = false;
  String? _generatedDescriptionVi;
  String? _generatedDescriptionEn;
  String? _selectedDomainId;
  String? _selectedDomainName;
  int _selectedLevel = 1;
  List<Map<String, dynamic>> _domains = [];
  bool _isLoadingDomains = false;
  
  // Search related content
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Set<String> _selectedContentIds = {};
  
  // Process intervention goal
  bool _isProcessing = false;
  Map<String, dynamic>? _processedData;
  final _titleController = TextEditingController();
  
  // Create criteria item
  bool _isCreatingCriteria = false;

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadDomains() async {
    setState(() {
      _isLoadingDomains = true;
    });

    try {
      final resp = await _apiService.getDevelopmentalDomains();
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        List<dynamic> domainsList;
        
        if (data is List) {
          domainsList = data;
        } else if (data is Map<String, dynamic> && data['content'] is List) {
          domainsList = data['content'] as List;
        } else {
          domainsList = [];
        }

        setState(() {
          _domains = domainsList
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
        });
      }
    } catch (e) {
      print('Error loading domains: $e');
    } finally {
      setState(() {
        _isLoadingDomains = false;
      });
    }
  }

  Future<void> _generateDescription() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung can thiệp')),
      );
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    try {
      final resp = await _apiService.generateDescription(_contentController.text.trim());
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          if (data['description'] is Map<String, dynamic>) {
            final desc = data['description'] as Map<String, dynamic>;
            _generatedDescriptionVi = desc['vi']?.toString();
            _generatedDescriptionEn = desc['en']?.toString();
          } else {
            // Fallback nếu description là string
            final descStr = data['description']?.toString() ?? data.toString();
            _generatedDescriptionVi = descStr;
            _generatedDescriptionEn = descStr;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo mô tả thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo mô tả: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
  }

  Future<void> _searchRelatedContent() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung can thiệp trước')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final resp = await _apiService.searchRelatedContent(
        query: _contentController.text.trim(),
        limit: 10,
        scoreThreshold: 0.7,
      );
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _searchResults = (data as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tìm thấy ${_searchResults.length} nội dung liên quan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tìm kiếm: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _processInterventionGoal() async {
    if (_selectedContentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một nội dung liên quan')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề bài viết')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get selected content
      final selectedContent = _searchResults
          .where((result) => _selectedContentIds.contains(result['id']?.toString()))
          .map((result) => result['payload']['content']?.toString() ?? '')
          .where((content) => content.isNotEmpty)
          .toList();

      final processData = {
        'intervention_goal': _contentController.text.trim(),
        'title': _titleController.text.trim(),
        'book_content': selectedContent,
      };

      final resp = await _apiService.processInterventionGoal(processData);
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _processedData = data;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xử lý nội dung thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _createCriteriaItem() async {
    if (_selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lĩnh vực can thiệp')),
      );
      return;
    }

    setState(() {
      _isCreatingCriteria = true;
    });

    try {
      final criteriaData = {
        'name': _contentController.text.trim(),
        'description': {
          'vi': _generatedDescriptionVi ?? '',
          'en': _generatedDescriptionEn ?? '',
        },
        'itemId': _selectedDomainId,
        'minAgeMonths': int.tryParse(_minAgeController.text) ?? 0,
        'maxAgeMonths': int.tryParse(_maxAgeController.text) ?? 100,
        'level': _selectedLevel,
        'relatedContentIds': _selectedContentIds.toList(),
      };

      final resp = await _apiService.createDevelopmentalItemCriteria(criteriaData);
      
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo mục tiêu can thiệp thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo mục tiêu: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCreatingCriteria = false;
      });
    }
  }

  Future<void> _saveCriteria() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lĩnh vực can thiệp')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final criteriaData = {
        'content': _contentController.text.trim(),
        'description': {
          'vi': _generatedDescriptionVi ?? _contentController.text.trim(),
          'en': _generatedDescriptionEn ?? _contentController.text.trim(),
        },
        'itemId': _selectedDomainId,
        'minAgeMonths': int.parse(_minAgeController.text),
        'maxAgeMonths': int.parse(_maxAgeController.text),
        'level': _selectedLevel,
        'relatedContentIds': _selectedContentIds.toList(),
      };

      final resp = await _apiService.createDevelopmentalItemCriteria(criteriaData);
      
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm mục tiêu can thiệp thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Mục Tiêu Can Thiệp'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin chung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minAgeController,
                              decoration: const InputDecoration(
                                labelText: 'Tuổi tối thiểu (tháng)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tuổi tối thiểu';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Vui lòng nhập số hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxAgeController,
                              decoration: const InputDecoration(
                                labelText: 'Tuổi tối đa (tháng)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tuổi tối đa';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Vui lòng nhập số hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Mức độ',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Mức 1 - Cơ bản')),
                          DropdownMenuItem(value: 2, child: Text('Mức 2 - Trung bình')),
                          DropdownMenuItem(value: 3, child: Text('Mức 3 - Nâng cao')),
                          DropdownMenuItem(value: 4, child: Text('Mức 4 - Chuyên sâu')),
                          DropdownMenuItem(value: 5, child: Text('Mức 5 - Chuyên gia')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDomainId,
                        decoration: InputDecoration(
                          labelText: 'Lĩnh vực can thiệp',
                          border: const OutlineInputBorder(),
                          suffixIcon: _isLoadingDomains
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : const Icon(Icons.arrow_drop_down),
                        ),
                        hint: const Text('Chọn lĩnh vực can thiệp'),
                        items: _domains.map((domain) {
                          final name = domain['name'];
                          String displayName = 'Domain ${domain['id']}';
                          
                          if (name is Map<String, dynamic>) {
                            displayName = name['vi'] ?? name['en'] ?? displayName;
                          } else if (name is String) {
                            displayName = name;
                          }
                          
                          return DropdownMenuItem<String>(
                            value: domain['id']?.toString(),
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: _isLoadingDomains ? null : (value) {
                          setState(() {
                            _selectedDomainId = value;
                            final selectedDomain = _domains.firstWhere(
                              (domain) => domain['id']?.toString() == value,
                              orElse: () => {},
                            );
                            _selectedDomainName = selectedDomain['name']?.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Step 1: Content Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bước 1: Nhập nội dung can thiệp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung can thiệp',
                          hintText: 'Nhập nội dung can thiệp...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung can thiệp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingDescription ? null : _generateDescription,
                          icon: _isGeneratingDescription
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(_isGeneratingDescription ? 'Đang tạo mô tả...' : 'Tạo mô tả tự động'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Generated Description
              if (_generatedDescriptionVi != null || _generatedDescriptionEn != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mô tả được tạo tự động:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Vietnamese Description
                        if (_generatedDescriptionVi != null) ...[
                          const Text(
                            'Tiếng Việt:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[300]!),
                            ),
                            child: Text(
                              _generatedDescriptionVi!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // English Description
                        if (_generatedDescriptionEn != null) ...[
                          const Text(
                            'English:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[300]!),
                            ),
                            child: Text(
                              _generatedDescriptionEn!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCreatingCriteria ? null : _createCriteriaItem,
                            icon: _isCreatingCriteria
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_circle),
                            label: Text(_isCreatingCriteria ? 'Đang tạo...' : 'Tạo mục tiêu can thiệp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Step 3: Search Related Content
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bước 2: Tìm nội dung liên quan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSearching ? null : _searchRelatedContent,
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isSearching ? 'Đang tìm kiếm...' : 'Tìm nội dung liên quan'),
                        ),
                      ),
                      if (_searchResults.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Nội dung liên quan:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              final id = result['id']?.toString() ?? '';
                              final payload = result['payload'] as Map<String, dynamic>? ?? {};
                              final title = payload['title']?.toString() ?? 'Không có tiêu đề';
                              final content = payload['content']?.toString() ?? '';
                              final score = result['score']?.toString() ?? '0';
                              final author = payload['author']?.toString() ?? '';
                              final year = payload['year']?.toString() ?? '';
                              final chapter = payload['chapter']?.toString() ?? '';
                              final page = payload['page']?.toString() ?? '';
                              final tags = (payload['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
                              
                              return CheckboxListTile(
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author and year info
                                    if (author.isNotEmpty || year.isNotEmpty) ...[
                                      Text(
                                        '${author.isNotEmpty ? author : ''}${author.isNotEmpty && year.isNotEmpty ? ' ($year)' : year}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    
                                    // Chapter and page info
                                    if (chapter.isNotEmpty || page.isNotEmpty) ...[
                                      Text(
                                        'Chương $chapter${page.isNotEmpty ? ', Trang $page' : ''}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    
                                    // Full content
                                    Text(
                                      content,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Tags
                                    if (tags.isNotEmpty) ...[
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 2,
                                        children: tags.take(5).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    
                                    // Score
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Score: ${(double.tryParse(score) ?? 0).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                value: _selectedContentIds.contains(id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedContentIds.add(id);
                                    } else {
                                      _selectedContentIds.remove(id);
                                    }
                                  });
                                },
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đã chọn ${_selectedContentIds.length} nội dung',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        if (_selectedContentIds.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề bài viết',
                              hintText: 'Nhập tiêu đề cho bài viết...',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tiêu đề bài viết';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _processInterventionGoal,
                              icon: _isProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(_isProcessing ? 'Đang xử lý...' : 'Xử lý nội dung'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Step 4: Processed Content Display
              if (_processedData != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nội dung đã xử lý:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DefaultTabController(
                          length: 5,
                          child: Column(
                            children: [
                              const TabBar(
                                isScrollable: true,
                                tabs: [
                                  Tab(text: 'Expert Analysis'),
                                  Tab(text: 'Practical Content'),
                                  Tab(text: 'Verified Content'),
                                  Tab(text: 'Workflow Summary'),
                                  Tab(text: 'Final Content'),
                                ],
                              ),
                              SizedBox(
                                height: 300,
                                child: TabBarView(
                                  children: [
                                    // Expert Analysis
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['expert_analysis']?.toString() ?? 'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Practical Content
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['practical_content']?.toString() ?? 'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Verified Content
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['verified_content']?.toString() ?? 'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Workflow Summary
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Step 1: ${_processedData!['workflow_summary']?['step_1']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 2: ${_processedData!['workflow_summary']?['step_2']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 3: ${_processedData!['workflow_summary']?['step_3']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 4: ${_processedData!['workflow_summary']?['step_4']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Final Content (HTML)
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Html(
                                        data: _processedData!['final_content']?.toString() ?? 'Không có dữ liệu',
                                        style: {
                                          "body": Style(
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                          ),
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCriteria,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu mục tiêu can thiệp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
