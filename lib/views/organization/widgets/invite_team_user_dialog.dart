import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/invite_user_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';

class InviteTeamUserDialog extends StatefulWidget {
  const InviteTeamUserDialog({super.key});

  @override
  State<InviteTeamUserDialog> createState() => _InviteTeamUserDialogState();
}

class _InviteTeamUserDialogState extends State<InviteTeamUserDialog> {
  late final InviteUserController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InviteUserController(), permanent: false);
  }

  @override
  void dispose() {
    Get.delete<InviteUserController>();
    super.dispose();
  }

  bool get _isMobile {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600;
  }

  double get _horizontalPadding => _isMobile ? 16 : 24;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 12 : 20,
        vertical: _isMobile ? 12 : 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: _isMobile ? double.infinity : 520,
          maxHeight: _isMobile ? screenHeight * 0.92 : 700,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(_isMobile ? 20 : 28),
          border: Border.all(color: Colors.white10),
        ),
        child: SafeArea(
          top: _isMobile,
          bottom: _isMobile,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(_horizontalPadding, 8, _horizontalPadding, 24),
                  child: Obx(() {
                    if (controller.stepIndex.value == 0) {
                      return _buildStep1BasicInfo();
                    }
                    return _buildStep2Permissions();
                  }),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(_horizontalPadding, _isMobile ? 16 : 24, _horizontalPadding, 0),
      child: Row(
        children: [
          Icon(Icons.person_add_rounded, color: const Color(0xFF8B5CF6), size: _isMobile ? 24 : 28),
          SizedBox(width: _isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Team User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Add new Users to your organization.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: _isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, color: Colors.white54, size: _isMobile ? 22 : 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Obx(() {
      final step = controller.stepIndex.value;
      final label1 = _isMobile ? 'Basic Info' : 'Basic Information';
      final label2 = 'Permissions';
      return Padding(
        padding: EdgeInsets.fromLTRB(_horizontalPadding, _isMobile ? 14 : 20, _horizontalPadding, 0),
        child: Row(
          children: [
            Expanded(child: _stepChip(1, label1, step == 0)),
            SizedBox(width: _isMobile ? 6 : 8),
            Expanded(child: _stepChip(2, label2, step == 1)),
          ],
        ),
      );
    });
  }

  Widget _stepChip(int number, String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _isMobile ? 10 : 12, vertical: _isMobile ? 10 : 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF8B5CF6).withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF8B5CF6) : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$number',
            style: TextStyle(
              color: isActive ? const Color(0xFF8B5CF6) : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: _isMobile ? 12 : 13,
            ),
          ),
          SizedBox(width: _isMobile ? 4 : 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: _isMobile ? 12 : 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Email'),
        const SizedBox(height: 8),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildLabel('First Name'),
        const SizedBox(height: 8),
        _buildTextField(controller: controller.firstNameController, hint: 'First Name'),
        const SizedBox(height: 20),
        _buildLabel('Last Name'),
        const SizedBox(height: 8),
        _buildTextField(controller: controller.lastNameController, hint: 'Last Name'),
        const SizedBox(height: 24),
        _buildLabel('Select Role'),
        const SizedBox(height: 12),
        Column(
                children: [
                  _buildRoleCard('user', 'User', 'Can view and manage assigned content with specific permissions.', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildRoleCard('admin', 'Administrator', 'Full access to manage users, settings, and all organization resources.', Icons.admin_panel_settings_outlined),
                ],
              ),
        // Obx(() => _isMobile
        //     ? Column(
        //         children: [
        //           _buildRoleCard('user', 'User', 'Can view and manage assigned content with specific permissions.', Icons.person_outline),
        //           const SizedBox(height: 12),
        //           _buildRoleCard('admin', 'Administrator', 'Full access to manage users, settings, and all organization resources.', Icons.admin_panel_settings_outlined),
        //         ],
        //       )
        //     : Row(
        //         children: [
        //           Expanded(child: _buildRoleCard('user', 'User', 'Can view and manage assigned content with specific permissions.', Icons.person_outline)),
        //           const SizedBox(width: 12),
        //           Expanded(child: _buildRoleCard('admin', 'Administrator', 'Full access to manage users, settings, and all organization resources.', Icons.admin_panel_settings_outlined)),
        //         ],
        //       )),
        Obx(() {
          if (controller.role.value == 'admin') {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.radio_button_checked, color: AppColors.chartPurple, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Full administrative access with all permissions',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Continue to Permissions >',
          onPressed: () {
            if (controller.role.value == 'admin') {
              controller.applyFullAccessForAdmin();
            }
            controller.nextStep();
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildEmailField() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.isEmailValid.value ? Colors.green : Colors.white10,
          width: controller.isEmailValid.value ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 22),
          suffixIcon: controller.isEmailValid.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    ));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRoleCard(String value, String title, String subtitle, IconData icon) {
    return Obx(() {
      final isSelected = controller.role.value == value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.setRole(value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(_isMobile ? 14 : 16),
            constraints: BoxConstraints(minHeight: _isMobile ? 72 : 0),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.15) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.white10,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: isSelected ? const Color(0xFF8B5CF6) : Colors.white54, size: _isMobile ? 24 : 28),
                    SizedBox(height: _isMobile ? 8 : 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isMobile ? 14 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: _isMobile ? 11 : 12,
                        height: 1.3,
                      ),
                      maxLines: _isMobile ? 2 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.check_circle, color: const Color(0xFF8B5CF6), size: _isMobile ? 20 : 22),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStep2Permissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isMobile) ...[
          const Text(
            'Configure Permissions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the specific permissions for this team User.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Obx(() => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
              ),
              child: Text(
                '${controller.selectedPermissionsCount} permissions selected',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )),
        ] else
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure Permissions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select the specific permissions for this team User.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                ),
                child: Text(
                  '${controller.selectedPermissionsCount} permissions selected',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ],
          ),
        const SizedBox(height: 20),
        ...kInvitePermissionCategories.map((category) => _buildPermissionCategory(category)),
      ],
    );
  }

  Widget _buildPermissionCategory(PermissionCategory category) {
    return Obx(() {
      final selectedCount = controller.selectedCountInCategory(category);
      final total = category.items.length;
      return _PermissionCategorySection(
        category: category,
        selectedCount: selectedCount,
        total: total,
        controller: controller,
      );
    });
  }

  Widget _buildFooter() {
    return Obx(() {
      final isStep2 = controller.stepIndex.value == 1;
      if (_isMobile && isStep2) {
        return Padding(
          padding: EdgeInsets.fromLTRB(_horizontalPadding, 8, _horizontalPadding, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: controller.previousStep,
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                label: const Text('Back to Details', style: TextStyle(color: Colors.white70, fontSize: 14)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 48),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildPrimaryButton(
                      label: 'Send Invitation',
                      onPressed: controller.isLoading.value ? null : () => controller.sendInvitation(),
                      isLoading: controller.isLoading.value,
                      icon: Icons.send_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      if (_isMobile && !isStep2) {
        return Padding(
          padding: EdgeInsets.fromLTRB(_horizontalPadding, 8, _horizontalPadding, 16),
          child: TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(_horizontalPadding, 0, _horizontalPadding, 24),
        child: Row(
          children: [
            if (isStep2)
              TextButton.icon(
                onPressed: controller.previousStep,
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white70),
                label: const Text('Back to Details', style: TextStyle(color: Colors.white70, fontSize: 14)),
              )
            else
              const SizedBox.shrink(),
            if (isStep2) const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ),
            ),
            if (isStep2) ...[
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => _buildPrimaryButton(
                      label: 'Send Invitation',
                      onPressed: controller.isLoading.value ? null : () => controller.sendInvitation(),
                      isLoading: controller.isLoading.value,
                      icon: Icons.send_rounded,
                    )),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    final minHeight = _isMobile ? 52.0 : 48.0;
    return Container(
      height: minHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PermissionCategorySection extends StatefulWidget {
  final PermissionCategory category;
  final int selectedCount;
  final int total;
  final InviteUserController controller;

  const _PermissionCategorySection({
    required this.category,
    required this.selectedCount,
    required this.total,
    required this.controller,
  });

  @override
  State<_PermissionCategorySection> createState() => _PermissionCategorySectionState();
}

class _PermissionCategorySectionState extends State<_PermissionCategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final c = widget.controller;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final padding = isMobile ? 12.0 : 16.0;
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 14 : 14),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white54,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 14 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${widget.total} permissions • ${widget.selectedCount} selected',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  if (widget.selectedCount == widget.total) {
                                    c.deselectAllInCategory(cat);
                                  } else {
                                    c.selectAllInCategory(cat);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: const Size(0, 44),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  widget.selectedCount == widget.total ? 'Deselect All' : 'Select All',
                                  style: const TextStyle(color: Color(0xFFFF6467), fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white54,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            cat.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.total} permissions • ${widget.selectedCount} selected',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              if (widget.selectedCount == widget.total) {
                                c.deselectAllInCategory(cat);
                              } else {
                                c.selectAllInCategory(cat);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 44),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              widget.selectedCount == widget.total ? 'Deselect All' : 'Select All',
                              style: const TextStyle(color: Color(0xFFFF6467), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.06)),
            ...cat.items.map((item) => Obx(() => CheckboxListTile(
                  value: c.isPermissionSelected(item.apiKey),
                  onChanged: (v) => c.togglePermission(item.apiKey),
                  title: Text(
                    item.label,
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14),
                  ),
                  activeColor: const Color(0xFF8B5CF6),
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: 6),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ))),
            SizedBox(height: isMobile ? 6 : 8),
          ],
        ],
      ),
    );
  }
}
