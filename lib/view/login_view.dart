import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../models/api_service.dart';
import '../models/policy_service.dart';
import '../dummy_data/dummy_users.dart';
import '../models/user_session.dart';
import 'policy_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _isSubmitting = false;
  bool _isFormValid = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_recomputeFormValidity);
    _passwordCtrl.addListener(_recomputeFormValidity);
  }

  void _fillWithDummy() {
    setState(() {
      _emailCtrl.text = dummyDevUser.email;
      _passwordCtrl.text = dummyDevUser.password;
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
    final valid = _emailCtrl.text.trim().isNotEmpty && 
                  _emailCtrl.text.trim().contains('@') &&
                  _passwordCtrl.text.isNotEmpty;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {      
      final response = await _api.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseData = {'token': response.body};;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', responseData['token'] ?? '');
        if ((responseData['token'] ?? '').toString().isNotEmpty) {
          await UserSession.updateFromLoginToken(responseData['token']);
        }
        await prefs.setString('user_email', _emailCtrl.text.trim());
        
        // Lưu customer ID từ response - bắt buộc phải có
        await prefs.setString('customer_id', responseData['customerId']);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng nhập thành công!'),
            backgroundColor: AppColors.primary,
          ),
        );
        
        // Kiểm tra có cần hiển thị policy screen không
        if (AppConfig.showPolicyScreen) {
          final shouldShowPolicy = await PolicyService.shouldShowPolicyScreen();
          if (shouldShowPolicy) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PolicyView()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainAppView()),
            );
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainAppView()),
          );
        }
              } else {
          if (!mounted) return;
          // Parse error response
          Map<String, dynamic> errorData = {};
          try {
            errorData = jsonDecode(response.body);
          } catch (e) {
            errorData = {'message': 'Email hoặc mật khẩu không đúng'};
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thất bại: ${errorData['message'] ?? 'Email hoặc mật khẩu không đúng'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối máy chủ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
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
              const SizedBox(height: 32),
              // Logo hoặc icon
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Tiêu đề
              const Center(
                child: Text(
                  'Chào mừng bạn trở lại!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Đăng nhập để tiếp tục hành trình hạnh phúc',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Form fields
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 24),
              // Nút đăng nhập
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_isFormValid ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 16),
              // Link đăng ký
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text(
                        'Đăng ký ngay',
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
