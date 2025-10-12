import 'package:flutter/material.dart';

class ExtensionTestQ009 extends StatefulWidget {
  const ExtensionTestQ009({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ009> createState() => _ExtensionTestQ009State();
}

class _ExtensionTestQ009State extends State<ExtensionTestQ009> {
  String? selectedAnswer;
  
  final String question = "Con bạn có thường xuyên có những cơn giận dữ không kiểm soát được không?";
  
  final List<String> options = [
    "A. Có, con thường xuyên có cơn giận dữ",
    "B. Thỉnh thoảng con có cơn giận dữ",
    "C. Con hiếm khi có cơn giận dữ",
    "D. Con rất bình tĩnh và kiểm soát tốt"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 9'),
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
              'Q_009: $question',
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
