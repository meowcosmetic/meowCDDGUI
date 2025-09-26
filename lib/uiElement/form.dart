import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'button.dart';
import 'card.dart';
import '../constants/app_colors.dart';

enum FieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  dropdown,
  checkbox,
  radio,
  date,
  time,
  file,
  switch_,
}

enum ValidationType { required, email, minLength, maxLength, pattern, custom }

class FormFieldConfig {
  final String name;
  final String label;
  final String? placeholder;
  final FieldType type;
  final String? defaultValue;
  final List<String>? options; // For dropdown, radio
  final List<ValidationRule>? validations;
  final bool enabled;
  final bool visible;
  final Map<String, dynamic>? extraData;

  const FormFieldConfig({
    required this.name,
    required this.label,
    this.placeholder,
    required this.type,
    this.defaultValue,
    this.options,
    this.validations,
    this.enabled = true,
    this.visible = true,
    this.extraData,
  });
}

class ValidationRule {
  final ValidationType type;
  final String? message;
  final dynamic value; // For minLength, maxLength, pattern, etc.

  const ValidationRule({required this.type, this.message, this.value});
}

class FormConfig {
  final String title;
  final String? description;
  final List<FormFieldConfig> fields;
  final List<FormAction> actions;
  final bool showCard;
  final CardType cardType;
  final CardSize cardSize;

  const FormConfig({
    required this.title,
    this.description,
    required this.fields,
    required this.actions,
    this.showCard = true,
    this.cardType = CardType.default_,
    this.cardSize = CardSize.medium,
  });
}

class FormAction {
  final String text;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSubmit;

  const FormAction({
    required this.text,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.onPressed,
    this.isSubmit = false,
  });
}

class DynamicForm extends StatefulWidget {
  final FormConfig config;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function(Map<String, dynamic>)? onChanged;
  final Map<String, dynamic>? initialValues;

  const DynamicForm({
    super.key,
    required this.config,
    this.onSubmit,
    this.onChanged,
    this.initialValues,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    for (var field in widget.config.fields) {
      _controllers[field.name] = TextEditingController(
        text:
            widget.initialValues?[field.name]?.toString() ??
            field.defaultValue ??
            '',
      );
      _focusNodes[field.name] = FocusNode();

      // Initialize form data based on field type
      if (field.type == FieldType.checkbox || field.type == FieldType.switch_) {
        // For boolean fields, convert string to bool
        final defaultValue = field.defaultValue;
        bool boolValue = false;
        if (defaultValue != null) {
          if (defaultValue.toLowerCase() == 'true') {
            boolValue = true;
          } else if (defaultValue.toLowerCase() == 'false') {
            boolValue = false;
          }
        }
        _formData[field.name] = widget.initialValues?[field.name] ?? boolValue;
      } else {
        // For other fields, use string value
        _formData[field.name] =
            widget.initialValues?[field.name] ?? field.defaultValue ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.config.title.isNotEmpty) ...[
            Text(
              widget.config.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.config.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.config.description!,
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
            ],
            const SizedBox(height: 24),
          ],
          ...widget.config.fields
              .where((field) => field.visible)
              .map((field) => _buildField(field)),
          const SizedBox(height: 24),
          _buildActions(),
        ],
      ),
    );

    if (widget.config.showCard) {
      return MeowCard(
        title: widget.config.title.isNotEmpty ? null : widget.config.title,
        content: formContent,
        type: widget.config.cardType,
        size: widget.config.cardSize,
      );
    }

    return formContent;
  }

  Widget _buildField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildFieldByType(field),
    );
  }

  Widget _buildFieldByType(FormFieldConfig field) {
    switch (field.type) {
      case FieldType.text:
        return _buildTextField(field);
      case FieldType.email:
        return _buildEmailField(field);
      case FieldType.password:
        return _buildPasswordField(field);
      case FieldType.number:
        return _buildNumberField(field);
      case FieldType.phone:
        return _buildPhoneField(field);
      case FieldType.multiline:
        return _buildMultilineField(field);
      case FieldType.dropdown:
        return _buildDropdownField(field);
      case FieldType.checkbox:
        return _buildCheckboxField(field);
      case FieldType.radio:
        return _buildRadioField(field);
      case FieldType.date:
        return _buildDateField(field);
      case FieldType.time:
        return _buildTimeField(field);
      case FieldType.file:
        return _buildFileField(field);
      case FieldType.switch_:
        return _buildSwitchField(field);
    }
  }

  Widget _buildTextField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
      ),
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildEmailField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildPasswordField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {
            // Toggle password visibility
          },
        ),
      ),
      obscureText: true,
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildNumberField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildPhoneField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildMultilineField(FormFieldConfig field) {
    return TextFormField(
      controller: _controllers[field.name],
      focusNode: _focusNodes[field.name],
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      onChanged: (value) => _updateFieldValue(field.name, value),
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildDropdownField(FormFieldConfig field) {
    final currentValue = _formData[field.name] as String?;
    final options = field.options ?? [];

    // Ensure the current value is in the options list
    String? validValue = currentValue;
    if (currentValue != null && !options.contains(currentValue)) {
      validValue = null;
    }

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        enabled: field.enabled,
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: field.enabled
          ? (value) => _updateFieldValue(field.name, value)
          : null,
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildCheckboxField(FormFieldConfig field) {
    return CheckboxListTile(
      title: Text(field.label),
      value: _formData[field.name] as bool? ?? false,
      onChanged: field.enabled
          ? (value) => _updateFieldValue(field.name, value)
          : null,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildRadioField(FormFieldConfig field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...field.options?.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _formData[field.name] as String?,
                onChanged: field.enabled
                    ? (value) => _updateFieldValue(field.name, value)
                    : null,
              );
            }).toList() ??
            [],
      ],
    );
  }

  Widget _buildDateField(FormFieldConfig field) {
    return InkWell(
      onTap: field.enabled ? () => _selectDate(field) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          enabled: field.enabled,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          _formData[field.name]?.toString() ?? 'Select date',
          style: TextStyle(
            color: _formData[field.name] != null
                ? AppColors.textPrimary
                : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(FormFieldConfig field) {
    return InkWell(
      onTap: field.enabled ? () => _selectTime(field) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          enabled: field.enabled,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          _formData[field.name]?.toString() ?? 'Select time',
          style: TextStyle(
            color: _formData[field.name] != null
                ? AppColors.textPrimary
                : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  Widget _buildFileField(FormFieldConfig field) {
    return ElevatedButton.icon(
      onPressed: field.enabled ? () => _selectFile(field) : null,
      icon: const Icon(Icons.attach_file),
      label: Text(_formData[field.name]?.toString() ?? 'Select file'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.grey200,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSwitchField(FormFieldConfig field) {
    return SwitchListTile(
      title: Text(field.label),
      value: _formData[field.name] as bool? ?? false,
      onChanged: field.enabled
          ? (value) => _updateFieldValue(field.name, value)
          : null,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widget.config.actions.map((action) {
        Widget button;

        switch (action.type) {
          case ButtonType.primary:
            button = PrimaryButton(
              text: action.text,
              size: action.size,
              icon: action.icon,
              onPressed: action.isSubmit ? _handleSubmit : action.onPressed,
            );
            break;
          case ButtonType.secondary:
            button = SecondaryButton(
              text: action.text,
              size: action.size,
              icon: action.icon,
              onPressed: action.onPressed,
            );
            break;
          case ButtonType.outline:
            button = OutlineButton(
              text: action.text,
              size: action.size,
              icon: action.icon,
              onPressed: action.onPressed,
            );
            break;
          case ButtonType.ghost:
            button = GhostButton(
              text: action.text,
              size: action.size,
              icon: action.icon,
              onPressed: action.onPressed,
            );
            break;
          case ButtonType.destructive:
            button = DestructiveButton(
              text: action.text,
              size: action.size,
              icon: action.icon,
              onPressed: action.onPressed,
            );
            break;
        }

        return Padding(padding: const EdgeInsets.only(left: 8), child: button);
      }).toList(),
    );
  }

  void _updateFieldValue(String fieldName, dynamic value) {
    setState(() {
      _formData[fieldName] = value;
    });
    widget.onChanged?.call(_formData);
  }

  String? _validateField(FormFieldConfig field, dynamic value) {
    if (field.validations == null) return null;

    for (var validation in field.validations!) {
      switch (validation.type) {
        case ValidationType.required:
          if (value == null || value.toString().trim().isEmpty) {
            return validation.message ?? 'This field is required';
          }
          break;
        case ValidationType.email:
          if (value != null && value.toString().isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value.toString())) {
              return validation.message ?? 'Please enter a valid email';
            }
          }
          break;
        case ValidationType.minLength:
          if (value != null && value.toString().length < validation.value) {
            return validation.message ??
                'Minimum length is ${validation.value} characters';
          }
          break;
        case ValidationType.maxLength:
          if (value != null && value.toString().length > validation.value) {
            return validation.message ??
                'Maximum length is ${validation.value} characters';
          }
          break;
        case ValidationType.pattern:
          if (value != null && value.toString().isNotEmpty) {
            final pattern = RegExp(validation.value);
            if (!pattern.hasMatch(value.toString())) {
              return validation.message ?? 'Invalid format';
            }
          }
          break;
        case ValidationType.custom:
          // Custom validation logic can be implemented here
          break;
      }
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call(_formData);
    }
  }

  Future<void> _selectDate(FormFieldConfig field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      _updateFieldValue(field.name, picked.toIso8601String().split('T')[0]);
    }
  }

  Future<void> _selectTime(FormFieldConfig field) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _updateFieldValue(field.name, picked.format(context));
    }
  }

  void _selectFile(FormFieldConfig field) {
    // File selection logic can be implemented here
    _updateFieldValue(field.name, 'selected_file.txt');
  }
}
