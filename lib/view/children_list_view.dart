import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/child.dart';
import '../models/api_service.dart';
import '../models/user_session.dart';
import 'children/add_child_sheet.dart';

class ChildrenListView extends StatefulWidget {
  const ChildrenListView({super.key});

  @override
  State<ChildrenListView> createState() => _ChildrenListViewState();
}

class _ChildrenListViewState extends State<ChildrenListView> {
  List<ChildData> children = [];
  List<ChildData> filteredChildren = [];
  String searchQuery = '';
  String selectedStatus = 'all';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Đảm bảo UserSession đã được khởi tạo
      await UserSession.initFromPrefs();
      
      final parentId = UserSession.userId;
      print('DEBUG: Loading children for parentId = $parentId');
      
      if (parentId == null || parentId.isEmpty) {
        throw Exception('User ID not found. Please login first.');
      }

      final apiService = ApiService();
      final response = await apiService.getChildrenByParentId(parentId);
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> childrenData = jsonDecode(response.body);
        final List<ChildData> loadedChildren = childrenData.map((json) => ChildData.fromJson(json)).toList();
        
        setState(() {
          children = loadedChildren;
          filteredChildren = loadedChildren;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load children: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error loading children: $e');
      setState(() {
        children = [];
        filteredChildren = [];
        isLoading = false;
      });
      
      // Hiển thị lỗi cho user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách trẻ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _filterChildren() {
    setState(() {
      filteredChildren = children.where((child) {
        final matchesSearch = child.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            child.developmentalDisorderDiagnosis.toLowerCase().contains(searchQuery.toLowerCase());
        
        final matchesStatus = selectedStatus == 'all' || child.status == selectedStatus;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Danh Sách Trẻ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    searchQuery = value;
                    _filterChildren();
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, phụ huynh, chẩn đoán...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Status Filter
                Row(
                  children: [
                    Text(
                      'Trạng thái: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusChip('all', 'Tất cả'),
                            const SizedBox(width: 8),
                            _buildStatusChip('active', 'Đang điều trị'),
                            const SizedBox(width: 8),
                            _buildStatusChip('inactive', 'Tạm dừng'),
                            const SizedBox(width: 8),
                            _buildStatusChip('completed', 'Hoàn thành'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Statistics Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Tổng số', '${children.length}', Icons.people),
                ),
                Expanded(
                  child: _buildStatCard('Đang điều trị', 
                    '${children.where((c) => c.status == 'active').length}', 
                    Icons.medical_services),
                ),
                Expanded(
                  child: _buildStatCard('Hoàn thành', 
                    '${children.where((c) => c.status == 'completed').length}', 
                    Icons.check_circle),
                ),
              ],
            ),
          ),
          
          // Children List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredChildren.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredChildren.length,
                        itemBuilder: (context, index) {
                          final child = filteredChildren[index];
                          return _buildChildCard(child);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm Trẻ'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
          _filterChildren();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildData child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showChildDetails(child),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      child.fullName.split(' ').last[0],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_calculateAge(child.dateOfBirth)} tuổi - ${_getGenderText(child.gender)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Chẩn đoán: ${_getDiagnosisText(child.developmentalDisorderDiagnosis)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(_getStatusColor(child.status)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(_getStatusColor(child.status))),
                    ),
                    child: Text(
                      _getStatusText(child.status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(_getStatusColor(child.status)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Diagnosis
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getDiagnosisText(child.developmentalDisorderDiagnosis),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              Row(
                children: [
                  Text(
                    'Trạng thái: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(_getStatusColor(child.status)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(_getStatusColor(child.status))),
                      ),
                      child: Text(
                        _getStatusText(child.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(_getStatusColor(child.status)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showChildDetails(child),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Chi tiết'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditChildDialog(context, child),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy trẻ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc thêm trẻ mới',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddChildDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Thêm Trẻ Mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChildDetails(ChildData child) {
    // TODO: Cập nhật ChildDetailView để nhận ChildData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chi tiết trẻ: ${child.fullName}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddChildSheet(),
    ).then((formData) async {
      if (formData == null) return;
      
      // Reload danh sách trẻ từ API sau khi thêm thành công
      await _loadChildren();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm trẻ thành công: ${formData['fullName'] ?? 'Trẻ mới'}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _showEditChildDialog(BuildContext context, ChildData child) {
    // TODO: Implement edit child dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng sửa thông tin trẻ sẽ được phát triển'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  // Helper methods
  int _calculateAge(String dateOfBirth) {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  String _getGenderText(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Nam';
      case 'FEMALE':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  String _getDiagnosisText(String diagnosis) {
    switch (diagnosis.toUpperCase()) {
      case 'NOT_EVALUATED':
        return 'Chưa đánh giá';
      case 'AUTISM_SPECTRUM_DISORDER':
        return 'Rối loạn phổ tự kỷ';
      case 'ATTENTION_DEFICIT_HYPERACTIVITY_DISORDER':
        return 'Rối loạn tăng động giảm chú ý';
      case 'INTELLECTUAL_DISABILITY':
        return 'Khuyết tật trí tuệ';
      case 'DEVELOPMENTAL_DELAY':
        return 'Chậm phát triển';
      default:
        return diagnosis;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Đang điều trị';
      case 'INACTIVE':
        return 'Tạm dừng';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  int _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 0xFF4CAF50; // Xanh lá
      case 'INACTIVE':
        return 0xFFFF9800; // Cam
      case 'COMPLETED':
        return 0xFF2196F3; // Xanh dương
      default:
        return 0xFF9E9E9E; // Xám
    }
  }
}



