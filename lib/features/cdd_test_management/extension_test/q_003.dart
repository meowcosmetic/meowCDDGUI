import 'package:flutter/material.dart';

class ExtensionTestQ003 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ003({
    Key? key,
    this.mainQuestionAnswer,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ003> createState() => _ExtensionTestQ003State();
}

class _ExtensionTestQ003State extends State<ExtensionTestQ003> {
  String? selectedAnswer;
  
  final String question = "Con bạn có thường xuyên chơi một mình và không tương tác với trẻ khác không?";
  
  final List<String> options = [
    "A. Có, con luôn chơi một mình",
    "B. Thỉnh thoảng chơi một mình",
    "C. Con thích chơi với bạn bè",
    "D. Con chơi cả một mình và với bạn"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 3'),
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
              'Q_003: $question',
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
