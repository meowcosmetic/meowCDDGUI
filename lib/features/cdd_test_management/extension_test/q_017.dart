import 'package:flutter/material.dart';

class ExtensionTestQ017 extends StatefulWidget {
  const ExtensionTestQ017({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ017> createState() => _ExtensionTestQ017State();
}

class _ExtensionTestQ017State extends State<ExtensionTestQ017> {
  String? selectedAnswer;

  final String question =
      "Con bạn có thường xuyên có những phản ứng quá mức với âm thanh hoặc ánh sáng không?";

  final List<String> options = [
    "A. Có, con rất nhạy cảm với âm thanh và ánh sáng",
    "B. Thỉnh thoảng con có phản ứng quá mức",
    "C. Con hiếm khi có phản ứng quá mức",
    "D. Con không bao giờ có phản ứng quá mức",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 17'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test ID: 10 - Extension Test',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Q_017: $question',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...options
                .map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedAnswer,
                    onChanged: (String? value) {
                      setState(() {
                        selectedAnswer = value;
                      });
                    },
                  ),
                )
                .toList(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: selectedAnswer != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã chọn: $selectedAnswer')),
                        );

                        // Quay lại test chính
                        if (widget.onReturnToMainTest != null) {
                          widget.onReturnToMainTest!();
                        }
                      }
                    : null,
                child: const Text('Xác nhận và tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
