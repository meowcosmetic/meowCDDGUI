import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/cdd_test.dart';
import '../models/api_service.dart';

class CreateTestView extends StatefulWidget {
  const CreateTestView({super.key});

  @override
  State<CreateTestView> createState() => _CreateTestViewState();
}

class _CreateTestViewState extends State<CreateTestView> {
  final _formKey = GlobalKey<FormState>();
  final _api = const ApiService();
  
  // Basic Information
  final _assessmentCodeCtrl = TextEditingController();
  final _nameViCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _descriptionViCtrl = TextEditingController();
  final _descriptionEnCtrl = TextEditingController();
  final _instructionsViCtrl = TextEditingController();
  final _instructionsEnCtrl = TextEditingController();
  
  // Test Configuration
  String _selectedCategory = 'DEVELOPMENTAL_SCREENING';
  final _minAgeCtrl = TextEditingController(text: '0');
  final _maxAgeCtrl = TextEditingController(text: '6');
  String _selectedStatus = CDDTestStatus.DRAFT;
  final _versionCtrl = TextEditingController(text: '1.0');
  final _durationCtrl = TextEditingController(text: '15');
  String _selectedAdminType = CDDAdministrationType.PARENT_REPORT;
  String _selectedQualifications = CDDRequiredQualifications.NO_QUALIFICATION_REQUIRED;
  
  // Materials
  final _materialsCtrl = TextEditingController();
  List<String> _requiredMaterials = [];
  
  // Questions
  List<CDDQuestion> _questions = [];
  
  // Scoring
  final _totalQuestionsCtrl = TextEditingController(text: '20');
  final _yesScoreCtrl = TextEditingController(text: '1');
  final _noScoreCtrl = TextEditingController(text: '0');
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addDefaultQuestions();
  }

  void _addDefaultQuestions() {
    _questions = [];
  }

  @override
  void dispose() {
    _assessmentCodeCtrl.dispose();
    _nameViCtrl.dispose();
    _nameEnCtrl.dispose();
    _descriptionViCtrl.dispose();
    _descriptionEnCtrl.dispose();
    _instructionsViCtrl.dispose();
    _instructionsEnCtrl.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    _versionCtrl.dispose();
    _durationCtrl.dispose();
    _materialsCtrl.dispose();
    _totalQuestionsCtrl.dispose();
    _yesScoreCtrl.dispose();
    _noScoreCtrl.dispose();
    super.dispose();
  }

  void _addMaterial() {
    if (_materialsCtrl.text.isNotEmpty) {
      setState(() {
        _requiredMaterials.add(_materialsCtrl.text);
        _materialsCtrl.clear();
      });
    }
  }

  void _removeMaterial(int index) {
    setState(() {
      _requiredMaterials.removeAt(index);
    });
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(
        questionNumber: _questions.length + 1,
        onSave: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      // Reorder question numbers and regenerate IDs
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = CDDQuestion(
          questionId: _generateQuestionId(i + 1),
          questionNumber: i + 1,
          questionTexts: _questions[i].questionTexts,
          category: _questions[i].category,
          weight: _questions[i].weight,
          required: _questions[i].required,
          hints: _questions[i].hints,
          explanations: _questions[i].explanations,
        );
      }
    });
  }

  String _generateQuestionId(int questionNumber) {
    return 'Q_${questionNumber.toString().padLeft(3, '0')}';
  }

  Future<void> _submitTest() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final test = CDDTest(
        assessmentCode: _assessmentCodeCtrl.text.trim(),
        names: {
          'vi': _nameViCtrl.text.trim(),
          'en': _nameEnCtrl.text.trim(),
        },
        descriptions: {
          'vi': _descriptionViCtrl.text.trim(),
          'en': _descriptionEnCtrl.text.trim(),
        },
        instructions: {
          'vi': _instructionsViCtrl.text.trim(),
          'en': _instructionsEnCtrl.text.trim(),
        },
        category: _selectedCategory,
        minAgeMonths: int.parse(_minAgeCtrl.text),
        maxAgeMonths: int.parse(_maxAgeCtrl.text),
        status: _selectedStatus,
        version: _versionCtrl.text.trim(),
        estimatedDuration: int.parse(_durationCtrl.text),
        administrationType: _selectedAdminType,
        requiredQualifications: _selectedQualifications,
        requiredMaterials: _requiredMaterials,
        notes: {
          'vi': 'Bài test được tạo tự động',
          'en': 'Test created automatically',
        },
        questions: _questions,
        scoringCriteria: CDDScoringCriteria(
          totalQuestions: int.parse(_totalQuestionsCtrl.text),
          yesScore: int.parse(_yesScoreCtrl.text),
          noScore: int.parse(_noScoreCtrl.text),
          scoreRanges: {
            'LOW_RISK': CDDScoreRange(
              minScore: 0,
              maxScore: 2,
              level: 'LOW_RISK',
              descriptions: {
                'vi': 'Nguy cơ thấp - Trẻ có ít dấu hiệu bất thường',
                'en': 'Low risk - Child has few abnormal signs'
              },
              recommendation: 'Tiếp tục theo dõi phát triển bình thường',
            ),
            'MEDIUM_RISK': CDDScoreRange(
              minScore: 3,
              maxScore: 5,
              level: 'MEDIUM_RISK',
              descriptions: {
                'vi': 'Nguy cơ trung bình - Trẻ có một số dấu hiệu bất thường',
                'en': 'Medium risk - Child has some abnormal signs'
              },
              recommendation: 'Cần theo dõi chặt chẽ và đánh giá lại sau 1-2 tháng',
            ),
            'HIGH_RISK': CDDScoreRange(
              minScore: 6,
              maxScore: int.parse(_totalQuestionsCtrl.text),
              level: 'HIGH_RISK',
              descriptions: {
                'vi': 'Nguy cơ cao - Trẻ có nhiều dấu hiệu bất thường',
                'en': 'High risk - Child has many abnormal signs'
              },
              recommendation: 'Cần đánh giá chuyên môn ngay lập tức',
            ),
          },
          interpretation: 'Điểm càng cao, nguy cơ bất thường phát triển càng lớn',
        ),
      );

      final response = await _api.createTest(test);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bài test đã được tạo thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tạo bài test: ${response.statusCode} - ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo bài test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài test mới'),
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
              _buildBasicInformation(),
              const SizedBox(height: 24),
              _buildTestConfiguration(),
              const SizedBox(height: 24),
              _buildMaterials(),
              const SizedBox(height: 24),
              _buildQuestions(),
              const SizedBox(height: 24),
              _buildScoring(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assessmentCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Mã bài test *',
                hintText: 'VD: DEVELOPMENTAL_SCREENING_V1',
              ),
              validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mã bài test' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameViCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên bài test (VI) *',
                      hintText: 'Tên tiếng Việt',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tên bài test' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nameEnCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên bài test (EN)',
                      hintText: 'Tên tiếng Anh',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionViCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả (VI) *',
                hintText: 'Mô tả bài test bằng tiếng Việt',
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionEnCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả (EN)',
                hintText: 'Mô tả bài test bằng tiếng Anh',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsViCtrl,
              decoration: const InputDecoration(
                labelText: 'Hướng dẫn (VI) *',
                hintText: 'Hướng dẫn thực hiện bài test',
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập hướng dẫn' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsEnCtrl,
              decoration: const InputDecoration(
                labelText: 'Hướng dẫn (EN)',
                hintText: 'Hướng dẫn thực hiện bài test bằng tiếng Anh',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestConfiguration() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình bài test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
              ),
              items: const [
                DropdownMenuItem(value: 'DEVELOPMENTAL_SCREENING', child: Text('Sàng lọc phát triển')),
                DropdownMenuItem(value: 'COMMUNICATION_ASSESSMENT', child: Text('Đánh giá giao tiếp')),
                DropdownMenuItem(value: 'MOTOR_ASSESSMENT', child: Text('Đánh giá vận động')),
                DropdownMenuItem(value: 'SOCIAL_ASSESSMENT', child: Text('Đánh giá xã hội')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAgeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Độ tuổi tối thiểu (tháng) *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập độ tuổi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxAgeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Độ tuổi tối đa (tháng) *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập độ tuổi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái *',
                    ),
                    items: const [
                      DropdownMenuItem(value: CDDTestStatus.DRAFT, child: Text('Bản nháp')),
                      DropdownMenuItem(value: CDDTestStatus.ACTIVE, child: Text('Hoạt động')),
                      DropdownMenuItem(value: CDDTestStatus.INACTIVE, child: Text('Không hoạt động')),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _versionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phiên bản *',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập phiên bản' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Thời gian ước tính (phút) *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập thời gian' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAdminType,
                    decoration: const InputDecoration(
                      labelText: 'Loại thực hiện *',
                    ),
                    items: const [
                      DropdownMenuItem(value: CDDAdministrationType.PARENT_REPORT, child: Text('Báo cáo phụ huynh')),
                      DropdownMenuItem(value: CDDAdministrationType.PROFESSIONAL_OBSERVATION, child: Text('Quan sát chuyên môn')),
                      DropdownMenuItem(value: CDDAdministrationType.DIRECT_ASSESSMENT, child: Text('Đánh giá trực tiếp')),
                    ],
                    onChanged: (value) => setState(() => _selectedAdminType = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedQualifications,
              decoration: const InputDecoration(
                labelText: 'Yêu cầu trình độ *',
              ),
              items: const [
                DropdownMenuItem(value: CDDRequiredQualifications.NO_QUALIFICATION_REQUIRED, child: Text('Không yêu cầu')),
                DropdownMenuItem(value: CDDRequiredQualifications.PSYCHOLOGIST_REQUIRED, child: Text('Chuyên gia tâm lý')),
                DropdownMenuItem(value: CDDRequiredQualifications.PEDIATRICIAN_REQUIRED, child: Text('Bác sĩ nhi khoa')),
                DropdownMenuItem(value: CDDRequiredQualifications.THERAPIST_REQUIRED, child: Text('Nhà trị liệu')),
              ],
              onChanged: (value) => setState(() => _selectedQualifications = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterials() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vật liệu cần thiết',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _materialsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Thêm vật liệu',
                      hintText: 'VD: Bảng câu hỏi, Bút, Đồ chơi...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addMaterial,
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_requiredMaterials.isNotEmpty) ...[
              const Text('Danh sách vật liệu:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...(_requiredMaterials.asMap().entries.map((entry) {
                final index = entry.key;
                final material = entry.value;
                return ListTile(
                  dense: true,
                  title: Text(material),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMaterial(index),
                  ),
                );
              })),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách câu hỏi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm câu hỏi'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_questions.isEmpty)
              const Center(
                child: Text('Chưa có câu hỏi nào', style: TextStyle(color: Colors.grey)),
              )
            else
              ...(_questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                 Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Expanded(
                               child: Text(
                                 'Câu hỏi ${question.questionNumber}',
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                               ),
                             ),
                             IconButton(
                               icon: const Icon(Icons.delete, color: Colors.red),
                               onPressed: () => _removeQuestion(index),
                             ),
                           ],
                         ),
                        const SizedBox(height: 8),
                        Text(
                          question.getQuestionText('vi'),
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (question.getQuestionText('en').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            question.getQuestionText('en'),
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getCategoryDisplayName(question.category),
                                style: TextStyle(fontSize: 10, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Trọng số: ${question.weight}',
                                style: TextStyle(fontSize: 10, color: AppColors.success),
                              ),
                            ),
                            if (question.required) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Bắt buộc',
                                  style: TextStyle(fontSize: 10, color: Colors.orange),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }

  Widget _buildScoring() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiêu chí chấm điểm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalQuestionsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tổng số câu hỏi *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tổng số câu hỏi' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yesScoreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Điểm cho "Có" *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập điểm' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _noScoreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Điểm cho "Không" *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập điểm' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Khoảng điểm mặc định:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Nguy cơ thấp: 0-2 điểm'),
            const Text('• Nguy cơ trung bình: 3-5 điểm'),
            const Text('• Nguy cơ cao: 6+ điểm'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Tạo bài test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case CDDQuestionCategory.COMMUNICATION_LANGUAGE:
        return 'Giao tiếp';
      case CDDQuestionCategory.GROSS_MOTOR:
        return 'Vận động thô';
      case CDDQuestionCategory.FINE_MOTOR:
        return 'Vận động tinh';
      case CDDQuestionCategory.IMITATION_LEARNING:
        return 'Bắt chước';
      case CDDQuestionCategory.PERSONAL_SOCIAL:
        return 'Xã hội';
      case CDDQuestionCategory.OTHER:
        return 'Khác';
      default:
        return category;
    }
  }
}

class QuestionDialog extends StatefulWidget {
  final int questionNumber;
  final Function(CDDQuestion) onSave;

  const QuestionDialog({
    super.key,
    required this.questionNumber,
    required this.onSave,
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _questionIdCtrl = TextEditingController();
  final _questionViCtrl = TextEditingController();
  final _questionEnCtrl = TextEditingController();
  final _hintViCtrl = TextEditingController();
  final _hintEnCtrl = TextEditingController();
  final _explanationViCtrl = TextEditingController();
  final _explanationEnCtrl = TextEditingController();
  
  String _selectedCategory = CDDQuestionCategory.COMMUNICATION_LANGUAGE;
  final _weightCtrl = TextEditingController(text: '1');
  bool _isRequired = true;

  @override
  void initState() {
    super.initState();
    _questionIdCtrl.text = 'Q_${widget.questionNumber.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _questionIdCtrl.dispose();
    _questionViCtrl.dispose();
    _questionEnCtrl.dispose();
    _hintViCtrl.dispose();
    _hintEnCtrl.dispose();
    _explanationViCtrl.dispose();
    _explanationEnCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;

    final question = CDDQuestion(
      questionId: _questionIdCtrl.text.trim(),
      questionNumber: widget.questionNumber,
      questionTexts: {
        'vi': _questionViCtrl.text.trim(),
        'en': _questionEnCtrl.text.trim(),
      },
      category: _selectedCategory,
      weight: int.parse(_weightCtrl.text),
      required: _isRequired,
      hints: {
        'vi': _hintViCtrl.text.trim(),
        'en': _hintEnCtrl.text.trim(),
      },
      explanations: {
        'vi': _explanationViCtrl.text.trim(),
        'en': _explanationEnCtrl.text.trim(),
      },
    );

    widget.onSave(question);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thêm câu hỏi ${widget.questionNumber}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question ID
                      TextFormField(
                        controller: _questionIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ID câu hỏi *',
                          hintText: 'VD: COMM_001',
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập ID câu hỏi' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Question Text
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _questionViCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nội dung câu hỏi (VI) *',
                                hintText: 'Câu hỏi bằng tiếng Việt',
                              ),
                              maxLines: 3,
                              validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập nội dung câu hỏi' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _questionEnCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nội dung câu hỏi (EN)',
                                hintText: 'Câu hỏi bằng tiếng Anh',
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Category and Weight
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Danh mục *',
                              ),
                              items: const [
                                DropdownMenuItem(value: CDDQuestionCategory.COMMUNICATION_LANGUAGE, child: Text('Giao tiếp - Ngôn ngữ')),
                                DropdownMenuItem(value: CDDQuestionCategory.GROSS_MOTOR, child: Text('Vận động thô')),
                                DropdownMenuItem(value: CDDQuestionCategory.FINE_MOTOR, child: Text('Vận động tinh')),
                                DropdownMenuItem(value: CDDQuestionCategory.IMITATION_LEARNING, child: Text('Bắt chước và học')),
                                DropdownMenuItem(value: CDDQuestionCategory.PERSONAL_SOCIAL, child: Text('Cá nhân - Xã hội')),
                                DropdownMenuItem(value: CDDQuestionCategory.OTHER, child: Text('Khác')),
                              ],
                              onChanged: (value) => setState(() => _selectedCategory = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Trọng số *',
                                hintText: '1',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập trọng số' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Required checkbox
                      CheckboxListTile(
                        title: const Text('Câu hỏi bắt buộc'),
                        value: _isRequired,
                        onChanged: (value) => setState(() => _isRequired = value!),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16),
                      
                      // Hints
                      const Text(
                        'Gợi ý',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hintViCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Gợi ý (VI)',
                                hintText: 'Gợi ý bằng tiếng Việt',
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _hintEnCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Gợi ý (EN)',
                                hintText: 'Gợi ý bằng tiếng Anh',
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Explanations
                      const Text(
                        'Giải thích',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _explanationViCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Giải thích (VI)',
                                hintText: 'Giải thích bằng tiếng Việt',
                              ),
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _explanationEnCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Giải thích (EN)',
                                hintText: 'Giải thích bằng tiếng Anh',
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Lưu câu hỏi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
