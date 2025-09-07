import 'package:flutter/material.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../models/test_models.dart';
import '../models/api_service.dart';
import '../models/test_result_model.dart';
import '../models/child.dart';
import 'test_taking_page.dart';
import '../features/cdd_test_management/models/cdd_test.dart';

class TestDetailView extends StatefulWidget {
  final String testId;
  final String testTitle;
  final Child? child; // Thêm thông tin về trẻ

  const TestDetailView({
    super.key,
    required this.testId,
    required this.testTitle,
    this.child, // Optional parameter
  });

  @override
  State<TestDetailView> createState() => _TestDetailViewState();
}

class _TestDetailViewState extends State<TestDetailView> {
  Test? test;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTestDetail();
  }

  Future<void> _loadTestDetail() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final response = await _api.getTestById(widget.testId);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Parse using new CDD model then convert to legacy Test model for UI reuse
        final CDDTest cdd = CDDTest.fromJson(data);
        final Test converted = _convertCDDToLegacyTest(cdd);

        setState(() {
          test = converted;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Không thể tải chi tiết bài test. Mã lỗi: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  // Convert new CDDTest model into existing Test model used by TestTakingPage
  Test _convertCDDToLegacyTest(CDDTest cdd) {
    final questions = cdd.questions
        .map((q) => TestQuestion(
              questionId: q.questionId,
              questionNumber: q.questionNumber,
              questionTexts: q.questionTexts,
              category: q.category,
              weight: q.weight,
              required: q.required,
              hints: q.hints,
              explanations: q.explanations,
            ))
        .toList();

    final scoring = ScoringCriteria(
      totalQuestions: cdd.scoringCriteria.totalQuestions,
      yesScore: cdd.scoringCriteria.yesScore,
      noScore: cdd.scoringCriteria.noScore,
      scoreRanges: cdd.scoringCriteria.scoreRanges.map(
        (k, v) => MapEntry(
          k,
          ScoreRange(
            minScore: v.minScore,
            maxScore: v.maxScore,
            level: v.level,
            descriptions: v.descriptions,
            recommendation: v.recommendation,
          ),
        ),
      ),
      interpretation: cdd.scoringCriteria.interpretation,
    );

    return Test(
      id: cdd.id ?? '',
      assessmentCode: cdd.assessmentCode,
      names: cdd.names,
      descriptions: cdd.descriptions,
      instructions: cdd.instructions,
      category: cdd.category,
      minAgeMonths: cdd.minAgeMonths,
      maxAgeMonths: cdd.maxAgeMonths,
      status: cdd.status,
      questions: questions,
      scoringCriteria: scoring,
      notes: cdd.notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(widget.testTitle),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTestDetail,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? _buildErrorState()
              : test == null
                  ? _buildEmptyState()
                  : _buildTestDetail(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTestDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.quiz, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy thông tin bài test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Vui lòng thử lại sau'),
        ],
      ),
    );
  }

  Widget _buildTestDetail() {
    final testData = test!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(testData.category),
                    size: 48,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  testData.getName(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  testData.getDescription(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Test Information
          _buildInfoSection(
            title: 'Thông Tin Bài Test',
            children: [
              _buildInfoRow('Mã bài test', testData.assessmentCode, AppColors.primary),
              _buildInfoRow('Lĩnh vực', testData.getCategoryText(), testData.getCategoryColor()),
              _buildInfoRow('Độ tuổi', testData.getAgeRangeText(), AppColors.primary),
              _buildInfoRow('Số câu hỏi', '${testData.questions.length} câu', AppColors.primary),
              _buildInfoRow('Trạng thái', testData.getStatusText(), testData.getStatusColor()),
              _buildInfoRow('Điểm tối đa', '${testData.getMaxScore()} điểm', AppColors.primary),
            ],
          ),

          const SizedBox(height: 16),

          // Instructions
          if (testData.getInstruction().isNotEmpty)
            _buildInfoSection(
              title: 'Hướng Dẫn',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    testData.getInstruction(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Scoring Criteria
          _buildInfoSection(
            title: 'Tiêu Chí Chấm Điểm',
            children: [
              _buildInfoRow('Điểm "Có"', '${testData.scoringCriteria.yesScore} điểm', AppColors.primary),
              _buildInfoRow('Điểm "Không"', '${testData.scoringCriteria.noScore} điểm', AppColors.primary),
              _buildInfoRow('Tổng câu hỏi', '${testData.scoringCriteria.totalQuestions} câu', AppColors.primary),
              const SizedBox(height: 12),
              Text(
                'Các mức độ nguy cơ:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...testData.scoringCriteria.scoreRanges.values.map((range) => 
                _buildScoreRangeItem(range)
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sample Questions Preview
          if (testData.questions.isNotEmpty)
            _buildInfoSection(
              title: 'Xem Trước Câu Hỏi (${testData.questions.length} câu)',
              children: [
                ...testData.questions.take(3).map((question) => _buildQuestionPreview(question)),
                if (testData.questions.length > 3)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '... và ${testData.questions.length - 3} câu hỏi khác',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 32),

          // Start Test Button - Moved to bottom
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _startTest(testData),
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text(
                'Bắt Đầu Làm Bài Test',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRangeItem(ScoreRange range) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: range.getLevelColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: range.getLevelColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: range.getLevelColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${range.getLevelText()} (${range.minScore}-${range.maxScore} điểm)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: range.getLevelColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  range.getDescription(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (range.recommendation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Khuyến nghị: ${range.recommendation}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPreview(TestQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: question.getCategoryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Câu ${question.questionNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: question.getCategoryColor(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.getCategoryText(),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.getQuestionText(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (question.getHint().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '💡 ${question.getHint()}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startTest(Test test) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestTakingPage(
          test: test,
          child: widget.child, // Truyền thông tin trẻ
        ),
      ),
    );
    
    // Xử lý kết quả sau khi hoàn thành test
    if (result != null && result is Map<String, dynamic> && widget.child != null) {
      await _submitTestResult(result, test);
    }
  }

  Future<void> _submitTestResult(Map<String, dynamic> testResult, Test test) async {
    try {
      // Tạo TestResultModel từ kết quả test
      final now = DateTime.now();
      final testResultModel = TestResultModel(
        childId: widget.child!.id,
        testId: test.id,
        testType: 'CDD_TEST',
        testDate: now,
        startTime: testResult['startTime'] != null ? DateTime.parse(testResult['startTime']) : now,
        endTime: now,
        status: 'COMPLETED',
        totalScore: (testResult['totalScore'] as num?)?.toDouble() ?? 0.0,
        maxScore: (testResult['maxScore'] as num?)?.toDouble() ?? 100.0,
        percentageScore: (testResult['percentageScore'] as num?)?.toDouble() ?? 0.0,
        resultLevel: _getResultLevel((testResult['percentageScore'] as num?)?.toDouble() ?? 0.0),
        interpretation: testResult['interpretation'] ?? 'Kết quả đánh giá phát triển của trẻ.',
        questionAnswers: jsonEncode(testResult['questionAnswers'] ?? {}),
        correctAnswers: testResult['correctAnswers'] ?? 0,
        totalQuestions: testResult['totalQuestions'] ?? test.questions.length,
        skippedQuestions: testResult['skippedQuestions'] ?? 0,
        notes: testResult['notes'] ?? '',
        environment: 'MOBILE_APP',
        assessor: '', // Tạm thời để trống như yêu cầu
        parentPresent: true,
      );

      // Gửi kết quả lên server
      final response = await _api.submitTestResult(testResultModel);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã lưu kết quả bài test thành công!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi lưu kết quả: ${response.statusCode}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi kết quả: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getResultLevel(double percentageScore) {
    if (percentageScore >= 80) return 'EXCELLENT';
    if (percentageScore >= 70) return 'GOOD';
    if (percentageScore >= 60) return 'AVERAGE';
    if (percentageScore >= 50) return 'BELOW_AVERAGE';
    return 'NEEDS_ATTENTION';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'DEVELOPMENTAL_SCREENING':
        return Icons.psychology;
      case 'COMMUNICATION_LANGUAGE':
        return Icons.chat;
      case 'GROSS_MOTOR':
        return Icons.accessibility;
      case 'FINE_MOTOR':
        return Icons.handyman;
      case 'IMITATION_LEARNING':
        return Icons.school;
      case 'PERSONAL_SOCIAL':
        return Icons.people;
      case 'OTHER':
        return Icons.more_horiz;
      default:
        return Icons.quiz;
    }
  }
}
