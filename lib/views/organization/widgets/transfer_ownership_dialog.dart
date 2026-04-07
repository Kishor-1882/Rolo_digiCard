import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/custom_textfield.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/organization/organization_settings_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';

class TransferOwnershipDialog extends StatefulWidget {
  const TransferOwnershipDialog({super.key});

  @override
  State<TransferOwnershipDialog> createState() => _TransferOwnershipDialogState();
}

class _TransferOwnershipDialogState extends State<TransferOwnershipDialog> {
  final _controller = Get.find<OrganizationSettingsController>();

  bool isSelectMember = true;
  String? selectedUserId;
  
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.fetchOrganizationMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (isSelectMember) {
      if (selectedUserId == null) {
        CommonSnackbar.error('Please select a member to transfer ownership');
        return;
      }
      _controller.transferOwnership(
        toUserId: selectedUserId,
        note: _noteController.text.trim(),
      );
    } else {
      if (_emailController.text.trim().isEmpty || !GetUtils.isEmail(_emailController.text.trim())) {
        CommonSnackbar.error('Please enter a valid email address');
        return;
      }
      _controller.transferOwnership(
        toEmail: _emailController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transfer Ownership',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Select a member or enter email',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isSelectMember = true),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelectMember ? Colors.white12 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Select Member',
                          style: TextStyle(
                            color: isSelectMember ? Colors.white : Colors.white54,
                            fontWeight: isSelectMember ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isSelectMember = false),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !isSelectMember ? Colors.white12 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Enter Email',
                          style: TextStyle(
                            color: !isSelectMember ? Colors.white : Colors.white54,
                            fontWeight: !isSelectMember ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            isSelectMember ? _buildSelectMemberView() : _buildEnterEmailView(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Initiate Transfer',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectMemberView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose New Owner', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 180,
          child: Obx(() {
            if (_controller.orgMembers.isEmpty) {
              return const Center(child: Text("No members available", style: TextStyle(color: Colors.white54)));
            }
            return ListView.builder(
              itemCount: _controller.orgMembers.length,
              itemBuilder: (context, index) {
                final user = _controller.orgMembers[index];
                final isSelected = selectedUserId == user['_id'] || selectedUserId == user['id'];
                
                String firstName = user['firstName'] ?? 'Unknown';
                String lastName = user['lastName'] ?? '';
                String initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedUserId = user['_id'] ?? user['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? Colors.deepPurpleAccent : Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$firstName $lastName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(user['email'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        _buildNoteField(),
      ],
    );
  }

  Widget _buildEnterEmailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormTextField(
          title: 'New Owner Email',
          hintText: 'Enter email address...',
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        _buildNoteField(),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Note (Optional)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Reason for transfer...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}
