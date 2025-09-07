import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../models/user.dart';
import '../models/api_service.dart';
import '../dummy_data/dummy_users.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _sex = 'other';
  String _secondaryRole = 'PARENT'; // 'PARENT' or 'TEACHER'

  bool _isSubmitting = false;
  final ApiService _api = ApiService();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo form với trạng thái không hợp lệ
    _isFormValid = false;
    
    // Thêm listeners để validate form khi user nhập liệu
    _nameCtrl.addListener(_recomputeFormValidity);
    _emailCtrl.addListener(_recomputeFormValidity);
    _phoneCtrl.addListener(_recomputeFormValidity);
    _yearCtrl.addListener(_recomputeFormValidity);
    _avatarCtrl.addListener(_recomputeFormValidity);
    _passwordCtrl.addListener(_recomputeFormValidity);
  }

  void _fillWithDummy() {
    final secondary = dummyDevUser.roles
        .map((r) => r.name)
        .firstWhere((r) => r != 'CUSTOMER', orElse: () => 'PARENT');
    setState(() {
      _nameCtrl.text = dummyDevUser.name;
      _emailCtrl.text = dummyDevUser.email;
      _phoneCtrl.text = dummyDevUser.phone;
      _yearCtrl.text = dummyDevUser.yearOfBirth.toString();
      _avatarCtrl.text = dummyDevUser.avatar;
      _passwordCtrl.text = dummyDevUser.password;
      _sex = dummyDevUser.sex; // expects 'male' | 'female' | 'other'
      _secondaryRole = (secondary == 'TEACHER') ? 'TEACHER' : 'PARENT';
    });
    _recomputeFormValidity();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã điền dữ liệu mẫu (dev).'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _recomputeFormValidity() {
    final currentYear = DateTime.now().year;
    final year = int.tryParse(_yearCtrl.text.trim()) ?? 0;
    
    // Validate từng trường một cách chi tiết
    final nameValid = _nameCtrl.text.trim().isNotEmpty;
    final emailValid = _emailCtrl.text.trim().contains('@') && _emailCtrl.text.trim().isNotEmpty;
    final passwordValid = _passwordCtrl.text.length >= 6;
    final phoneValid = _phoneCtrl.text.trim().isNotEmpty;
    final yearValid = year >= 1900 && year <= currentYear;
    
    final valid = nameValid && emailValid && passwordValid && phoneValid && yearValid;
    
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _yearCtrl.dispose();
    _avatarCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final nowIso = DateTime.now().toIso8601String();

    final user = User(
      customerId: 'CUS-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      sex: _sex,
      yearOfBirth: int.tryParse(_yearCtrl.text.trim()) ?? 0,
      avatar: _avatarCtrl.text.trim(),
      addresses: const [], // sẽ chỉnh sửa sau
      cardDetails: const [], // sẽ chỉnh sửa sau
      interactive: 0,
      bought: 0,
      viewed: 0,
      password: _passwordCtrl.text,
      token: '',
      roles: [
        const Role('CUSTOMER'),
        Role(_secondaryRole),
      ],
      metadata: Metadata(
        createdAtIso: nowIso,
        updatedAtIso: nowIso,
        extra: const {},
      ),
    );

    // Send request to backend
    try {
      final resp = await _api.createUser(user);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', user.toJsonString());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại (${resp.statusCode}). Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.'),
        backgroundColor: AppColors.primary,
      ),
    );
    
    // Navigate đến màn hình đăng nhập
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (AppConfig.enableDebugMode)
            IconButton(
              tooltip: 'Điền dữ liệu mẫu (dev)',
              icon: const Icon(Icons.auto_fix_high),
              onPressed: _fillWithDummy,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          autovalidateMode: AutovalidateMode.disabled,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Giới tính'),
                value: _sex,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Nam')),
                  DropdownMenuItem(value: 'female', child: Text('Nữ')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (v) {
                  setState(() => _sex = v ?? 'other');
                  _recomputeFormValidity();
                },
              ),
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(labelText: 'Năm sinh'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final year = int.tryParse(v?.trim() ?? '');
                  final now = DateTime.now().year;
                  if (year == null) return 'Vui lòng nhập số hợp lệ';
                  if (year < 1900 || year > now) return 'Năm sinh không hợp lệ';
                  return null;
                },
              ),
              TextFormField(
                controller: _avatarCtrl,
                decoration: const InputDecoration(labelText: 'Ảnh đại diện (URL hoặc path)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Bạn là'),
                value: _secondaryRole,
                items: const [
                  DropdownMenuItem(value: 'PARENT', child: Text('Phụ huynh')),
                  DropdownMenuItem(value: 'TEACHER', child: Text('Giáo viên')),
                ],
                onChanged: (v) {
                  setState(() => _secondaryRole = v ?? 'PARENT');
                  _recomputeFormValidity();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_isFormValid ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo tài khoản'),
                ),
              ),
              const SizedBox(height: 16),
              // Link đăng nhập
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      ),
                      child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
