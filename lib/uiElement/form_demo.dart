import 'package:flutter/material.dart';
import 'form.dart';
import 'button.dart';
import '../constants/app_colors.dart';

class FormDemo extends StatefulWidget {
  final bool showAppBar;

  const FormDemo({super.key, this.showAppBar = true});

  @override
  State<FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<FormDemo> {
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Dynamic Form Demo'),
              backgroundColor: AppColors.cardBorder,
              foregroundColor: AppColors.white,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Registration Form', [
              DynamicForm(
                config: _getRegistrationFormConfig(),
                onSubmit: _handleFormSubmit,
                onChanged: _handleFormChanged,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSection('Contact Form', [
              DynamicForm(
                config: _getContactFormConfig(),
                onSubmit: _handleFormSubmit,
                onChanged: _handleFormChanged,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSection('Survey Form', [
              DynamicForm(
                config: _getSurveyFormConfig(),
                onSubmit: _handleFormSubmit,
                onChanged: _handleFormChanged,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSection('Settings Form', [
              DynamicForm(
                config: _getSettingsFormConfig(),
                onSubmit: _handleFormSubmit,
                onChanged: _handleFormChanged,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSection('Form Data Preview', [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Form Data:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formData.isEmpty ? 'No data yet' : _formData.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  FormConfig _getRegistrationFormConfig() {
    return const FormConfig(
      title: 'User Registration',
      description: 'Please fill in your information to create an account',
      fields: [
        FormFieldConfig(
          name: 'firstName',
          label: 'First Name',
          placeholder: 'Enter your first name',
          type: FieldType.text,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.minLength, value: 2),
          ],
        ),
        FormFieldConfig(
          name: 'lastName',
          label: 'Last Name',
          placeholder: 'Enter your last name',
          type: FieldType.text,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.minLength, value: 2),
          ],
        ),
        FormFieldConfig(
          name: 'email',
          label: 'Email Address',
          placeholder: 'Enter your email',
          type: FieldType.email,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.email),
          ],
        ),
        FormFieldConfig(
          name: 'password',
          label: 'Password',
          placeholder: 'Enter your password',
          type: FieldType.password,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.minLength, value: 8),
          ],
        ),
        FormFieldConfig(
          name: 'phone',
          label: 'Phone Number',
          placeholder: 'Enter your phone number',
          type: FieldType.phone,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'dateOfBirth',
          label: 'Date of Birth',
          type: FieldType.date,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'gender',
          label: 'Gender',
          type: FieldType.radio,
          options: ['Male', 'Female', 'Other'],
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'terms',
          label: 'I agree to the terms and conditions',
          type: FieldType.checkbox,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
      ],
      actions: [
        FormAction(text: 'Cancel', type: ButtonType.secondary, onPressed: null),
        FormAction(
          text: 'Register',
          type: ButtonType.primary,
          icon: Icons.person_add,
          isSubmit: true,
        ),
      ],
    );
  }

  FormConfig _getContactFormConfig() {
    return const FormConfig(
      title: 'Contact Us',
      description: 'Send us a message and we\'ll get back to you',
      fields: [
        FormFieldConfig(
          name: 'name',
          label: 'Your Name',
          placeholder: 'Enter your full name',
          type: FieldType.text,
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'email',
          label: 'Email',
          placeholder: 'Enter your email address',
          type: FieldType.email,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.email),
          ],
        ),
        FormFieldConfig(
          name: 'subject',
          label: 'Subject',
          placeholder: 'What is this about?',
          type: FieldType.dropdown,
          options: ['General Inquiry', 'Support', 'Feedback', 'Other'],
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'message',
          label: 'Message',
          placeholder: 'Tell us more...',
          type: FieldType.multiline,
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.minLength, value: 10),
          ],
        ),
        FormFieldConfig(
          name: 'urgent',
          label: 'Mark as urgent',
          type: FieldType.switch_,
        ),
      ],
      actions: [
        FormAction(text: 'Clear', type: ButtonType.ghost, onPressed: null),
        FormAction(
          text: 'Send Message',
          type: ButtonType.primary,
          icon: Icons.send,
          isSubmit: true,
        ),
      ],
    );
  }

  FormConfig _getSurveyFormConfig() {
    return const FormConfig(
      title: 'Customer Satisfaction Survey',
      description: 'Help us improve our services by sharing your feedback',
      fields: [
        FormFieldConfig(
          name: 'satisfaction',
          label: 'How satisfied are you with our service?',
          type: FieldType.radio,
          options: [
            'Very Satisfied',
            'Satisfied',
            'Neutral',
            'Dissatisfied',
            'Very Dissatisfied',
          ],
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'recommend',
          label: 'Would you recommend us to others?',
          type: FieldType.radio,
          options: [
            'Definitely',
            'Probably',
            'Not sure',
            'Probably not',
            'Definitely not',
          ],
          validations: [ValidationRule(type: ValidationType.required)],
        ),
        FormFieldConfig(
          name: 'features',
          label: 'Which features do you use most? (Select all that apply)',
          type: FieldType.checkbox,
          extraData: {'multiple': true},
        ),
        FormFieldConfig(
          name: 'improvements',
          label: 'What could we improve?',
          placeholder: 'Share your suggestions...',
          type: FieldType.multiline,
        ),
        FormFieldConfig(
          name: 'age',
          label: 'Age Group',
          type: FieldType.dropdown,
          options: ['18-24', '25-34', '35-44', '45-54', '55+'],
        ),
        FormFieldConfig(
          name: 'contact',
          label: 'Can we contact you for follow-up?',
          type: FieldType.switch_,
        ),
      ],
      actions: [
        FormAction(text: 'Skip', type: ButtonType.secondary, onPressed: null),
        FormAction(
          text: 'Submit Survey',
          type: ButtonType.primary,
          icon: Icons.check_circle,
          isSubmit: true,
        ),
      ],
    );
  }

  FormConfig _getSettingsFormConfig() {
    return const FormConfig(
      title: 'Account Settings',
      description: 'Update your account preferences',
      fields: [
        FormFieldConfig(
          name: 'displayName',
          label: 'Display Name',
          placeholder: 'Enter display name',
          type: FieldType.text,
          defaultValue: 'John Doe',
        ),
        FormFieldConfig(
          name: 'email',
          label: 'Email Address',
          placeholder: 'Enter email address',
          type: FieldType.email,
          defaultValue: 'john@example.com',
          validations: [
            ValidationRule(type: ValidationType.required),
            ValidationRule(type: ValidationType.email),
          ],
        ),
        FormFieldConfig(
          name: 'timezone',
          label: 'Timezone',
          type: FieldType.dropdown,
          options: ['UTC', 'EST', 'PST', 'GMT', 'CET'],
          defaultValue: 'UTC',
        ),
        FormFieldConfig(
          name: 'notifications',
          label: 'Enable Notifications',
          type: FieldType.switch_,
          defaultValue: 'true',
        ),
        FormFieldConfig(
          name: 'emailNotifications',
          label: 'Email Notifications',
          type: FieldType.switch_,
          defaultValue: 'true',
        ),
        FormFieldConfig(
          name: 'theme',
          label: 'Theme Preference',
          type: FieldType.radio,
          options: ['Light', 'Dark', 'System'],
          defaultValue: 'System',
        ),
        FormFieldConfig(
          name: 'language',
          label: 'Language',
          type: FieldType.dropdown,
          options: ['English', 'Spanish', 'French', 'German'],
          defaultValue: 'English',
        ),
      ],
      actions: [
        FormAction(text: 'Reset', type: ButtonType.outline, onPressed: null),
        FormAction(
          text: 'Save Changes',
          type: ButtonType.primary,
          icon: Icons.save,
          isSubmit: true,
        ),
      ],
    );
  }

  void _handleFormSubmit(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form submitted: ${data.toString()}'),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleFormChanged(Map<String, dynamic> data) {
    setState(() {
      _formData = data;
    });
  }
}
