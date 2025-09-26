import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class LanguageDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final String? label;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  static const Map<String, String> languageOptions = {
    'Vietnamese': 'Tiếng Việt',
    'English': 'Tiếng Anh',
    'Chinese': 'Tiếng Trung',
    'Korean': 'Tiếng Hàn',
    'Japanese': 'Tiếng Nhật',
    'French': 'Tiếng Pháp',
    'German': 'Tiếng Đức',
    'Spanish': 'Tiếng Tây Ban Nha',
    'Russian': 'Tiếng Nga',
    'Arabic': 'Tiếng Ả Rập',
    'Thai': 'Tiếng Thái',
    'Lao': 'Tiếng Lào',
    'Khmer': 'Tiếng Khmer',
    'Indonesian': 'Tiếng Indonesia',
    'Malay': 'Tiếng Malaysia',
    'Filipino': 'Tiếng Philippines',
    'Hindi': 'Tiếng Hindi',
    'Bengali': 'Tiếng Bengali',
    'Urdu': 'Tiếng Urdu',
    'Turkish': 'Tiếng Thổ Nhĩ Kỳ',
    'Italian': 'Tiếng Ý',
    'Portuguese': 'Tiếng Bồ Đào Nha',
    'Dutch': 'Tiếng Hà Lan',
    'Swedish': 'Tiếng Thụy Điển',
    'Norwegian': 'Tiếng Na Uy',
    'Danish': 'Tiếng Đan Mạch',
    'Finnish': 'Tiếng Phần Lan',
    'Polish': 'Tiếng Ba Lan',
    'Czech': 'Tiếng Séc',
    'Hungarian': 'Tiếng Hungary',
    'Romanian': 'Tiếng Romania',
    'Bulgarian': 'Tiếng Bulgaria',
    'Greek': 'Tiếng Hy Lạp',
    'Hebrew': 'Tiếng Hebrew',
    'Persian': 'Tiếng Ba Tư',
    'OTHER': 'Khác',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? 'Ngôn ngữ chính',
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
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              items: languageOptions.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
