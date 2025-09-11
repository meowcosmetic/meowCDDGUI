import 'package:flutter/material.dart';
import 'dart:html' as html;

/// HTML Form Field Widget for Flutter Web
/// Tạo HTML input trực tiếp để tận dụng auto fill của browser
class HtmlFormField extends StatefulWidget {
  final String label;
  final String? value;
  final String? placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final String htmlId;
  final String htmlName;
  final String? htmlAutocomplete;

  const HtmlFormField({
    super.key,
    required this.label,
    this.value,
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.textInputAction,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    required this.htmlId,
    required this.htmlName,
    this.htmlAutocomplete,
  });

  @override
  State<HtmlFormField> createState() => _HtmlFormFieldState();
}

class _HtmlFormFieldState extends State<HtmlFormField> {
  late html.InputElement _inputElement;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeInputElement();
  }

  void _initializeInputElement() {
    _inputElement = html.InputElement()
      ..id = widget.htmlId
      ..name = widget.htmlName
      ..value = widget.value ?? ''
      ..placeholder = widget.placeholder ?? ''
      ..disabled = !widget.enabled
      ..style.cssText = '''
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        font-size: 16px;
        font-family: inherit;
        background-color: ${widget.enabled ? 'white' : '#f5f5f5'};
        color: ${widget.enabled ? '#333' : '#999'};
        box-sizing: border-box;
        transition: border-color 0.3s ease;
      ''';

    // Set input type based on keyboardType and obscureText
    if (widget.obscureText) {
      _inputElement.type = 'password';
    } else if (widget.keyboardType == TextInputType.emailAddress) {
      _inputElement.type = 'email';
    } else if (widget.keyboardType == TextInputType.phone) {
      _inputElement.type = 'tel';
    } else if (widget.keyboardType == TextInputType.number) {
      _inputElement.type = 'number';
    } else {
      _inputElement.type = 'text';
    }

    // Set autocomplete attribute
    if (widget.htmlAutocomplete != null) {
      _inputElement.setAttribute('autocomplete', widget.htmlAutocomplete!);
    }

    // Set required attribute for validation
    _inputElement.required = widget.validator != null;

    // Add event listeners
    _inputElement.addEventListener('input', _onInput);
    _inputElement.addEventListener('blur', _onBlur);
    _inputElement.addEventListener('focus', _onFocus);
  }

  void _onInput(html.Event event) {
    final value = _inputElement.value ?? '';
    widget.onChanged?.call(value);
    _validateInput(value);
  }

  void _onBlur(html.Event event) {
    final value = _inputElement.value ?? '';
    _validateInput(value);
  }

  void _onFocus(html.Event event) {
    // Remove error styling when focused
    _inputElement.style.borderColor = '#e0e0e0';
  }

  void _validateInput(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorText = error;
      });
      
      if (error != null) {
        _inputElement.style.borderColor = '#f44336';
      } else {
        _inputElement.style.borderColor = '#4caf50';
      }
    }
  }

  @override
  void dispose() {
    _inputElement.removeEventListener('input', _onInput);
    _inputElement.removeEventListener('blur', _onBlur);
    _inputElement.removeEventListener('focus', _onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        
        // Input container with prefix/suffix icons
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _errorText != null ? Colors.red : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Prefix icon
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.prefixIcon!,
                ),
              ],
              
              // HTML Input Element
              Expanded(
                child: HtmlElementView(
                  viewType: _inputElement.id,
                ),
              ),
              
              // Suffix icon
              if (widget.suffixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.suffixIcon!,
                ),
              ],
            ],
          ),
        ),
        
        // Error text
        if (_errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            _errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// HTML Form Widget for Flutter Web
/// Tạo HTML form trực tiếp để browser nhận diện
class HtmlForm extends StatefulWidget {
  final List<Widget> children;
  final String? htmlAction;
  final String? htmlMethod;
  final void Function()? onSubmit;

  const HtmlForm({
    super.key,
    required this.children,
    this.htmlAction,
    this.htmlMethod,
    this.onSubmit,
  });

  @override
  State<HtmlForm> createState() => _HtmlFormState();
}

class _HtmlFormState extends State<HtmlForm> {
  late html.FormElement _formElement;

  @override
  void initState() {
    super.initState();
    _initializeFormElement();
  }

  void _initializeFormElement() {
    _formElement = html.FormElement()
      ..action = widget.htmlAction ?? ''
      ..method = widget.htmlMethod ?? 'post'
      ..style.cssText = 'width: 100%;';

    // Add submit event listener
    _formElement.addEventListener('submit', _onSubmit);
  }

  void _onSubmit(html.Event event) {
    event.preventDefault();
    widget.onSubmit?.call();
  }

  @override
  void dispose() {
    _formElement.removeEventListener('submit', _onSubmit);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children,
    );
  }
}

/// HTML Submit Button Widget for Flutter Web
class HtmlSubmitButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const HtmlSubmitButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<HtmlSubmitButton> createState() => _HtmlSubmitButtonState();
}

class _HtmlSubmitButtonState extends State<HtmlSubmitButton> {
  late html.ButtonElement _buttonElement;

  @override
  void initState() {
    super.initState();
    _initializeButtonElement();
  }

  void _initializeButtonElement() {
    _buttonElement = html.ButtonElement()
      ..type = 'submit'
      ..text = widget.text
      ..disabled = widget.onPressed == null || widget.isLoading
      ..style.cssText = '''
        width: 100%;
        padding: 12px 24px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: ${widget.onPressed == null || widget.isLoading ? 'not-allowed' : 'pointer'};
        background-color: ${widget.backgroundColor?.value.toRadixString(16).substring(2) ?? '4caf50'};
        color: ${widget.textColor?.value.toRadixString(16).substring(2) ?? 'ffffff'};
        opacity: ${widget.onPressed == null || widget.isLoading ? '0.6' : '1.0'};
        transition: opacity 0.3s ease;
      ''';

    // Add click event listener
    _buttonElement.addEventListener('click', _onClick);
  }

  void _onClick(html.Event event) {
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  @override
  void dispose() {
    _buttonElement.removeEventListener('click', _onClick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: HtmlElementView(
        viewType: _buttonElement.id,
      ),
    );
  }
}
