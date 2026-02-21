import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/invite_user_controller.dart';
import 'package:rolo_digi_card/controllers/organization/organization_user_management_controller.dart';


class EditPermissionsDialog extends StatefulWidget {
  final OrgUser user;

  const EditPermissionsDialog({super.key, required this.user});

  @override
  State<EditPermissionsDialog> createState() => _EditPermissionsDialogState();
}

class _EditPermissionsDialogState extends State<EditPermissionsDialog> {
  late Set<String> _selectedPermissions;
  late String _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedPermissions = Set<String>.from(widget.user.permissions);
    _selectedRole = widget.user.organizationRole == 'admin' ? 'admin' : 'user';
  }

  OrgUserManagementController get _controller =>
      Get.find<OrgUserManagementController>();

  bool _isCategoryAllSelected(PermissionCategory cat) {
    return cat.items.every((i) => _selectedPermissions.contains(i.apiKey));
  }

  void _toggleCategory(PermissionCategory cat) {
    setState(() {
      if (_isCategoryAllSelected(cat)) {
        for (final item in cat.items) {
          _selectedPermissions.remove(item.apiKey);
        }
      } else {
        for (final item in cat.items) {
          _selectedPermissions.add(item.apiKey);
        }
      }
    });
  }

  void _togglePermission(String apiKey) {
    setState(() {
      if (_selectedPermissions.contains(apiKey)) {
        _selectedPermissions.remove(apiKey);
      } else {
        _selectedPermissions.add(apiKey);
      }
    });
  }

  void _applyAdminPreset() {
    setState(() {
      for (final cat in kInvitePermissionCategories) {
        for (final item in cat.items) {
          _selectedPermissions.add(item.apiKey);
        }
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    bool success;
    if (_selectedRole == 'admin') {
      success = await _controller.updateRole(
        widget.user.id,
        _selectedRole,
        _selectedPermissions.toList(),
      );
    } else {
      success = await _controller.updatePermissions(
        widget.user.id,
        _selectedPermissions.toList(),
      );
    }
    setState(() => _isSaving = false);
    
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A28),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildRoleSelector(),
            const Divider(color: Color(0xFF2B2B36), height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: kInvitePermissionCategories
                      .map((cat) => _buildCategory(cat))
                      .toList(),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Permissions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage what this user can do',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Role', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _roleChip('user', 'Member'),
              const SizedBox(width: 10),
              _roleChip('admin', 'Administrator'),
            ],
          ),
          if (_selectedRole == 'admin') ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _applyAdminPreset,
              child: const Text(
                'Apply Full Access preset',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _roleChip(String value, String label) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
          if (value == 'admin') _applyAdminPreset();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E8E).withOpacity(0.15) : const Color(0xFF2B2B36),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E8E) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE91E8E) : Colors.white54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(PermissionCategory cat) {
    final allSelected = _isCategoryAllSelected(cat);
    final selectedCount = cat.items.where((i) => _selectedPermissions.contains(i.apiKey)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        GestureDetector(
          onTap: () => _toggleCategory(cat),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cat.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$selectedCount/${cat.items.length}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: allSelected
                      ? const Color(0xFFE91E8E)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: allSelected ? const Color(0xFFE91E8E) : Colors.white24,
                  ),
                ),
                child: allSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Permission items
        ...cat.items.map((item) => _buildPermissionItem(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPermissionItem(PermissionItem item) {
    final isSelected = _selectedPermissions.contains(item.apiKey);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: GestureDetector(
        onTap: () => _togglePermission(item.apiKey),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white24,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              item.apiKey,
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Changes (${_selectedPermissions.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}