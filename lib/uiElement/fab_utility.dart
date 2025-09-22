import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../view/multi_chat_view.dart';

class FABUtility {
  static Widget buildSmartFAB(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Sử dụng FAB mở rộng cho màn hình lớn, FAB nhỏ cho mobile
    if (screenWidth > 600) {
      return Stack(
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MultiChatView()),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.chat_bubble, size: 24),
            label: const Text(
              'Nhắn tin với hệ thống',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            tooltip: 'Nhắn tin với hệ thống',
          ),
          // Badge notification
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MultiChatView()),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            child: const Icon(Icons.chat_bubble, size: 28),
            tooltip: 'Nhắn tin với hệ thống',
          ),
          // Badge notification
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
  }
}
