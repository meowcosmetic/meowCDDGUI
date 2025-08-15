import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DonationView extends StatefulWidget {
  const DonationView({super.key});

  @override
  State<DonationView> createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  String selectedAmount = '100000';
  String customAmount = '';
  String selectedPaymentMethod = 'momo';
  bool isProcessing = false;

  final List<DonationTier> donationTiers = [
    DonationTier(
      amount: 50000,
      title: 'Hỗ trợ nhỏ',
      description: 'Góp phần phát triển tính năng mới',
      icon: Icons.favorite_border,
      color: Colors.pink,
    ),
    DonationTier(
      amount: 100000,
      title: 'Hỗ trợ vừa',
      description: 'Giúp cải thiện chất lượng ứng dụng',
      icon: Icons.favorite,
      color: Colors.red,
    ),
    DonationTier(
      amount: 200000,
      title: 'Hỗ trợ lớn',
      description: 'Đóng góp cho nghiên cứu và phát triển',
      icon: Icons.favorite,
      color: Colors.deepPurple,
    ),
    DonationTier(
      amount: 500000,
      title: 'Nhà tài trợ',
      description: 'Hỗ trợ toàn diện cho dự án',
      icon: Icons.diamond,
      color: Colors.amber,
    ),
  ];

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'momo',
      name: 'MoMo',
      icon: Icons.account_balance_wallet,
      color: Colors.pink,
    ),
    PaymentMethod(
      id: 'vnpay',
      name: 'VNPay',
      icon: Icons.payment,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'bank',
      name: 'Chuyển khoản ngân hàng',
      icon: Icons.account_balance,
      color: Colors.green,
    ),
    PaymentMethod(
      id: 'paypal',
      name: 'PayPal',
      icon: Icons.payment,
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Đóng Góp'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hỗ Trợ Dự Án',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đóng góp của bạn sẽ giúp chúng tôi phát triển ứng dụng tốt hơn và hỗ trợ nhiều gia đình hơn',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Project Impact Section
            _buildInfoSection(
              title: 'Tác Động Của Dự Án',
              children: [
                _buildImpactItem(
                  'Hỗ trợ 1000+ gia đình',
                  'Cung cấp công cụ và tài liệu cho phụ huynh',
                  Icons.family_restroom,
                  Colors.blue,
                ),
                _buildImpactItem(
                  'Phát triển 50+ bài test',
                  'Đánh giá toàn diện sự phát triển của trẻ',
                  Icons.psychology,
                  Colors.green,
                ),
                _buildImpactItem(
                  'Tư vấn 24/7',
                  'Đội ngũ chuyên gia hỗ trợ liên tục',
                  Icons.support_agent,
                  Colors.orange,
                ),
                _buildImpactItem(
                  'Nghiên cứu cải tiến',
                  'Phát triển phương pháp can thiệp mới',
                  Icons.science,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Donation Amount Section
            _buildInfoSection(
              title: 'Chọn Mức Đóng Góp',
              children: [
                ...donationTiers.map((tier) => _buildDonationTier(tier)),
                const SizedBox(height: 16),
                // Custom Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số tiền khác:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            customAmount = value;
                            selectedAmount = 'custom';
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Nhập số tiền (VNĐ)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.grey50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Payment Method Section
            _buildInfoSection(
              title: 'Phương Thức Thanh Toán',
              children: [
                ...paymentMethods.map((method) => _buildPaymentMethod(method)),
              ],
            ),

            const SizedBox(height: 24),

            // Donation Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : _processDonation,
                icon: isProcessing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Icon(Icons.volunteer_activism, size: 24),
                label: Text(
                  isProcessing ? 'Đang xử lý...' : 'Đóng Góp Ngay',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Thông tin bổ sung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Mọi đóng góp đều được sử dụng để phát triển ứng dụng\n'
                    '• Bạn sẽ nhận được báo cáo sử dụng quỹ hàng tháng\n'
                    '• Có thể yêu cầu hóa đơn đóng góp từ thiện\n'
                    '• Thông tin cá nhân được bảo mật tuyệt đối',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImpactItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTier(DonationTier tier) {
    final isSelected = selectedAmount == tier.amount.toString();
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = tier.amount.toString();
          customAmount = '';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? tier.color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? tier.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tier.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tier.icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    tier.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${_formatPrice(tier.amount)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tier.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(PaymentMethod method) {
    final isSelected = selectedPaymentMethod == method.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: method.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method.icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: method.color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _processDonation() {
    final amount = selectedAmount == 'custom' 
        ? (int.tryParse(customAmount) ?? 0)
        : int.parse(selectedAmount);
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập số tiền hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isProcessing = false;
      });
      
      _showDonationSuccess(amount);
    });
  }

  void _showDonationSuccess(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Đóng góp thành công'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cảm ơn bạn đã đóng góp ${_formatPrice(amount)} cho dự án!'),
            const SizedBox(height: 16),
            const Text(
              'Chúng tôi sẽ sử dụng số tiền này để:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Phát triển tính năng mới'),
            const Text('• Cải thiện chất lượng ứng dụng'),
            const Text('• Hỗ trợ nghiên cứu'),
            const Text('• Tư vấn cho gia đình'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Share donation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Chia sẻ'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toString();
  }
}

class DonationTier {
  final int amount;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DonationTier({
    required this.amount,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
