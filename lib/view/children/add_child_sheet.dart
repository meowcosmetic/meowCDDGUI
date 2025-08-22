import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/api_service.dart';
import '../../models/child.dart';
import '../../models/user_session.dart';
import 'language_dropdown.dart';

class AddChildSheet extends StatefulWidget {
  const AddChildSheet({super.key});

  @override
  State<AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<AddChildSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _dateOfBirth = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _allergies = TextEditingController();
  final TextEditingController _medicalHistory = TextEditingController();
  final TextEditingController _specialMedicalConditions = TextEditingController();
  final TextEditingController _gestationalWeek = TextEditingController();
  final TextEditingController _birthWeightGrams = TextEditingController();
  final TextEditingController _earlyInterventionDetails = TextEditingController();
  final TextEditingController _familyDevelopmentalIssues = TextEditingController();
  
  String _primaryLanguage = 'Vietnamese';
  String _gender = 'MALE';
  String _bloodType = 'A+';
  bool _isPremature = false;
  String _developmentalDisorderDiagnosis = 'NOT_EVALUATED';
  bool _hasEarlyIntervention = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
            decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: const [
                Text('Thêm Trẻ Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field('Họ và tên đầy đủ', _fullName, validator: (v) => v == null || v.trim().isEmpty ? 'Nhập họ và tên' : null),
                    _field('Ngày sinh (YYYY-MM-DD)', _dateOfBirth, validator: (v) => v == null || v.trim().isEmpty ? 'Nhập ngày sinh' : null),
                    
                    Row(
                      children: [
                        Expanded(child: _genderPicker()),
                        const SizedBox(width: 12),
                        Expanded(child: _bloodTypePicker()),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(child: _field('Chiều cao (cm)', _height, keyboardType: TextInputType.number, validator: (v) {
                          if (v == null || v.isEmpty) return 'Nhập chiều cao';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Chiều cao không hợp lệ';
                          return null;
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Cân nặng (kg)', _weight, keyboardType: TextInputType.number, validator: (v) {
                          if (v == null || v.isEmpty) return 'Nhập cân nặng';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Cân nặng không hợp lệ';
                          return null;
                        })),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(child: _field('Tuần thai (nếu sinh non)', _gestationalWeek, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Cân nặng lúc sinh (gram)', _birthWeightGrams, keyboardType: TextInputType.number)),
                      ],
                    ),
                    
                    _field('Dị ứng', _allergies),
                    _field('Tiền sử bệnh lý', _medicalHistory),
                    _field('Tình trạng y tế đặc biệt', _specialMedicalConditions),
                    _field('Chi tiết can thiệp sớm', _earlyInterventionDetails),
                    _field('Vấn đề phát triển gia đình', _familyDevelopmentalIssues),
                    
                    LanguageDropdown(
                      value: _primaryLanguage,
                      onChanged: (value) => setState(() => _primaryLanguage = value ?? 'Vietnamese'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Checkboxes
                    _buildCheckbox('Sinh non', _isPremature, (value) => setState(() => _isPremature = value)),
                    _buildCheckbox('Có can thiệp sớm', _hasEarlyIntervention, (value) => setState(() => _hasEarlyIntervention = value)),
                    
                    const SizedBox(height: 16),
                    
                    // Developmental Disorder Diagnosis
                    _buildDiagnosisDropdown(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                        )
                      : const Text('Thêm Trẻ'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _genderPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(border: InputBorder.none, labelText: 'Giới tính'),
        items: const [
          DropdownMenuItem(value: 'MALE', child: Text('Nam')),
          DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
          DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
        ],
        onChanged: (v) => setState(() => _gender = v ?? 'MALE'),
      ),
    );
  }

  Widget _bloodTypePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: _bloodType,
        decoration: const InputDecoration(border: InputBorder.none, labelText: 'Nhóm máu'),
        items: const [
          DropdownMenuItem(value: 'A+', child: Text('A+')),
          DropdownMenuItem(value: 'A-', child: Text('A-')),
          DropdownMenuItem(value: 'B+', child: Text('B+')),
          DropdownMenuItem(value: 'B-', child: Text('B-')),
          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
          DropdownMenuItem(value: 'O+', child: Text('O+')),
          DropdownMenuItem(value: 'O-', child: Text('O-')),
          DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
        ],
        onChanged: (v) => setState(() => _bloodType = v ?? 'A+'),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: AppColors.primary,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDiagnosisDropdown() {
    final diagnosisOptions = {
      'NOT_EVALUATED': 'Chưa đánh giá',
      'NO': 'Không có',
      'YES': 'Có',
      'UNDER_INVESTIGATION': 'Đang tìm hiểu',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chẩn đoán rối loạn phát triển',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonFormField<String>(
              value: _developmentalDisorderDiagnosis,
              decoration: const InputDecoration(border: InputBorder.none),
              items: diagnosisOptions.entries.map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              )).toList(),
              onChanged: (value) => setState(() => _developmentalDisorderDiagnosis = value ?? 'NOT_EVALUATED'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.grey50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Đảm bảo UserSession đã được khởi tạo
      await UserSession.initFromPrefs();
      
      // Debug: Kiểm tra session
      print('DEBUG: UserSession.userId = ${UserSession.userId}');
      print('DEBUG: UserSession.jwtToken = ${UserSession.jwtToken?.substring(0, 20)}...');
      
      final apiService = ApiService();
      
      // Chuẩn bị dữ liệu cho API sử dụng model ChildData
      final childData = ChildData(
        fullName: _fullName.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth.text.trim(),
        height: double.tryParse(_height.text.trim()),
        weight: double.tryParse(_weight.text.trim()),
        bloodType: _bloodType,
        allergies: _allergies.text.trim(),
        medicalHistory: _medicalHistory.text.trim(),
        specialMedicalConditions: _specialMedicalConditions.text.trim(),
        isPremature: _isPremature,
        primaryLanguage: LanguageDropdown.languageOptions[_primaryLanguage] ?? 'Tiếng Việt',
        developmentalDisorderDiagnosis: _developmentalDisorderDiagnosis,
        hasEarlyIntervention: _hasEarlyIntervention,
        familyDevelopmentalIssues: _familyDevelopmentalIssues.text.trim(),
        gestationalWeek: _gestationalWeek.text.trim().isNotEmpty ? int.tryParse(_gestationalWeek.text.trim()) : null,
        birthWeightGrams: _birthWeightGrams.text.trim().isNotEmpty ? int.tryParse(_birthWeightGrams.text.trim()) : null,
        earlyInterventionDetails: _earlyInterventionDetails.text.trim().isNotEmpty ? _earlyInterventionDetails.text.trim() : null,
        status: 'ACTIVE',
      );

      final response = await apiService.createChild(childData);
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final childName = _fullName.text.trim();
        
        // Pop với kiểm tra an toàn
        if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(childData.toJson());
        }
        
        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm trẻ thành công: $childName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        throw Exception('Failed to add child: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      
      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm trẻ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
