import 'package:flutter/material.dart';

class ExtensionTestQ016 extends StatefulWidget {
  const ExtensionTestQ016({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ016> createState() => _ExtensionTestQ016State();
}

class _ExtensionTestQ016State extends State<ExtensionTestQ016> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc tham gia các hoạt động nhóm không?";
  
  final List<String> options = [
    "A. Có, con rất khó tham gia hoạt động nhóm",
    "B. Con cần được khuyến khích để tham gia",
    "C. Con tham gia hoạt động nhóm một cách tự nhiên",
    "D. Con rất tích cực trong các hoạt động nhóm"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 16'),
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
              'Q_016: $question',
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
