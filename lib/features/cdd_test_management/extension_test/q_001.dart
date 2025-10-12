import 'package:flutter/material.dart';

class ExtensionTestQ001 extends StatefulWidget {
  final bool? mainQuestionAnswer; // Kết quả từ câu hỏi chính
  final VoidCallback? onReturnToMainTest; // Callback để quay lại test chính
  
  const ExtensionTestQ001({
    Key? key,
    this.mainQuestionAnswer,
    this.onReturnToMainTest,
  }) : super(key: key);

  @override
  State<ExtensionTestQ001> createState() => _ExtensionTestQ001State();
}

class _ExtensionTestQ001State extends State<ExtensionTestQ001> {
  String? selectedAnswer;
  
  final String question = "Trong tình huống con bạn gặp khó khăn trong việc học tập, bạn sẽ làm gì đầu tiên?";
  
  final List<String> options = [
    "A. Tìm hiểu nguyên nhân cụ thể của khó khăn",
    "B. Yêu cầu con cố gắng hơn nữa",
    "C. Tìm kiếm sự giúp đỡ từ giáo viên",
    "D. So sánh con với các bạn khác"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 1'),
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
              'Q_001: $question',
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
                  // Xử lý kết quả
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
