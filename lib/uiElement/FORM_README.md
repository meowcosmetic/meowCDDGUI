# Dynamic Form System Documentation

Hệ thống form động có thể cấu hình hoàn toàn dựa trên metadata. Tạo form từ cấu hình JSON hoặc code một cách dễ dàng.

## Các loại Field

### 1. Text Fields
```dart
FormFieldConfig(
  name: 'firstName',
  label: 'First Name',
  placeholder: 'Enter your first name',
  type: FieldType.text,
  validations: [
    ValidationRule(type: ValidationType.required),
    ValidationRule(type: ValidationType.minLength, value: 2),
  ],
)
```

### 2. Email Field
```dart
FormFieldConfig(
  name: 'email',
  label: 'Email Address',
  placeholder: 'Enter your email',
  type: FieldType.email,
  validations: [
    ValidationRule(type: ValidationType.required),
    ValidationRule(type: ValidationType.email),
  ],
)
```

### 3. Password Field
```dart
FormFieldConfig(
  name: 'password',
  label: 'Password',
  placeholder: 'Enter your password',
  type: FieldType.password,
  validations: [
    ValidationRule(type: ValidationType.required),
    ValidationRule(type: ValidationType.minLength, value: 8),
  ],
)
```

### 4. Number Field
```dart
FormFieldConfig(
  name: 'age',
  label: 'Age',
  placeholder: 'Enter your age',
  type: FieldType.number,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 5. Phone Field
```dart
FormFieldConfig(
  name: 'phone',
  label: 'Phone Number',
  placeholder: 'Enter your phone number',
  type: FieldType.phone,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 6. Multiline Text Field
```dart
FormFieldConfig(
  name: 'message',
  label: 'Message',
  placeholder: 'Tell us more...',
  type: FieldType.multiline,
  validations: [
    ValidationRule(type: ValidationType.required),
    ValidationRule(type: ValidationType.minLength, value: 10),
  ],
)
```

### 7. Dropdown Field
```dart
FormFieldConfig(
  name: 'country',
  label: 'Country',
  type: FieldType.dropdown,
  options: ['USA', 'Canada', 'UK', 'Australia'],
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 8. Checkbox Field
```dart
FormFieldConfig(
  name: 'terms',
  label: 'I agree to the terms and conditions',
  type: FieldType.checkbox,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 9. Radio Field
```dart
FormFieldConfig(
  name: 'gender',
  label: 'Gender',
  type: FieldType.radio,
  options: ['Male', 'Female', 'Other'],
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 10. Date Field
```dart
FormFieldConfig(
  name: 'birthDate',
  label: 'Date of Birth',
  type: FieldType.date,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 11. Time Field
```dart
FormFieldConfig(
  name: 'meetingTime',
  label: 'Meeting Time',
  type: FieldType.time,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 12. File Field
```dart
FormFieldConfig(
  name: 'document',
  label: 'Upload Document',
  type: FieldType.file,
  validations: [
    ValidationRule(type: ValidationType.required),
  ],
)
```

### 13. Switch Field
```dart
FormFieldConfig(
  name: 'notifications',
  label: 'Enable Notifications',
  type: FieldType.switch_,
  defaultValue: 'true',
)
```

## Các loại Validation

### Required Validation
```dart
ValidationRule(type: ValidationType.required)
```

### Email Validation
```dart
ValidationRule(type: ValidationType.email)
```

### Min Length Validation
```dart
ValidationRule(type: ValidationType.minLength, value: 8)
```

### Max Length Validation
```dart
ValidationRule(type: ValidationType.maxLength, value: 100)
```

### Pattern Validation
```dart
ValidationRule(
  type: ValidationType.pattern,
  value: r'^[A-Za-z0-9]+$',
  message: 'Only alphanumeric characters allowed'
)
```

### Custom Validation
```dart
ValidationRule(type: ValidationType.custom)
```

## Cấu hình Form

### FormConfig cơ bản
```dart
FormConfig(
  title: 'User Registration',
  description: 'Please fill in your information',
  fields: [
    // List of FormFieldConfig
  ],
  actions: [
    // List of FormAction
  ],
)
```

### FormConfig với Card
```dart
FormConfig(
  title: 'Settings',
  description: 'Update your preferences',
  fields: [...],
  actions: [...],
  showCard: true,
  cardType: CardType.elevated,
  cardSize: CardSize.large,
)
```

## Form Actions

### Submit Action
```dart
FormAction(
  text: 'Submit',
  type: ButtonType.primary,
  icon: Icons.send,
  isSubmit: true,
)
```

### Cancel Action
```dart
FormAction(
  text: 'Cancel',
  type: ButtonType.secondary,
  onPressed: () => Navigator.pop(context),
)
```

### Custom Action
```dart
FormAction(
  text: 'Save Draft',
  type: ButtonType.outline,
  icon: Icons.save,
  onPressed: () => saveDraft(),
)
```

## Sử dụng DynamicForm

### Form cơ bản
```dart
DynamicForm(
  config: FormConfig(
    title: 'Simple Form',
    fields: [
      FormFieldConfig(
        name: 'name',
        label: 'Name',
        type: FieldType.text,
        validations: [ValidationRule(type: ValidationType.required)],
      ),
    ],
    actions: [
      FormAction(
        text: 'Submit',
        type: ButtonType.primary,
        isSubmit: true,
      ),
    ],
  ),
  onSubmit: (data) => print('Form data: $data'),
  onChanged: (data) => print('Form changed: $data'),
)
```

### Form với giá trị ban đầu
```dart
DynamicForm(
  config: formConfig,
  initialValues: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': '25',
  },
  onSubmit: handleSubmit,
)
```

## Ví dụ Form hoàn chỉnh

### Registration Form
```dart
FormConfig(
  title: 'User Registration',
  description: 'Create your account',
  fields: [
    FormFieldConfig(
      name: 'firstName',
      label: 'First Name',
      type: FieldType.text,
      validations: [
        ValidationRule(type: ValidationType.required),
        ValidationRule(type: ValidationType.minLength, value: 2),
      ],
    ),
    FormFieldConfig(
      name: 'lastName',
      label: 'Last Name',
      type: FieldType.text,
      validations: [ValidationRule(type: ValidationType.required)],
    ),
    FormFieldConfig(
      name: 'email',
      label: 'Email',
      type: FieldType.email,
      validations: [
        ValidationRule(type: ValidationType.required),
        ValidationRule(type: ValidationType.email),
      ],
    ),
    FormFieldConfig(
      name: 'password',
      label: 'Password',
      type: FieldType.password,
      validations: [
        ValidationRule(type: ValidationType.required),
        ValidationRule(type: ValidationType.minLength, value: 8),
      ],
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
      label: 'I agree to terms',
      type: FieldType.checkbox,
      validations: [ValidationRule(type: ValidationType.required)],
    ),
  ],
  actions: [
    FormAction(
      text: 'Cancel',
      type: ButtonType.secondary,
    ),
    FormAction(
      text: 'Register',
      type: ButtonType.primary,
      icon: Icons.person_add,
      isSubmit: true,
    ),
  ],
)
```

### Contact Form
```dart
FormConfig(
  title: 'Contact Us',
  description: 'Send us a message',
  fields: [
    FormFieldConfig(
      name: 'name',
      label: 'Your Name',
      type: FieldType.text,
      validations: [ValidationRule(type: ValidationType.required)],
    ),
    FormFieldConfig(
      name: 'email',
      label: 'Email',
      type: FieldType.email,
      validations: [
        ValidationRule(type: ValidationType.required),
        ValidationRule(type: ValidationType.email),
      ],
    ),
    FormFieldConfig(
      name: 'subject',
      label: 'Subject',
      type: FieldType.dropdown,
      options: ['General', 'Support', 'Feedback'],
      validations: [ValidationRule(type: ValidationType.required)],
    ),
    FormFieldConfig(
      name: 'message',
      label: 'Message',
      type: FieldType.multiline,
      validations: [
        ValidationRule(type: ValidationType.required),
        ValidationRule(type: ValidationType.minLength, value: 10),
      ],
    ),
  ],
  actions: [
    FormAction(
      text: 'Send',
      type: ButtonType.primary,
      icon: Icons.send,
      isSubmit: true,
    ),
  ],
)
```

## Tích hợp với Button và Card System

Form system được thiết kế để hoạt động hoàn hảo với button và card system:

```dart
DynamicForm(
  config: FormConfig(
    title: 'Form in Card',
    fields: [...],
    actions: [
      FormAction(
        text: 'Submit',
        type: ButtonType.primary,
        isSubmit: true,
      ),
    ],
    showCard: true,
    cardType: CardType.elevated,
    cardSize: CardSize.large,
  ),
  onSubmit: handleSubmit,
)
```

## Các thuộc tính có sẵn

### FormFieldConfig
- `name`: Tên field (String)
- `label`: Label hiển thị (String)
- `placeholder`: Placeholder text (String?)
- `type`: Loại field (FieldType)
- `defaultValue`: Giá trị mặc định (String?)
- `options`: Danh sách options cho dropdown/radio (List<String>?)
- `validations`: Danh sách validation rules (List<ValidationRule>?)
- `enabled`: Có thể edit không (bool)
- `visible`: Có hiển thị không (bool)
- `extraData`: Dữ liệu bổ sung (Map<String, dynamic>?)

### FormConfig
- `title`: Tiêu đề form (String)
- `description`: Mô tả form (String?)
- `fields`: Danh sách fields (List<FormFieldConfig>)
- `actions`: Danh sách actions (List<FormAction>)
- `showCard`: Hiển thị trong card không (bool)
- `cardType`: Loại card (CardType)
- `cardSize`: Kích thước card (CardSize)

### FormAction
- `text`: Text hiển thị (String)
- `type`: Loại button (ButtonType)
- `size`: Kích thước button (ButtonSize)
- `icon`: Icon (IconData?)
- `onPressed`: Callback khi nhấn (VoidCallback?)
- `isSubmit`: Có phải submit button không (bool) 