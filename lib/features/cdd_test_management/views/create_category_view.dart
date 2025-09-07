import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../uiElement/form.dart';
import '../../../uiElement/button.dart';
import '../../../models/api_service.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  final ApiService _api = ApiService();

  Future<void> _handleSubmit(Map<String, dynamic> values) async {
    final code = (values['code'] as String?)?.trim() ?? '';
    final nameVi = (values['name_vi'] as String?)?.trim() ?? '';
    final nameEn = (values['name_en'] as String?)?.trim() ?? '';
    final descVi = (values['desc_vi'] as String?)?.trim();
    final descEn = (values['desc_en'] as String?)?.trim();

    if (code.isEmpty || nameVi.isEmpty || nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ Code, Tên VI và EN')),
      );
      return;
    }

    final displayedName = <String, Object>{
      'vi': nameVi,
      'en': nameEn,
    };

    final Map<String, Object>? description = (descVi?.isNotEmpty == true || descEn?.isNotEmpty == true)
        ? {
            if (descVi != null && descVi.isNotEmpty) 'vi': descVi,
            if (descEn != null && descEn.isNotEmpty) 'en': descEn,
          }
        : null;

    final resp = await _api.createTestCategory(
      code: code,
      displayedName: displayedName,
      description: description,
    );

    if (!mounted) return;

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo category thành công')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${resp.statusCode} - ${resp.body}')),
      );
    }
  }

  FormConfig _formConfig() {
    return FormConfig(
      title: 'Thêm Category Bài Test',
      description: 'Nhập thông tin theo ngôn ngữ VI/EN',
      fields: const [
        FormFieldConfig(
          name: 'code',
          label: 'Code (duy nhất)',
          placeholder: 'VD: AUTISM_SCREENING',
          type: FieldType.text,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.minLength, value: 2),
          ],
        ),
        FormFieldConfig(
          name: 'name_vi',
          label: 'Tên (VI)',
          placeholder: 'Tên tiếng Việt',
          type: FieldType.text,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'name_en',
          label: 'Name (EN)',
          placeholder: 'English name',
          type: FieldType.text,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'desc_vi',
          label: 'Mô tả (VI)',
          placeholder: 'Mô tả tiếng Việt',
          type: FieldType.multiline,
        ),
        FormFieldConfig(
          name: 'desc_en',
          label: 'Description (EN)',
          placeholder: 'English description',
          type: FieldType.multiline,
        ),
      ],
      actions: [
        FormAction(
          text: 'Hủy',
          type: ButtonType.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        FormAction(
          text: 'Lưu',
          type: ButtonType.primary,
          icon: Icons.save,
          isSubmit: true,
        ),
      ],
      showCard: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DynamicForm(
          config: _formConfig(),
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}


