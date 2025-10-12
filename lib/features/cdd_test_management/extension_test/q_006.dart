import 'package:flutter/material.dart';

class ExtensionTestQ006 extends StatefulWidget {
  const ExtensionTestQ006({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ006> createState() => _ExtensionTestQ006State();
}

class _ExtensionTestQ006State extends State<ExtensionTestQ006> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc thay đổi thói quen hàng ngày không?";
  
  final List<String> options = [
    "A. Có, con rất khó thay đổi thói quen",
    "B. Con cần thời gian để thích nghi",
    "C. Con thích nghi tốt với thay đổi",
    "D. Con rất linh hoạt với thay đổi"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 6'),
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
              'Q_006: $question',
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
                } : null,
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
