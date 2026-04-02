import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/controllers/organization/add_members_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';

class AddMembersView extends StatefulWidget {
  final GroupModel group;
  const AddMembersView({super.key, required this.group});

  @override
  State<AddMembersView> createState() => _AddMembersViewState();
}

class _AddMembersViewState extends State<AddMembersView> {
  final controller = Get.put(AddMemberController());
  final Set<String> _selectedIds = {};
  final Set<String> _preExistingIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch team members when the view is initialized
    controller.fetchTeamMembers();

    // Pre-select existing members
    if (Get.isRegistered<GroupManagementController>()) {
      final groupCtrl = Get.find<GroupManagementController>();
      final existingMembers = groupCtrl.selectedGroup.value?.members ?? widget.group.members;
      _preExistingIds.addAll(existingMembers.map((e) => e.id));
    } else {
      _preExistingIds.addAll(widget.group.members.map((e) => e.id));
    }
    _selectedIds.addAll(_preExistingIds);
  }

  void _toggleSelection(String id) {
    if (_preExistingIds.contains(id)) {
      return; // Cannot unselect existing members
    }
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      final filteredMembers = _getFilteredMembers();
      final allFilteredIds = filteredMembers.map((m) => m.id as String).toSet();
      // If we've selected all the currently visible items (plus any preexisting)
      if (allFilteredIds.every((id) => _selectedIds.contains(id))) {
        // Clear all except preexisting
        _selectedIds.clear();
        _selectedIds.addAll(_preExistingIds);
      } else {
        _selectedIds.addAll(allFilteredIds);
      }
    });
  }

  List<dynamic> _getFilteredMembers() {
    final activeMembers = controller.teamMembers.where((m) => m.isActive).toList();
    if (_searchQuery.isEmpty) {
      return activeMembers;
    }
    return activeMembers.where((member) {
      final fullName = '${member.firstName} ${member.lastName}'.toLowerCase();
      final email = member.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Search and select users to add',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.teamMembers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE040FB),
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty && controller.teamMembers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchTeamMembers(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE040FB),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredMembers = _getFilteredMembers();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedIds.length} selected',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: filteredMembers.isEmpty ? null : _selectAll,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Select All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white38,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _selectedIds.length == _preExistingIds.length
                            ? null
                            : () => setState(() {
                                  _selectedIds.clear();
                                  _selectedIds.addAll(_preExistingIds);
                                }),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (filteredMembers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                        color: Colors.white38,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No team members available'
                            : 'No members found',
                        style: const TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Try adjusting your search',
                            style: const TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFE040FB),
                  onRefresh: () => controller.fetchTeamMembers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      final isSelected = _selectedIds.contains(member.id);
                      final isPreExisting = _preExistingIds.contains(member.id);
                      final initial = member.firstName.isNotEmpty
                          ? member.firstName[0].toUpperCase()
                          : 'U';

                      return GestureDetector(
                        onTap: () => _toggleSelection(member.id),
                        child: Opacity(
                          opacity: isPreExisting ? 0.5 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFE040FB)
                                  : Colors.white.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE040FB)
                                        : Colors.pinkAccent,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE040FB),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade900,
                                child: Text(
                                  initial,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      member.email,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (member.organizationRole.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          member.organizationRole,
                                          style: const TextStyle(
                                            color: Color(0xFFE040FB),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton.icon(
               onPressed: _selectedIds.isEmpty || controller.isLoading.value
              ? null
             : () async {
               final success = await controller.addMembersToGroup(
                groupId: widget.group.id,
                  userIds: _selectedIds.toList(),
                  cardGroupIds: [widget.group.id], // Pass the group ID
                );
               if (success) {
                 if (Get.isRegistered<GroupManagementController>()) {
                   final groupCtrl = Get.find<GroupManagementController>();
                   groupCtrl.getGroupUsers(widget.group.id);
                   groupCtrl.getGroups();
                   groupCtrl.getGroupById(widget.group.id);
                 }
                 Get.back();
               }
      },
                  icon: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    controller.isLoading.value ? 'Adding...' : 'Add Selected (${_selectedIds.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE040FB),
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
              ),
            ),
          ],
        );
      }),
    );
  }
}