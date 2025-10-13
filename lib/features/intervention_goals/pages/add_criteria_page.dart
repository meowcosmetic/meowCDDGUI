import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/app_colors.dart';
import '../../../constants/app_config.dart';
import '../../../models/api_service.dart';

class AddCriteriaPage extends StatefulWidget {
  final String? itemId;
  final Map<String, dynamic>? initialData; // For edit mode
  final bool isEditMode;

  const AddCriteriaPage({
    super.key,
    this.itemId,
    this.initialData,
    this.isEditMode = false,
  });

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
  // Generated descriptions controllers (editable)
  final _generatedViController = TextEditingController();
  final _generatedEnController = TextEditingController();
  // Additional post fields
  final _durationController = TextEditingController(text: '20');
  final _tagsController = TextEditingController(
    text: 'can thiệp,phát triển,trẻ em',
  );
  final _authorController = TextEditingController(text: 'Dr. Nguyen Van A');
  final _versionController = TextEditingController(text: '1.0');

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

  // Create post item
  bool _isCreatingCriteria = false;

  @override
  void initState() {
    super.initState();
    print('=== AddCriteriaPage initialized ===');
    print('itemId: ${widget.itemId}');
    print('isEditMode: ${widget.isEditMode}');
    print('initialData: ${widget.initialData}');
    print('itemId type: ${widget.itemId.runtimeType}');
    print('itemId is null: ${widget.itemId == null}');

    // Load domains first, then populate initial data
    _loadDomains().then((_) {
      // Populate initial data if in edit mode
      if (widget.isEditMode && widget.initialData != null) {
        _populateInitialData();
      }
    });
  }

  void _populateInitialData() {
    final data = widget.initialData!;
    print('=== Populating initial data ===');
    print('Data: $data');

    // Populate content
    _contentController.text =
        data['name'] ?? data['title'] ?? data['content'] ?? '';

    // Populate description
    if (data['description'] != null) {
      if (data['description'] is Map) {
        final desc = data['description'] as Map<String, dynamic>;
        _generatedViController.text = desc['vi'] ?? '';
        _generatedEnController.text = desc['en'] ?? '';
        _generatedDescriptionVi = desc['vi'];
        _generatedDescriptionEn = desc['en'];
      } else {
        _generatedViController.text = data['description'].toString();
        _generatedEnController.text = data['description'].toString();
        _generatedDescriptionVi = data['description'].toString();
        _generatedDescriptionEn = data['description'].toString();
      }
    }

    // Populate age range
    _minAgeController.text = data['minAgeMonths']?.toString() ?? '';
    _maxAgeController.text = data['maxAgeMonths']?.toString() ?? '';

    // Populate level
    _selectedLevel = data['level'] ?? 1;

    // Populate related content IDs
    if (data['relatedContentIds'] is List) {
      _selectedContentIds = (data['relatedContentIds'] as List)
          .map((e) => e.toString())
          .toSet();
    }

    // Populate domain ID
    _selectedDomainId = data['itemId']?.toString();
    print('Populated domainId: $_selectedDomainId');

    // Set selected domain name if domains are already loaded
    if (_domains.isNotEmpty && _selectedDomainId != null) {
      final selectedDomain = _domains.firstWhere(
        (domain) => domain['id']?.toString() == _selectedDomainId,
        orElse: () => {},
      );
      if (selectedDomain.isNotEmpty) {
        _selectedDomainName =
            selectedDomain['displayedName'] ??
            selectedDomain['name'] ??
            'Lĩnh vực can thiệp';
      } else {
        // If domain not found, clear the selection
        print(
          'Domain with ID $_selectedDomainId not found in domains list during populate',
        );
        _selectedDomainId = null;
        _selectedDomainName = null;
      }
    }

    print('Populated content: ${_contentController.text}');
    print('Populated minAge: ${_minAgeController.text}');
    print('Populated maxAge: ${_maxAgeController.text}');
    print('Populated level: $_selectedLevel');
    print('Populated relatedContentIds: $_selectedContentIds');
    print('Populated domainName: $_selectedDomainName');

    // Trigger setState to update UI
    setState(() {});
  }

  @override
  void dispose() {
    _contentController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _generatedViController.dispose();
    _generatedEnController.dispose();
    _titleController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    _authorController.dispose();
    _versionController.dispose();
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

          // Set selected domain name if we have a selected domain ID
          if (_selectedDomainId != null) {
            final selectedDomain = _domains.firstWhere(
              (domain) => domain['id']?.toString() == _selectedDomainId,
              orElse: () => {},
            );
            if (selectedDomain.isNotEmpty) {
              _selectedDomainName =
                  selectedDomain['displayedName'] ??
                  selectedDomain['name'] ??
                  'Lĩnh vực can thiệp';
            } else {
              // If domain not found, clear the selection
              print(
                'Domain with ID $_selectedDomainId not found in domains list',
              );
              _selectedDomainId = null;
              _selectedDomainName = null;
            }
          }
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
      final resp = await _apiService.generateDescription(
        _contentController.text.trim(),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          if (data['description'] is Map<String, dynamic>) {
            final desc = data['description'] as Map<String, dynamic>;
            _generatedDescriptionVi = desc['vi']?.toString();
            _generatedDescriptionEn = desc['en']?.toString();
            _generatedViController.text = _generatedDescriptionVi ?? '';
            _generatedEnController.text = _generatedDescriptionEn ?? '';
          } else {
            // Fallback nếu description là string
            final descStr = data['description']?.toString() ?? data.toString();
            _generatedDescriptionVi = descStr;
            _generatedDescriptionEn = descStr;
            _generatedViController.text = _generatedDescriptionVi ?? '';
            _generatedEnController.text = _generatedDescriptionEn ?? '';
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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
          _searchResults = (data as List)
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tìm thấy ${_searchResults.length} nội dung liên quan',
            ),
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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một nội dung liên quan'),
        ),
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
          .where(
            (result) => _selectedContentIds.contains(result['id']?.toString()),
          )
          .map((result) => result['payload']['content']?.toString() ?? '')
          .where((content) => content.isNotEmpty)
          .toList();

      final processData = {
        'intervention_goal': _contentController.text.trim(),
        'title': _titleController.text.trim(),
        'book_content': selectedContent,
      };

      print('Process data: $processData');

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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _createCriteriaItem() async {
    print('=== Creating criteria item (BLUE BUTTON) ===');
    print('widget.isEditMode: ${widget.isEditMode}');
    print('widget.itemId: ${widget.itemId}');
    print('_selectedDomainId: $_selectedDomainId');

    // Use widget.itemId if available, otherwise use _selectedDomainId
    final finalItemId = widget.itemId ?? _selectedDomainId;
    print('Final itemId for create: $finalItemId');

    if (finalItemId == null) {
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
          'vi': _generatedViController.text.trim().isNotEmpty
              ? _generatedViController.text.trim()
              : (_generatedDescriptionVi ?? ''),
          'en': _generatedEnController.text.trim().isNotEmpty
              ? _generatedEnController.text.trim()
              : (_generatedDescriptionEn ?? ''),
        },
        'itemId': finalItemId, // Use the correct itemId
        'minAgeMonths': int.tryParse(_minAgeController.text) ?? 0,
        'maxAgeMonths': int.tryParse(_maxAgeController.text) ?? 100,
        'level': _selectedLevel,
        'relatedContentIds': _selectedContentIds.toList(),
      };

      print('Create criteria data: $criteriaData');

      // Check if we should use update or create
      http.Response resp;
      if (widget.isEditMode && widget.initialData != null) {
        // Update existing post
        final criteriaId = widget.initialData!['id'];
        print('=== EDIT MODE - USING PUT (BLUE BUTTON) ===');
        print('Updating post with ID: $criteriaId');
        resp = await _apiService.updateDevelopmentalItemCriteria(
          criteriaId.toString(),
          criteriaData,
        );
      } else {
        // Create new post
        print('=== ADD MODE - USING POST (BLUE BUTTON) ===');
        resp = await _apiService.createDevelopmentalItemCriteria(criteriaData);
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Cập nhật bài post thành công'
                  : 'Tạo bài post thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${resp.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isCreatingCriteria = false;
      });
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lĩnh vực can thiệp')),
      );
      return;
    }

    if (_processedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng xử lý nội dung trước khi lưu bài post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('=== Saving post ===');
      print('isEditMode: ${widget.isEditMode}');
      print('widget.itemId: ${widget.itemId}');
      print('widget.itemId is null: ${widget.itemId == null}');
      print('_selectedDomainId: $_selectedDomainId');
      print('_selectedDomainId is null: ${_selectedDomainId == null}');

      // Force use widget.itemId if available, don't fallback to _selectedDomainId
      final finalItemId = widget.itemId;
      print('Final itemId (forced): $finalItemId');

      if (finalItemId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Không có itemId để tạo mục tiêu can thiệp'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Tạo dữ liệu cho intervention-posts API
      final postData = {
        "title": _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : _contentController.text.trim(),
        "content": {
          "vi":
              _processedData?['processing_results']?['final_content']
                  ?.toString() ??
              _contentController.text.trim(),
          "en":
              _processedData?['processing_results']?['final_content']
                  ?.toString() ??
              _contentController.text.trim(),
        },
        "postType": "INTERVENTION_METHOD",
        "difficultyLevel": _selectedLevel,
        "targetAgeMinMonths": int.parse(_minAgeController.text),
        "targetAgeMaxMonths": int.parse(_maxAgeController.text),
        "estimatedDurationMinutes":
            int.tryParse(_durationController.text.trim()) ?? 20,
        "tags": _tagsController.text.trim(),
        "isPublished": false,
        "author": _authorController.text.trim(),
        "version": _versionController.text.trim(),
        "criteriaId": int.tryParse(finalItemId ?? '1') ?? 1,
      };

      print('Intervention post data to send: $postData');

      // Luôn luôn tạo mới bài post với POST method
      print('=== CREATING NEW INTERVENTION POST - USING POST ===');
      print('Creating new intervention post');
      print('API URL: ${AppConfig.cddAPI}/intervention-posts');
      print('itemId in payload: ${postData['criteriaId']}');

      final resp = await _apiService.createInterventionPost(postData);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo bài post thành công'),
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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
        title: Text(
          widget.isEditMode
              ? 'Sửa Mục Tiêu Can Thiệp'
              : 'Thêm Mục Tiêu Can Thiệp',
        ),
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
                        initialValue: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Mức độ',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Mức 1 - Cơ bản'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('Mức 2 - Trung bình'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('Mức 3 - Nâng cao'),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text('Mức 4 - Chuyên sâu'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('Mức 5 - Chuyên gia'),
                          ),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.arrow_drop_down),
                        ),
                        hint: const Text('Chọn lĩnh vực can thiệp'),
                        items: _domains.map((domain) {
                          final name = domain['name'];
                          String displayName = 'Domain ${domain['id']}';

                          if (name is Map<String, dynamic>) {
                            displayName =
                                name['vi'] ?? name['en'] ?? displayName;
                          } else if (name is String) {
                            displayName = name;
                          }

                          return DropdownMenuItem<String>(
                            value: domain['id']?.toString(),
                            child: Text(displayName),
                          );
                        }).toList(),
                        onChanged: _isLoadingDomains
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedDomainId = value;
                                  final selectedDomain = _domains.firstWhere(
                                    (domain) =>
                                        domain['id']?.toString() == value,
                                    orElse: () => {},
                                  );
                                  _selectedDomainName = selectedDomain['name']
                                      ?.toString();
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      // Additional post fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Thời gian (phút)',
                                hintText: '20',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập thời gian';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Vui lòng nhập số hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _versionController,
                              decoration: const InputDecoration(
                                labelText: 'Phiên bản',
                                hintText: '1.0',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập phiên bản';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (cách nhau bởi dấu phẩy)',
                          hintText: 'can thiệp,phát triển,trẻ em',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tags';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Tác giả',
                          hintText: 'Dr. Nguyen Van A',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tác giả';
                          }
                          return null;
                        },
                      ),
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
                          onPressed: _isGeneratingDescription
                              ? null
                              : _generateDescription,
                          icon: _isGeneratingDescription
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isGeneratingDescription
                                ? 'Đang tạo mô tả...'
                                : 'Tạo mô tả tự động',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Generated Description
              if (_generatedDescriptionVi != null ||
                  _generatedDescriptionEn != null) ...[
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
                          TextFormField(
                            controller: _generatedViController,
                            minLines: 1,
                            maxLines: null,
                            decoration: InputDecoration(
                              isCollapsed: false,
                              filled: true,
                              fillColor: Colors.blue[50],
                              labelText: 'Mô tả (VI) - có thể chỉnh sửa',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: const TextStyle(fontSize: 14),
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
                          TextFormField(
                            controller: _generatedEnController,
                            minLines: 1,
                            maxLines: null,
                            decoration: InputDecoration(
                              isCollapsed: false,
                              filled: true,
                              fillColor: Colors.green[50],
                              labelText: 'Description (EN) - editable',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCreatingCriteria
                                ? null
                                : _createCriteriaItem,
                            icon: _isCreatingCriteria
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_circle),
                            label: Text(
                              _isCreatingCriteria
                                  ? 'Đang tạo...'
                                  : 'Tạo mục tiêu can thiệp',
                            ),
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
                          onPressed: _isSearching
                              ? null
                              : _searchRelatedContent,
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(
                            _isSearching
                                ? 'Đang tìm kiếm...'
                                : 'Tìm nội dung liên quan',
                          ),
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
                              final payload =
                                  result['payload'] as Map<String, dynamic>? ??
                                  {};
                              final title =
                                  payload['title']?.toString() ??
                                  'Không có tiêu đề';
                              final content =
                                  payload['content']?.toString() ?? '';
                              final score = result['score']?.toString() ?? '0';
                              final author =
                                  payload['author']?.toString() ?? '';
                              final year = payload['year']?.toString() ?? '';
                              final chapter =
                                  payload['chapter']?.toString() ?? '';
                              final page = payload['page']?.toString() ?? '';
                              final tags =
                                  (payload['tags'] as List?)
                                      ?.map((e) => e.toString())
                                      .toList() ??
                                  [];

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
                                    if (author.isNotEmpty ||
                                        year.isNotEmpty) ...[
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
                                    if (chapter.isNotEmpty ||
                                        page.isNotEmpty) ...[
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _processInterventionGoal, // Luôn cho phép bấm
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(
                              _isProcessing
                                  ? 'Đang xử lý...'
                                  : 'Xử lý nội dung',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
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
                                height:
                                    1200, // Chiều cao cố định cho TabBarView
                                child: TabBarView(
                                  children: [
                                    // Expert Analysis
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['expert_analysis']
                                                ?.toString() ??
                                            'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Practical Content
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['practical_content']
                                                ?.toString() ??
                                            'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Verified Content
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        _processedData!['processing_results']?['verified_content']
                                                ?.toString() ??
                                            'Không có dữ liệu',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // Workflow Summary
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Step 1: ${_processedData!['workflow_summary']?['step_1']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 2: ${_processedData!['workflow_summary']?['step_2']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 3: ${_processedData!['workflow_summary']?['step_3']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Step 4: ${_processedData!['workflow_summary']?['step_4']?.toString() ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Final Content (HTML)
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(12),
                                      child: Html(
                                        data:
                                            _processedData!['final_content']
                                                ?.toString() ??
                                            'Không có dữ liệu',
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
                  onPressed: _isSaving ? null : _savePost,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu bài post'),
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
