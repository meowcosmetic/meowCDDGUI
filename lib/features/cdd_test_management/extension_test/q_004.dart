import 'package:flutter/material.dart';

class ExtensionTestQ004 extends StatefulWidget {
  const ExtensionTestQ004({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ004> createState() => _ExtensionTestQ004State();
}

class _ExtensionTestQ004State extends State<ExtensionTestQ004> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc hiểu cảm xúc của người khác không?";
  
  final List<String> options = [
    "A. Có, con không hiểu cảm xúc của người khác",
    "B. Con hiểu một số cảm xúc cơ bản",
    "C. Con hiểu tốt cảm xúc của mọi người",
    "D. Con rất nhạy cảm với cảm xúc"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 4'),
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
              'Q_004: $question',
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
