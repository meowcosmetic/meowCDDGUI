import 'package:flutter/material.dart';

class ExtensionTestQ005 extends StatefulWidget {
  const ExtensionTestQ005({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ005> createState() => _ExtensionTestQ005State();
}

class _ExtensionTestQ005State extends State<ExtensionTestQ005> {
  String? selectedAnswer;
  
  final String question = "Con bạn có thường lặp lại các hành động hoặc từ ngữ không?";
  
  final List<String> options = [
    "A. Có, con lặp lại rất nhiều",
    "B. Thỉnh thoảng có lặp lại",
    "C. Hiếm khi lặp lại",
    "D. Con không bao giờ lặp lại"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 5'),
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
              'Q_005: $question',
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
