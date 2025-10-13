import 'package:flutter/material.dart';

class ExtensionTestQ012 extends StatefulWidget {
  const ExtensionTestQ012({Key? key}) : super(key: key);

  @override
  State<ExtensionTestQ012> createState() => _ExtensionTestQ012State();
}

class _ExtensionTestQ012State extends State<ExtensionTestQ012> {
  String? selectedAnswer;

  final String question =
      "Con bạn có khó khăn trong việc chờ đợi đến lượt mình không?";

  final List<String> options = [
    "A. Có, con rất khó chờ đợi",
    "B. Con cần được nhắc nhở để chờ đợi",
    "C. Con chờ đợi một cách tự nhiên",
    "D. Con rất kiên nhẫn và biết chờ đợi",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension Test - Câu hỏi 12'),
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
              'Q_012: $question',
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
