import 'package:flutter/material.dart';

class ExtensionTestQ014 extends StatefulWidget {
  const ExtensionTestQ014({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ014> createState() => _ExtensionTestQ014State();
}

class _ExtensionTestQ014State extends State<ExtensionTestQ014> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc hiểu các cử chỉ và ngôn ngữ cơ thể không?";
  
  final List<String> options = [
    "A. Có, con không hiểu cử chỉ và ngôn ngữ cơ thể",
    "B. Con hiểu một số cử chỉ cơ bản",
    "C. Con hiểu tốt cử chỉ và ngôn ngữ cơ thể",
    "D. Con rất nhạy cảm với ngôn ngữ cơ thể"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 14'),
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
              'Q_014: $question',
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
