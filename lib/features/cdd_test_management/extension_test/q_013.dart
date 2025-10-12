import 'package:flutter/material.dart';

class ExtensionTestQ013 extends StatefulWidget {
  const ExtensionTestQ013({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ013> createState() => _ExtensionTestQ013State();
}

class _ExtensionTestQ013State extends State<ExtensionTestQ013> {
  String? selectedAnswer;
  
  final String question = "Con bạn có thường xuyên có những sở thích rất cụ thể và hạn chế không?";
  
  final List<String> options = [
    "A. Có, con chỉ quan tâm đến một vài thứ",
    "B. Con có một số sở thích cụ thể",
    "C. Con có nhiều sở thích đa dạng",
    "D. Con rất cởi mở với nhiều hoạt động"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 13'),
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
              'Q_013: $question',
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
