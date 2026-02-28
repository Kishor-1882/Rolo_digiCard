import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rolo_digi_card/controllers/organization/organization_user_management_controller.dart';
import 'package:rolo_digi_card/models/org_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/card_details.dart';
import 'package:rolo_digi_card/views/organization/widgets/edit_permission_dialog.dart';

class OrgUserDetailPage extends StatefulWidget {
  final String userId;

  const OrgUserDetailPage({super.key, required this.userId});

  @override
  State<OrgUserDetailPage> createState() => _OrgUserDetailPageState();
}

class _OrgUserDetailPageState extends State<OrgUserDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OrgUser? _user;
  RxList<OrgCard> _cards = <OrgCard>[].obs;
  bool _isLoading = true;

  OrgUserManagementController get _controller =>
      Get.put(OrgUserManagementController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();

  }

  Future<void> _loadUser() async {
    // Use cached version first for instant display
    final cached = _controller.getCachedUser(widget.userId);
    if (cached != null) {
      setState(() {
        _user = cached;
        _isLoading = false;
      });
    }
    // Then fetch fresh data
    final fresh = await _controller.getUser(widget.userId);
    if (fresh != null && mounted) {
      setState(() {
        _user = fresh;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

    Future<void> _loadCards() async {
    // Use cached version first for instant display
   
    // Then fetch fresh data
    final fresh = await _controller.fetchUserCards(widget.userId);
    if (mounted) {
      _cards.value = _controller.userCards;
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MMMM d, yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: _isLoading && _user == null
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE91E8E)),
              )
            : _user == null
                ? _buildNotFound()
                : _buildContent(),
      ),
    );
  }

  // ── Not Found ─────────────────────────────────────────────────────────────
  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          const Text('User not found', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back', style: TextStyle(color: Color(0xFFE91E8E))),
          ),
        ],
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────
  Widget _buildContent() {
    final user = _user!;
    final cards = _controller.userCards;
     if (cards.isEmpty) {
      _loadCards();
    }
    return Column(
      children: [
        _buildTopBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(user),
              _buildCardsTab(cards:cards, isLoading: _controller.isCardsLoading, totalCount: cards.length),
            ],
          ),
        ),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Back to Users',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF2B2B3A),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Cards'),
          ],
        ),
      ),
    );
  }

  // ── Overview Tab ──────────────────────────────────────────────────────────
  Widget _buildOverviewTab(OrgUser user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildUserPreviewCard(user),
          const SizedBox(height: 16),
          _buildContactInfoCard(user),
          const SizedBox(height: 16),
          _buildActionsCard(user),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── User Preview Card ─────────────────────────────────────────────────────
  Widget _buildUserPreviewCard(OrgUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayRole,
                    style: const TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2B36), thickness: 1),
          // Permissions preview
          if (user.permissions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Permissions',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.permissions.take(6).map((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    p,
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList()
                ..addAll(
                  user.permissions.length > 6
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${user.permissions.length - 6} more',
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ),
                        ]
                      : [],
                ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Contact Info Card ─────────────────────────────────────────────────────
  Widget _buildContactInfoCard(OrgUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2B36), thickness: 1),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.mail_outline,
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2B36), thickness: 1),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: _formatDate(user.createdAt),
          ),
          if (user.lastLogin != null && user.lastLogin!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2B2B36), thickness: 1),
            const SizedBox(height: 12),
            _contactRow(
              icon: Icons.login_outlined,
              label: 'Last Login',
              value: _formatDate(user.lastLogin),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2B36), thickness: 1),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: user.displayRole,
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2B36), thickness: 1),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.verified_outlined,
            label: 'Email Verified',
            value: user.isEmailVerified ? 'Verified' : 'Not verified',
            valueColor: user.isEmailVerified ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Actions Card ──────────────────────────────────────────────────────────
  Widget _buildActionsCard(OrgUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Edit Permissions
          _actionButton(
            label: 'Edit Permissions',
            icon: Icons.edit_outlined,
            borderColor: const Color(0xFFE91E8E),
            textColor: const Color(0xFFE91E8E),
            onTap: () {
              Get.dialog(
                EditPermissionsDialog(user: user),
                barrierDismissible: true,
              ).then((_) => _loadUser());
            },
          ),
          const SizedBox(height: 12),
          // Remove User
          _actionButton(
            label: 'Remove User',
            icon: Icons.delete_outline,
            borderColor: const Color(0xFFFF5252),
            textColor: const Color(0xFFFF5252),
            onTap: () => _showDeleteDialog(user),
          ),
          const SizedBox(height: 12),
          // Activate / Deactivate
          if (user.isActive)
            _actionButton(
              label: 'Deactivate User',
              icon: Icons.pause_circle_outline,
              borderColor: Colors.orangeAccent,
              textColor: Colors.orangeAccent,
              onTap: () => _onDeactivate(user),
            )
          else
            _actionButton(
              label: 'Activate User',
              icon: Icons.lock_open_outlined,
              borderColor: Colors.orangeAccent,
              textColor: Colors.orangeAccent,
              onTap: () => _onActivate(user),
            ),
          // Resend Invite (if not email-verified)
          if (!user.isEmailVerified) ...[
            const SizedBox(height: 12),
            _actionButton(
              label: 'Resend Invitation',
              icon: Icons.send_outlined,
              borderColor: const Color(0xFF8B5CF6),
              textColor: const Color(0xFF8B5CF6),
              onTap: () => _controller.resendInvitation(user.id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withOpacity(0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cards Tab ─────────────────────────────────────────────────────────────
  Widget _buildCardsTab({
  required RxList<OrgCard> cards,
  required RxBool isLoading,
  required int totalCount,
}) {
  return Obx(() {


    if (isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C5CFC)),
      );
    }

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_outlined,
                color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              '$totalCount Card${totalCount == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No cards found',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.credit_card_outlined,
                  color: Color(0xFF7C5CFC), size: 20),
              const SizedBox(width: 8),
              Text(
                'User Cards',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C5CFC).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cards.length} total',
                  style: const TextStyle(
                      color: Color(0xFF7C5CFC), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'All cards created by this user',
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _CardListTile(card: cards[index]),
          ),
        ),
      ],
    );
  });
}

  // ── Action Handlers ───────────────────────────────────────────────────────
  Future<void> _onActivate(OrgUser user) async {
    await _controller.updateUserStatus(user.id, isActive: true);
    await _loadUser();
  }

  Future<void> _onDeactivate(OrgUser user) async {
    await _controller.updateUserStatus(user.id, isActive: false);
    await _loadUser();
  }

  void _showDeleteDialog(OrgUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${user.fullName}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _controller.removeUser(user.id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}


class _CardListTile extends StatelessWidget {
  const _CardListTile({required this.card});
  final OrgCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => CardDetailPage(card: card)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            // Avatar
            _CardAvatar(card: card),
            const SizedBox(width: 12),
            // Name / title / stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name.isEmpty ? '(No name)' : card.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (card.displayTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      card.displayTitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
               
                  Row(
  children: [
    Expanded(
      child: _StatChip(
        icon: Icons.remove_red_eye_outlined,
        value: card.viewCount,
        label: 'views',
      ),
    ),
    Expanded(
      child: _StatChip(
        icon: Icons.qr_code_scanner,
        value: card.scanCount,
        label: 'scans',
      ),
    ),
    Expanded(
      child: _StatChip(
        icon: Icons.bookmark_outline,
        value: card.saveCount,
        label: 'saves',
      ),
    ),
  ],
),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status + View
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ActiveBadge(isActive: card.isActive),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Get.to(() => CardDetailPage(card: card)),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Color(0xFF7C5CFC),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardAvatar extends StatelessWidget {
  const _CardAvatar({required this.card});
  final OrgCard card;

  @override
  Widget build(BuildContext context) {
    final initials = card.name.isNotEmpty
        ? card.name.trim().split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    if (card.profile.isNotEmpty && card.profile.startsWith('data:image')) {
      try {
        final base64Str = card.profile.split(',').last;
        final bytes = base64Decode(base64Str);
        return CircleAvatar(
          radius: 22,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF7C5CFC),
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _StatChip1 extends StatelessWidget {
  const _StatChip1(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 3),
        Text(
          '$value $label',
          style:
              const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '$value $label',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF22C55E).withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF22C55E).withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF22C55E) : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? const Color(0xFF22C55E) : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}