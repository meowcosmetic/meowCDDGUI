import 'package:flutter/material.dart';

class ExtensionTestQ002 extends StatefulWidget {
  const ExtensionTestQ002({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ002> createState() => _ExtensionTestQ002State();
}

class _ExtensionTestQ002State extends State<ExtensionTestQ002> {
  String? selectedAnswer;
  
  final String question = "Khi con bạn không phản ứng khi được gọi tên, bạn thường làm gì?";
  
  final List<String> options = [
    "A. Gọi to hơn và nhiều lần",
    "B. Đến gần và chạm vào con",
    "C. Kiểm tra xem con có nghe thấy không",
    "D. Bỏ qua và để con tự nhiên"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 2'),
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
              'Q_002: $question',
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
