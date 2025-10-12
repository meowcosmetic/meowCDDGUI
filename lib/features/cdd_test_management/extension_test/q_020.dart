import 'package:flutter/material.dart';

class ExtensionTestQ020 extends StatefulWidget {
  const ExtensionTestQ020({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ020> createState() => _ExtensionTestQ020State();
}

class _ExtensionTestQ020State extends State<ExtensionTestQ020> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc hiểu và tuân theo các hướng dẫn đơn giản không?";
  
  final List<String> options = [
    "A. Có, con rất khó hiểu và tuân theo hướng dẫn",
    "B. Con cần được nhắc nhở nhiều lần",
    "C. Con hiểu và tuân theo hướng dẫn tốt",
    "D. Con rất giỏi trong việc tuân theo hướng dẫn"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 20'),
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
              'Q_020: $question',
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
