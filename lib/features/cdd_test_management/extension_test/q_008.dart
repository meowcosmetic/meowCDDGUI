import 'package:flutter/material.dart';

class ExtensionTestQ008 extends StatefulWidget {
  const ExtensionTestQ008({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ008> createState() => _ExtensionTestQ008State();
}

class _ExtensionTestQ008State extends State<ExtensionTestQ008> {
  String? selectedAnswer;
  
  final String question = "Con bạn có khó khăn trong việc chia sẻ đồ chơi với bạn bè không?";
  
  final List<String> options = [
    "A. Có, con rất khó chia sẻ",
    "B. Con cần được nhắc nhở để chia sẻ",
    "C. Con chia sẻ một cách tự nhiên",
    "D. Con rất hào phóng với bạn bè"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 8'),
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
              'Q_008: $question',
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
