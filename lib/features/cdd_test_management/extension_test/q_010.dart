import 'package:flutter/material.dart';

class ExtensionTestQ010 extends StatefulWidget {
  const ExtensionTestQ010({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ010> createState() => _ExtensionTestQ010State();
}

class _ExtensionTestQ010State extends State<ExtensionTestQ010> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc hiểu các quy tắc xã hội không?";
  
  final List<String> options = [
    "A. Có, con không hiểu các quy tắc xã hội",
    "B. Con hiểu một số quy tắc cơ bản",
    "C. Con hiểu tốt các quy tắc xã hội",
    "D. Con rất giỏi trong việc tuân thủ quy tắc"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 10'),
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
              'Q_010: $question',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedAnswer,
              onChanged: (String? value) {
                setState(() {
                  selectedAnswer = value;
                });
              },
            )).toList(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã chọn: $selectedAnswer')),
                  );
                  
                  // Quay lại test chính
                  if (widget.onReturnToMainTest != null) {
                    widget.onReturnToMainTest!();
                  }
                } : null,
                child: const Text('Xác nhận và tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
