import 'package:flutter/material.dart';

class ExtensionTestQ018 extends StatefulWidget {
  const ExtensionTestQ018({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ018> createState() => _ExtensionTestQ018State();
}

class _ExtensionTestQ018State extends State<ExtensionTestQ018> {
  String? selectedAnswer;

  final String question =
      "Con bạn có khó khăn trong việc hiểu các trò chơi tưởng tượng không?";

  final List<String> options = [
    "A. Có, con không hiểu trò chơi tưởng tượng",
    "B. Con hiểu một số trò chơi tưởng tượng đơn giản",
    "C. Con hiểu tốt trò chơi tưởng tượng",
    "D. Con rất sáng tạo trong trò chơi tưởng tượng",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 18'),
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
              'Q_018: $question',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...options
                .map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedAnswer,
                    onChanged: (String? value) {
                      setState(() {
                        selectedAnswer = value;
                      });
                    },
                  ),
                )
                .toList(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: selectedAnswer != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã chọn: $selectedAnswer')),
                        );

                        // Quay lại test chính
                        if (widget.onReturnToMainTest != null) {
                          widget.onReturnToMainTest!();
                        }
                      }
                    : null,
                child: const Text('Xác nhận và tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
