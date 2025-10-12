import 'package:flutter/material.dart';

class ExtensionTestQ015 extends StatefulWidget {
  const ExtensionTestQ015({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ015> createState() => _ExtensionTestQ015State();
}

class _ExtensionTestQ015State extends State<ExtensionTestQ015> {
  String? selectedAnswer;
  
  final String question = "Con bạn có thường xuyên có những hành vi lặp đi lặp lại không?";
  
  final List<String> options = [
    "A. Có, con thường xuyên có hành vi lặp lại",
    "B. Thỉnh thoảng con có hành vi lặp lại",
    "C. Con hiếm khi có hành vi lặp lại",
    "D. Con không bao giờ có hành vi lặp lại"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 15'),
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
              'Q_015: $question',
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
