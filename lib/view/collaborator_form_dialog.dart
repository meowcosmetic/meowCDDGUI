import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/collaborator_models.dart';

class CollaboratorFormDialog extends StatefulWidget {
  final CollaboratorDetail? collaborator;
  final Function(CreateCollaboratorRequest) onCreate;
  final Function(String, UpdateCollaboratorRequest) onUpdate;

  const CollaboratorFormDialog({
    super.key,
    this.collaborator,
    required this.onCreate,
    required this.onUpdate,
  });

  @override
  State<CollaboratorFormDialog> createState() => _CollaboratorFormDialogState();
}

class _CollaboratorFormDialogState extends State<CollaboratorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _specializationController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _organizationController = TextEditingController();
  final _certificationViController = TextEditingController();
  final _certificationEnController = TextEditingController();
  final _availabilityViController = TextEditingController();
  final _availabilityEnController = TextEditingController();
  final _notesViController = TextEditingController();
  final _notesEnController = TextEditingController();
  final _userIdController = TextEditingController();
  final _roleIdController = TextEditingController();

  CollaboratorStatus _selectedStatus = CollaboratorStatus.PENDING;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.collaborator != null) {
      _loadCollaboratorData();
    }
  }

  void _loadCollaboratorData() {
    final collaborator = widget.collaborator!;
    _specializationController.text = collaborator.specialization;
    _experienceYearsController.text = collaborator.experienceYears.toString();
    _organizationController.text = collaborator.organization;
    _certificationViController.text = collaborator.certification.vi;
    _certificationEnController.text = collaborator.certification.en;
    _availabilityViController.text = collaborator.availability.vi;
    _availabilityEnController.text = collaborator.availability.en;
    _notesViController.text = collaborator.notes.vi;
    _notesEnController.text = collaborator.notes.en;
    _userIdController.text = collaborator.userId;
    _roleIdController.text = collaborator.roleId;
    _selectedStatus = collaborator.status;
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _experienceYearsController.dispose();
    _organizationController.dispose();
    _certificationViController.dispose();
    _certificationEnController.dispose();
    _availabilityViController.dispose();
    _availabilityEnController.dispose();
    _notesViController.dispose();
    _notesEnController.dispose();
    _userIdController.dispose();
    _roleIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.collaborator == null ? 'Thêm Cộng Tác Viên' : 'Sửa Cộng Tác Viên',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User ID và Role ID
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _userIdController,
                              decoration: const InputDecoration(
                                labelText: 'User ID *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập User ID';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _roleIdController,
                              decoration: const InputDecoration(
                                labelText: 'Role ID *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập Role ID';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Specialization
                      TextFormField(
                        controller: _specializationController,
                        decoration: const InputDecoration(
                          labelText: 'Chuyên môn *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập chuyên môn';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Experience Years
                      TextFormField(
                        controller: _experienceYearsController,
                        decoration: const InputDecoration(
                          labelText: 'Số năm kinh nghiệm *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số năm kinh nghiệm';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Vui lòng nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Organization
                      TextFormField(
                        controller: _organizationController,
                        decoration: const InputDecoration(
                          labelText: 'Tổ chức *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên tổ chức';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<CollaboratorStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái *',
                          border: OutlineInputBorder(),
                        ),
                        items: CollaboratorStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Certification
                      const Text(
                        'Chứng chỉ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _certificationViController,
                        decoration: const InputDecoration(
                          labelText: 'Chứng chỉ (Tiếng Việt)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _certificationEnController,
                        decoration: const InputDecoration(
                          labelText: 'Chứng chỉ (English)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Availability
                      const Text(
                        'Thời gian khả dụng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _availabilityViController,
                        decoration: const InputDecoration(
                          labelText: 'Thời gian khả dụng (Tiếng Việt)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _availabilityEnController,
                        decoration: const InputDecoration(
                          labelText: 'Thời gian khả dụng (English)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      const Text(
                        'Ghi chú',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesViController,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú (Tiếng Việt)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesEnController,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú (English)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.collaborator == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(CollaboratorStatus status) {
    switch (status) {
      case CollaboratorStatus.ACTIVE:
        return 'Hoạt động';
      case CollaboratorStatus.INACTIVE:
        return 'Không hoạt động';
      case CollaboratorStatus.PENDING:
        return 'Chờ duyệt';
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final certification = Certification(
        vi: _certificationViController.text,
        en: _certificationEnController.text,
      );

      final availability = Availability(
        vi: _availabilityViController.text,
        en: _availabilityEnController.text,
      );

      final notes = Notes(
        vi: _notesViController.text,
        en: _notesEnController.text,
      );

      if (widget.collaborator == null) {
        // Tạo mới
        final request = CreateCollaboratorRequest(
          userId: _userIdController.text,
          roleId: _roleIdController.text,
          specialization: _specializationController.text,
          experienceYears: int.parse(_experienceYearsController.text),
          certification: certification,
          organization: _organizationController.text,
          availability: availability,
          status: _selectedStatus,
          notes: notes,
        );
        await widget.onCreate(request);
      } else {
        // Cập nhật
        final request = UpdateCollaboratorRequest(
          specialization: _specializationController.text,
          experienceYears: int.parse(_experienceYearsController.text),
          certification: certification,
          organization: _organizationController.text,
          availability: availability,
          status: _selectedStatus,
          notes: notes,
        );
        await widget.onUpdate(widget.collaborator!.collaboratorId, request);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.collaborator == null
                  ? 'Thêm cộng tác viên thành công'
                  : 'Cập nhật cộng tác viên thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

