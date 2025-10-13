import 'package:flutter/material.dart';

class ExtensionTestQ019 extends StatefulWidget {
  const ExtensionTestQ019({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ019> createState() => _ExtensionTestQ019State();
}

class _ExtensionTestQ019State extends State<ExtensionTestQ019> {
  String? selectedAnswer;

  final String question =
      "Con bạn có thường xuyên có những hành vi tự làm tổn thương không?";

  final List<String> options = [
    "A. Có, con thường xuyên có hành vi tự làm tổn thương",
    "B. Thỉnh thoảng con có hành vi này",
    "C. Con hiếm khi có hành vi này",
    "D. Con không bao giờ có hành vi này",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 19'),
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
              'Q_019: $question',
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
