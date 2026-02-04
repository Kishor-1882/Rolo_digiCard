import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/user_management_controller.dart'; 
import 'package:rolo_digi_card/views/organization/org_theme.dart';

class InviteUserDialog extends StatelessWidget {
  InviteUserDialog({Key? key}) : super(key: key);

  final UserManagementController userController = Get.find<UserManagementController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: OrgTheme.cardBackgroundColor, // Using card bg as modal bg
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Invite User", style: OrgTheme.headerStyle),
                IconButton(
                  icon: const Icon(Icons.close, color: OrgTheme.textSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: OrgTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                const Text("Basic Information", style: TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Email", style: TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(hint: "user@example.com", controller: userController.inviteEmailController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("First Name", style: TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       _buildTextField(hint: "John", controller: userController.inviteFirstNameController),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("Last Name", style: TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       _buildTextField(hint: "Doe", controller: userController.inviteLastNameController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Role Selection", style: TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildRoleCard("User", "Limited access", true)),
                const SizedBox(width: 12),
                Expanded(child: _buildRoleCard("Administrator", "Full access", false)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                    // Logic to invite
                    // userController.inviteUser(['default_perms']);
                    Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrgTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Send Invite", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: OrgTheme.textSecondary),
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Slightly different input bg
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildRoleCard(String title, String subtitle, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF321E38) : const Color(0xFF2C2C2C), // Darker purple bg if selected
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? OrgTheme.primaryColor : Colors.white10,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               if(isSelected) const Icon(Icons.check, color: OrgTheme.primaryColor, size: 16),
             ],
           ),
           const SizedBox(height: 4),
           Text(subtitle, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
