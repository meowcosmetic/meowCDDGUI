import 'dart:convert';
import 'dart:html' as html;
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

class LoginViewHtml extends StatefulWidget {
  const LoginViewHtml({super.key});

  @override
  State<LoginViewHtml> createState() => _LoginViewHtmlState();
}

class _LoginViewHtmlState extends State<LoginViewHtml> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isFormValid = false;
  final ApiService _api = ApiService();

  // HTML Elements
  late html.InputElement _emailInput;
  late html.InputElement _passwordInput;
  late html.ButtonElement _submitButton;
  late html.FormElement _formElement;

  @override
  void initState() {
    super.initState();
    _initializeHtmlElements();
    _emailCtrl.addListener(_recomputeFormValidity);
    _passwordCtrl.addListener(_recomputeFormValidity);
  }

  void _initializeHtmlElements() {
    // Create HTML form element
    _formElement = html.FormElement()
      ..id = 'login-form'
      ..action = '/login'
      ..method = 'post'
      ..style.cssText = '''
        width: 100%;
        display: flex;
        flex-direction: column;
        gap: 16px;
      ''';

    // Create email input
    _emailInput = html.InputElement()
      ..id = 'email-input'
      ..name = 'email'
      ..type = 'email'
      ..placeholder = 'Nhập email của bạn'
      ..required = true
      ..autocomplete = 'email'
      ..style.cssText = '''
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        font-size: 16px;
        font-family: inherit;
        background-color: white;
        color: #333;
        box-sizing: border-box;
        transition: border-color 0.3s ease;
      ''';

    // Create password input
    _passwordInput = html.InputElement()
      ..id = 'password-input'
      ..name = 'password'
      ..type = 'password'
      ..placeholder = 'Nhập mật khẩu'
      ..required = true
      ..autocomplete = 'current-password'
      ..style.cssText = '''
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        font-size: 16px;
        font-family: inherit;
        background-color: white;
        color: #333;
        box-sizing: border-box;
        transition: border-color 0.3s ease;
      ''';

    // Create submit button
    _submitButton = html.ButtonElement()
      ..id = 'submit-button'
      ..type = 'submit'
      ..text = 'Đăng nhập'
      ..style.cssText = '''
        width: 100%;
        padding: 12px 24px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        background-color: #4caf50;
        color: white;
        transition: background-color 0.3s ease;
      ''';

    // Add event listeners
    _emailInput.addEventListener('input', _onEmailInput);
    _passwordInput.addEventListener('input', _onPasswordInput);
    _formElement.addEventListener('submit', _onFormSubmit);

    // Add elements to form
    _formElement.children.add(_emailInput);
    _formElement.children.add(_passwordInput);
    _formElement.children.add(_submitButton);

    // Add form to body
    html.document.body?.children.add(_formElement);
  }

  void _onEmailInput(html.Event event) {
    final value = _emailInput.value ?? '';
    _emailCtrl.text = value;
    _recomputeFormValidity();
  }

  void _onPasswordInput(html.Event event) {
    final value = _passwordInput.value ?? '';
    _passwordCtrl.text = value;
    _recomputeFormValidity();
  }

  void _onFormSubmit(html.Event event) {
    event.preventDefault();
    _login();
  }

  void _fillWithDummy() {
    _emailInput.value = dummyDevUser.email;
    _passwordInput.value = dummyDevUser.password;
    _emailCtrl.text = dummyDevUser.email;
    _passwordCtrl.text = dummyDevUser.password;
    _recomputeFormValidity();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã điền dữ liệu mẫu (dev).'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _recomputeFormValidity() {
    final valid =
        _emailCtrl.text.trim().isNotEmpty &&
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

    // Remove HTML elements
    _formElement.removeEventListener('submit', _onFormSubmit);
    _emailInput.removeEventListener('input', _onEmailInput);
    _passwordInput.removeEventListener('input', _onPasswordInput);
    _formElement.remove();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_isFormValid) return;

    _submitButton.disabled = true;
    _submitButton.text = 'Đang đăng nhập...';

    try {
      final response = await _api.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Response chỉ chứa token, không có customerId
        final token = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
        if (token.isNotEmpty) {
          await UserSession.updateFromLoginToken(token);
        }
        await prefs.setString('user_email', _emailCtrl.text.trim());

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
            content: Text(
              'Đăng nhập thất bại: ${errorData['message'] ?? 'Email hoặc mật khẩu không đúng'}',
            ),
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
      _submitButton.disabled = false;
      _submitButton.text = 'Đăng nhập';
    }
  }

  void _navigateToRegister() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập (HTML)'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Logo hoặc icon
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                style: TextStyle(fontSize: 16, color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // HTML Form Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email label
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // HTML Email Input
                  HtmlElementView(viewType: 'email-input'),

                  const SizedBox(height: 16),

                  // Password label
                  const Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // HTML Password Input
                  HtmlElementView(viewType: 'password-input'),

                  const SizedBox(height: 24),

                  // HTML Submit Button
                  HtmlElementView(viewType: 'submit-button'),
                ],
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

            const SizedBox(height: 16),
            // Info about HTML form
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Form này sử dụng HTML trực tiếp để tận dụng auto fill của browser.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
