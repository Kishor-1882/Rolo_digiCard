import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/add_cards_view.dart';
import 'package:rolo_digi_card/views/organization/add_members_view.dart';
import 'package:rolo_digi_card/views/organization/organization_user_details.dart';
import 'package:rolo_digi_card/views/organization/widgets/card_details_card_model.dart';
import 'package:rolo_digi_card/views/organization/widgets/card_details_group.dart';

class GroupDetailView extends StatefulWidget {
  final GroupModel group;
  bool isUserGroup;

  GroupDetailView({super.key, required this.group, required this.isUserGroup});

  @override
  State<GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<GroupDetailView> with SingleTickerProviderStateMixin {
  final controller = Get.find<GroupManagementController>();
    late TabController _tabController;


  @override
  void initState() {
    super.initState();
     _tabController = TabController(length: 2, vsync: this);
    controller.getGroupUsers(widget.group.id);
    controller.getGroupById(widget.group.id);
  }

   @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

   Future<void> _openLinkCardGroupsDialog() async {
    // Show loading spinner while fetching
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    List<dynamic> cardGroups = [];
    try {
      cardGroups = await controller.fetchCardGroups();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to load card groups',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      return;
    }
    Get.back(); // close loading

    // Pre-select currently linked groups
    final linked = controller.selectedGroup.value?.linkedGroups ?? [];
    final Set<String> preSelected = linked
        .map<String>((g) =>
            (g is Map ? (g['_id'] ?? g['id'] ?? '') : g.toString()))
        .toSet();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => _LinkCardGroupsDialog(
        cardGroups: cardGroups,
        preSelectedIds: preSelected,
        onSave: (selectedIds) async {
          Navigator.of(ctx).pop();
          try {
            await controller.linkCardGroups(
                widget.group.id, selectedIds.toList());
            await controller.getGroupById(widget.group.id);
            Get.snackbar('Success', 'Card groups updated',
                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
                colorText: Colors.white);
          } catch (e) {
            Get.snackbar('Error', 'Failed to link card groups',
                backgroundColor: Colors.red.withOpacity(0.8),
                colorText: Colors.white);
          }
        },
      ),
    );
  }

  // ── Unlink a single card group ─────────────────────────────────────────────

 // Replace your existing _confirmUnlink method in _GroupDetailViewState with this:

void _confirmUnlink(String groupId, String groupName) {
  // Get member count from the linked group data
  final linkedGroups = controller.selectedGroup.value?.linkedGroups ?? [];
  final groupData = linkedGroups.firstWhere(
    (g) => (g is Map ? (g['_id'] ?? g['id'] ?? '') : g.toString()) == groupId,
    orElse: () => null,
  );
  final memberCount = groupData is Map
      ? (groupData['members'] as List?)?.length ?? 0
      : 0;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF1A1A26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red trash icon in circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Unlink Card Group?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            // Body text with bold group name + member count
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.white60, fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: 'Are you sure you want to unlink '),
                  TextSpan(
                    text: groupName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                      text: '?\nThis will remove access for all '),
                  TextSpan(
                    text:
                        '$memberCount member${memberCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel + Unlink buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();

                      // Remove this groupId from the linked list
                      final current =
                          controller.selectedGroup.value?.linkedGroups ?? [];
                      final updatedIds = current
                          .map<String>((g) => g is Map
                              ? (g['_id'] ?? g['id'] ?? '')
                              : g.toString())
                          .where((id) => id != groupId)
                          .toList();

                      try {
                        await controller.linkCardGroups(
                            widget.group.id, updatedIds);
                        await controller.getGroupById(widget.group.id);
                        Get.snackbar(
                          'Unlinked',
                          '"$groupName" has been removed.',
                          backgroundColor:
                              const Color(0xFF4CAF50).withOpacity(0.9),
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to unlink card group.',
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Unlink',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.group.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      // body: SingleChildScrollView(
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       _buildGroupHeader(),
      //       const SizedBox(height: 16),
      //       _buildInfoCard(),
      //       const SizedBox(height: 24),
      //       _buildMembersSection(),
      //       const SizedBox(height: 24),
      //     ],
      //   ),
      // ),
      body:  Column(
        children: [
          // Top static section: stats + info card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildInfoCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Tab bar
           if (widget.isUserGroup) ...[
      _buildTabBar(),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersTab(),
            _buildCardsTab(),
          ],
        ),
      ),
    ] else
      Expanded(
        child: _buildCardGroupSection(),
      ),
  ],
  
      ),
    );

  }


  Widget _buildCardGroupSection() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Obx(() {
      final cards = controller.selectedGroup.value?.cards ?? [];
      log("DUmmy CARDS: ${cards.length}");
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.layers_outlined,
                        color: Color(0xFF4CAF50), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cards',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          '${cards.length} cards in this group',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Your existing Add Cards navigation
                      // Get.to(() => AddCardsView(group: widget.group));
                      Get.to(() => AddCardsView(group: widget.group));
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text(
                      'Add Cards',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC44EE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Column headers
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141420),
                border: Border.symmetric(
                  horizontal:
                      BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text('Card Name',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Destination',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Status',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  SizedBox(width: 60),
                  Text('Actions',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),

            // Empty state
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.credit_card_outlined,
                        color: Colors.white24, size: 48),
                    const SizedBox(height: 12),
                    const Text('No cards added yet',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => AddCardsView(group: widget.group));
                      },
                      icon: const Icon(Icons.add,
                          size: 16, color: Colors.white),
                      label: const Text('Add Cards',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC44EE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: cards.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.07),
                  indent: 16,
                  endIndent: 16,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final card = cards[index]; 

                  // Support both Map (full object) and String (ID only)
                  final cardId = card is Map
                      ? (card.id ?? '')
                      : card.toString();


                  final firstName = card is Map
                      ? (card.name ??
                          'Card ${index + 1}')
                      : 'Card ${index + 1}';
                  final lastName =
                      card is Map ? (card.name ?? '') : '';
                  final destination =
                      card is Map ? (card.title ?? '') : '';
                  final isActive =
                      card is Map ? (card.isActive ?? true) : true;

                  final initials =
                      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                          .toUpperCase();


                  final avatarColors = [
                    const Color(0xFF9B59B6),
                    const Color(0xFF3B82F6),
                    const Color(0xFF10B981),
                    const Color(0xFFEF4444),
                    const Color(0xFF6C3EB8),
                  ];
                  final avatarColor =
                      avatarColors[index % avatarColors.length];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: avatarColor,
                          child: Text(
                            initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Card Name
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${card.name} $lastName'.trim(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Destination
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              const Icon(Icons.link,
                                  color: Colors.white38, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  card.title.isNotEmpty
                                      ? card.title
                                      : '—',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status badge
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1A1A26)
                                  : const Color(0xFF2C2C3C),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Disabled',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Actions: eye + delete
                        GestureDetector(
                          onTap: () {
                            Get.to(() => CardDetailsCardModel(card: card));
                            // Navsigate to card detail if needed
                          },
                          child: const Icon(Icons.remove_red_eye_outlined,
                              color: Color(0xFF4FC3F7), size: 20),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 4),
          ],
        ),
      );
    }),
  );
}

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFCC44EE),
        unselectedLabelColor: Colors.white54,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        indicatorColor: const Color(0xFFCC44EE),
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Users'),
          Tab(text: 'Cards'),
        ],
      ),
    );
  }


Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final members = controller.selectedGroup.value?.members ?? [];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.group_outlined,
                          color: Color(0xFF4FC3F7), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Members',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            '${members.length} members in this group',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Get.to(() => AddMembersView(group: widget.group)),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text('Add Members',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC44EE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Column headers row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141420),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Text('Member',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12))),
                    Expanded(
                        flex: 4,
                        child: Text('Email',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12))),
                    Expanded(
                        flex: 2,
                        child: Text('Role',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12))),
                    SizedBox(width: 30),
                  ],
                ),
              ),

              // Loading state
              if (controller.isLoading.value)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              // Empty state
              else if (members.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.group_outlined,
                          color: Colors.white24, size: 48),
                      const SizedBox(height: 16),
                      const Text('No members added yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(
                            () => AddMembersView(group: widget.group)),
                        icon: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                        label: const Text('Add Members',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC44EE),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                )
              // Members list
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.07),
                    indent: 16,
                    endIndent: 16,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final user = members[index];
                    log("USER: $user");

                    final firstName = user.firstName ?? '';
                    final lastName = user.lastName ?? '';
                    final email = user.email ?? '';
                    final initials =
                        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                            .toUpperCase();

                    final ownerId =
                        controller.selectedGroup.value?.ownerId;
                    final userId = user.id ??  '';
                    final isOwner = ownerId != null &&
                        (ownerId == userId ||
                            (ownerId is Map && ownerId.id == userId));
                    final role = user.organizationRole ?? '';

                    final avatarColors = [
                      const Color(0xFF9B59B6),
                      const Color(0xFF6C3EB8),
                      const Color(0xFF3B82F6),
                      const Color(0xFF10B981),
                      const Color(0xFFEF4444),
                    ];
                    final avatarColor =
                        avatarColors[index % avatarColors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: avatarColor,
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                          const SizedBox(width: 10),

                          // Name + owner badge
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$firstName $lastName',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isOwner)
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC44EE)
                                          .withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFCC44EE)
                                              .withOpacity(0.5)),
                                    ),
                                    child: const Text(
                                      'Owner of the Group',
                                      style: TextStyle(
                                          color: Color(0xFFCC44EE),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Email
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                const Icon(Icons.mail_outline,
                                    color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Role badge
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C3C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.15)),
                              ),
                              child: Text(
                                role,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Eye icon
                          GestureDetector(
                            onTap: () => Get.to(
                                () => OrgUserDetailPage(userId: userId)),
                            child: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: Color(0xFF4FC3F7),
                                size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 4),
            ],
          ),
        );
      }),
    );
  }

  // ── Cards tab ──────────────────────────────────────────────────────────────

  Widget _buildCardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final linkedGroups =
            controller.selectedGroup.value?.linkedGroups ?? [];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.layers_outlined,
                          color: Color(0xFF4CAF50), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Linked Card Groups',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            'Members of this group will have access to cards in these groups.',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _openLinkCardGroupsDialog,
                      icon: const Icon(Icons.add,
                          size: 16, color: Colors.white),
                      label: const Text('Add Card Group',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC44EE),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Empty state
              if (linkedGroups.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      Divider(
                          color: Colors.white.withOpacity(0.07), height: 1),
                      const SizedBox(height: 32),
                      const Icon(Icons.layers_outlined,
                          color: Colors.white24, size: 48),
                      const SizedBox(height: 12),
                      const Text('No card groups linked yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap "Add Card Group" to link card groups.',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              // Linked groups list
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: linkedGroups.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.07),
                    indent: 16,
                    endIndent: 16,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final g = linkedGroups[index];
                    final name = g is Map
                        ? (g['name'] ?? 'Unknown')
                        : g.toString();
                    final cardCount = g is Map
                        ? (g['cards'] as List?)?.length ?? 0
                        : 0;
                    final groupId = g is Map
                        ? (g['_id'] ?? g['id'] ?? '')
                        : g.toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF242433),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.layers_outlined,
                                color: Colors.white54, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.credit_card_outlined,
                                        color: Colors.white38,
                                        size: 12),
                                    const SizedBox(width: 4),
                                    Text('$cardCount cards',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              log("dd");
                              // Navigate to card group detail if needed
                              // Get.to(() => CardDetailsCardModel(card:));
                            },
                            child: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: Color(0xFF4FC3F7),
                                size: 20),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () =>
                                _confirmUnlink(groupId, name),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white38, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 4),
            ],
          ),
        );
      }),
    );
  }


  // Large icon + name header (matches top of image)
  Widget _buildGroupHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAB4FE8), Color(0xFF7B2FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.group_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 16),
        Text(
          widget.group.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

Widget _buildStatsRow() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildStatBox(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF4FC3F7),
                label: 'Members',
                value: '${controller.selectedGroup.value?.members.length ?? 0}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatBox(
                icon: Icons.layers_outlined,
                iconColor: const Color(0xFF4CAF50),
                label: 'Card Groups',
                value:
                    '${controller.selectedGroup.value?.linkedGroups?.length ?? 0}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatBox(
                icon: Icons.people_alt_outlined,
                iconColor: const Color(0xFF4FC3F7),
                label: 'Type',
                value: widget.isUserGroup ? 'User\nGroup' : 'Card\nGroup',
                valueFontSize: 13,
              ),
            ),
          ],
        ));
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    double valueFontSize = 22,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  // Stats + metadata card (matches the dark rounded card in the image)
  // Widget _buildInfoCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1A1A26),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.white.withOpacity(0.07)),
  //     ),
  //     child: Column(
  //       children: [
  //         // Top stats row: Members | Card Groups | Type
  //         Obx(() => Row(
  //               children: [
  //                 Expanded(
  //                   child: _buildStatBox(
  //                     value: '${controller.groupUsers.length}',
  //                     label: 'Members',
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: _buildStatBox(
  //                     label: 'Card Groups',
  //                     value: '${controller.selectedGroup.value?.cards.length ?? 0}',
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: _buildStatBox(
  //                     label: 'Type',
  //                     value: widget.isUserGroup ? 'User Group' : 'Card Group',
  //                     valueFontSize: 13,
  //                   ),
  //                 ),
  //               ],
  //             )),

  //         Divider(color: Colors.white.withOpacity(0.08), height: 32),

  //         // Bottom row: Group Name | Created
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Group Name',
  //                     style: TextStyle(color: Colors.white54, fontSize: 12),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     widget.group.name,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Created',
  //                     style: TextStyle(color: Colors.white54, fontSize: 12),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Row(
  //                     children: [
  //                       const Icon(Icons.calendar_today_outlined,
  //                           color: Colors.white70, size: 14),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         _formatDate(widget.group.createdAt),
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

   Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Group Name',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      widget.group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Created',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(widget.group.createdAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.group.description != null &&
              widget.group.description!.isNotEmpty) ...[
            Divider(color: Colors.white.withOpacity(0.08), height: 28),
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.group.description!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildStatBox({
  //   required String value,
  //   required String label,
  //   double valueFontSize = 22,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF242433),
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: valueFontSize,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           label,
  //           style: const TextStyle(color: Colors.white54, fontSize: 11),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Members section header + list
  Widget _buildMembersSection() {
    return Column(
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                widget.isUserGroup
                    ? Get.to(() => AddMembersView(group: widget.group))
                    : Get.to(() => AddCardsView(group: widget.group));
              },
              icon: const Icon(Icons.person_add_alt_1_outlined,
                  size: 16, color: Colors.white),
              label: Text(
                widget.isUserGroup ? 'Add Members' : 'Add Cards',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC44EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Members list card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final members = controller.selectedGroup.value?.members ?? [];
            log("Seven MEMBERS: ${members.length}");
            if (members.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: members.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.07),
                indent: 16,
                endIndent: 16,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final user = members[index];
                log("USER: $user");

                final firstName = user.firstName ?? '';
                final lastName = user.lastName ?? '';
                final email = user.email ?? '';
                final initials =
                    '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                        .toUpperCase();

                // Determine role — owner gets ADMIN badge
                final ownerId = controller.selectedGroup.value?.ownerId;
                final userId = user.id ?? '';
                final isOwner = ownerId != null &&
                    (ownerId == userId ||
                        (ownerId is Map && ownerId.id == userId));
                final role =  user.organizationRole;
                // Pick avatar color based on index
                final avatarColors = [
                  const Color(0xFF9B59B6),
                  const Color(0xFF6C3EB8),
                  const Color(0xFF3B82F6),
                  const Color(0xFF10B981),
                  const Color(0xFFEF4444),
                ];
                final avatarColor = avatarColors[index % avatarColors.length];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: avatarColor,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name + owner tag + email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$firstName $lastName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isOwner) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC44EE)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFCC44EE)
                                              .withOpacity(0.5)),
                                    ),
                                    child: const Text(
                                      'Owner of the Group',
                                      style: TextStyle(
                                        color: Color(0xFFCC44EE),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C3C),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Eye icon
                      GestureDetector(
                        onTap: () {
                          Get.to(()=>OrgUserDetailPage(userId: userId));
                        },
                        child: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Color(0xFF4FC3F7),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No members added yet',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              widget.isUserGroup
                  ? Get.to(() => AddMembersView(group: widget.group))
                  : Get.to(() => AddCardsView(group: widget.group));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              widget.isUserGroup ? 'Add Members' : 'Add Cards',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}



class _LinkCardGroupsDialog extends StatefulWidget {
  final List<dynamic> cardGroups;
  final Set<String> preSelectedIds;
  final void Function(Set<String> selectedIds) onSave;

  const _LinkCardGroupsDialog({
    required this.cardGroups,
    required this.preSelectedIds,
    required this.onSave,
  });

  @override
  State<_LinkCardGroupsDialog> createState() => _LinkCardGroupsDialogState();
}

class _LinkCardGroupsDialogState extends State<_LinkCardGroupsDialog> {
  late Set<String> _selected;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.preSelectedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.cardGroups.where((g) {
      final name =
          (g is Map ? g['name'] ?? '' : g.toString()).toString().toLowerCase();
      return name.contains(_search.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: const Color(0xFF1A1A26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link Card Groups',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select or deselect card groups to sync with this user group.',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close,
                      color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF242433),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search card groups...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white38, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Card group list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No card groups found',
                        style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final g = filtered[index];
                      final id = g is Map
                          ? (g['_id'] ?? g['id'] ?? '')
                          : g.toString();
                      final name = g is Map
                          ? (g['name'] ?? 'Unknown')
                          : g.toString();
                      final cardCount = g is Map
                          ? (g['cards'] as List?)?.length ?? 0
                          : 0;
                      final memberCount = g is Map
                          ? (g['members'] as List?)?.length ?? 0
                          : 0;
                      final isSelected = _selected.contains(id);

                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selected.remove(id);
                          } else {
                            _selected.add(id);
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6B21A8).withOpacity(0.3)
                                : const Color(0xFF242433),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFCC44EE)
                                      .withOpacity(0.5)
                                  : Colors.white.withOpacity(0.07),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFCC44EE)
                                          .withOpacity(0.2)
                                      : const Color(0xFF1A1A26),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          Colors.white.withOpacity(0.1)),
                                ),
                                child: const Icon(Icons.layers_outlined,
                                    color: Colors.white54, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$cardCount cards • $memberCount members',
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              // Circle checkbox
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFFCC44EE)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFCC44EE)
                                        : Colors.white38,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer: Cancel + Save Changes
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onSave(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC44EE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
