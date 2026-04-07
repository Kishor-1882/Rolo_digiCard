import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/custom_textfield.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/organization/organization_settings_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/change_password_dialog.dart';
import 'package:rolo_digi_card/views/organization/widgets/transfer_ownership_dialog.dart';

class OrganizationSettingsView extends StatefulWidget {
  const OrganizationSettingsView({super.key});

  @override
  State<OrganizationSettingsView> createState() => _OrganizationSettingsViewState();
}

class _OrganizationSettingsViewState extends State<OrganizationSettingsView> {
  late OrganizationSettingsController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<OrganizationSettingsController>()) {
      controller = Get.put(OrganizationSettingsController());
    } else {
      controller = Get.find<OrganizationSettingsController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            'Organization Settings',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppColors.primaryPink,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Security & Access'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.nameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          }
          return TabBarView(
            children: [
              _buildGeneralTab(),
              _buildSecurityTab(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile & Branding',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Organization Logo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Obx(() {
                        if (controller.logoBase64.value.isNotEmpty) {
                          final base64String = controller.logoBase64.value.split(',').last;
                          return Image.memory(
                            const Base64Decoder().convert(base64String),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.white38, size: 40),
                          );
                        } else if (controller.logoUrl.value.isNotEmpty) {
                          return Image.network(
                            controller.logoUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.white38, size: 40),
                          );
                        }
                        return const Icon(Icons.business, color: Colors.white38, size: 40);
                      }),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.pickLogo(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Upload Image'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => controller.removeLogo(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                          ),
                          child: const Text('Remove'),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                CustomFormTextField(
                  title: 'Organization Name',
                  hintText: 'Enter name',
                  isImportant: true,
                  controller: controller.nameController,
                ),
                const SizedBox(height: 16),
                CustomFormTextField(
                  title: 'Description',
                  hintText: 'Enter short description',
                  controller: controller.descriptionController,
                ),
                const SizedBox(height: 16),
                CustomFormTextField(
                  title: 'Domain / Subdomain',
                  hintText: 'e.g. google.com',
                  controller: controller.domainController,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.updateSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.purpleAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Security & Access',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHeaderLabel(Icons.key, 'Authentication'),
          const SizedBox(height: 12),
          _buildSectionCard(
            child: Column(
              children: [
                _buildActionRow(
                  title: 'Organization Password',
                  subtitle: 'Main password for org-level actions.',
                  actionWidget: OutlinedButton(
                    onPressed: () {
                      Get.dialog(const ChangePasswordDialog());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Change Password'),
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),
                _buildActionRow(
                  title: 'Admin Settings Access',
                  subtitle: 'Allow admins to manage these settings.',
                  actionWidget: Obx(() => Switch(
                    value: controller.adminSettingsPermission.value,
                    onChanged: (val) => controller.toggleAdminAccess(val),
                    activeColor: Colors.purpleAccent,
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.dashboard_customize_outlined, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Advanced Settings',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdvancedSettingsGrid(),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildActionRow({required String title, required String subtitle, required Widget actionWidget}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        actionWidget,
      ],
    );
  }

  Widget _buildAdvancedSettingsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final items = [
          _buildAdvancedActionCard(
            title: 'Transfer Ownership',
            subtitle: 'Assign a new owner. You will lose owner privileges but remain as a member.',
            buttonText: 'Transfer',
            icon: Icons.person,
            onPressed: () {
              Get.dialog(const TransferOwnershipDialog());
            },
          ),
          _buildAdvancedActionCard(
            title: 'Deactivate Organization',
            subtitle: 'Temporarily disable access. Data is preserved and can be reactivated.',
            buttonText: 'Deactivate',
            icon: Icons.power_settings_new,
            onPressed: () {
              _showConfirmDialog(
                title: 'Deactivate Organization',
                content: 'Are you sure you want to deactivate this organization? Users will lose access until reactivated.',
                confirmText: 'Deactivate',
                isDestructive: true,
                onConfirm: () {
                  Get.back();
                  controller.deactivateOrganization();
                },
              );
            },
          ),
          _buildAdvancedActionCard(
            title: 'Delete Organization',
            subtitle: 'Permanently remove this organization. This action cannot be undone.',
            buttonText: 'Delete Organization',
            icon: Icons.delete_outline,
            isDestructive: true,
            onPressed: () {
              CommonSnackbar.success("Coming soon!");
            },
          ),
        ];

        if (isMobile) {
          return Column(
            children: items.map((e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: e)).toList(),
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((e) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: e))).toList(),
          );
        }
      },
    );
  }

  Widget _buildAdvancedActionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    bool isDestructive = false,
    required VoidCallback onPressed,
  }) {
    return _buildSectionCard(
      borderColor: isDestructive ? Colors.red.withOpacity(0.3) : Colors.white10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(color: isDestructive ? Colors.redAccent.withOpacity(0.8) : Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? Colors.redAccent : Colors.white12,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required bool isDestructive,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive ? Colors.redAccent : Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(confirmText, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
