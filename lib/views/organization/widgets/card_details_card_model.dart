import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/organization/organization_user_management_controller.dart';
import 'package:rolo_digi_card/models/org_model.dart';
import 'package:rolo_digi_card/views/organization/widgets/assign_card_dialog.dart';

class CardDetailsCardModel extends StatelessWidget {
  const CardDetailsCardModel({super.key, required this.card});
  final OrgCard card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Card Details',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Metrics Row ──
            _MetricsRow(card: card),
            const SizedBox(height: 16),

            // ── Card Preview ──
            _CardPreviewSection(card: card),
            const SizedBox(height: 16),

            // ── Assignment ──
            _AssignmentSection(card: card),
            const SizedBox(height: 16),

            // ── Actions ──
            _ActionsSection(card: card),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Metrics Row ────────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.card});
  final OrgCard card;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: Icons.remove_red_eye_outlined,
        iconColor: const Color(0xFF818CF8),
        iconBg: const Color(0xFF818CF8),
        value: card.viewCount,
        label: 'PERFORMANCE',
        title: 'Views',
      ),
      _MetricData(
        icon: Icons.share_outlined,
        iconColor: const Color(0xFF34D399),
        iconBg: const Color(0xFF34D399),
        value: card.shareCount,
        label: 'REACH',
        title: 'Shares',
      ),
      _MetricData(
        icon: Icons.qr_code_scanner,
        iconColor: const Color(0xFF60A5FA),
        iconBg: const Color(0xFF60A5FA),
        value: card.scanCount,
        label: 'CONNECTIONS',
        title: 'Scans',
      ),
      _MetricData(
        icon: Icons.favorite_border,
        iconColor: const Color(0xFFF87171),
        iconBg: const Color(0xFFF87171),
        value: card.saveCount,
        label: 'COLLECTION',
        title: 'Saves',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: metrics.map((m) => _MetricCard(data: m)).toList(),
    );
  }
}

class _MetricData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int value;
  final String label;
  final String title;
  const _MetricData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.title,
  });
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});
  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ← don't expand unnecessarily

        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: data.iconBg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 14),
          ),
          const Spacer(),
          Text(
            '${data.value}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card Preview Section ───────────────────────────────────────────────────

class _CardPreviewSection extends StatelessWidget {
  const _CardPreviewSection({required this.card});
  final OrgCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Card Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _ActiveBadge(isActive: card.isActive),
            ],
          ),
          const SizedBox(height: 20),

          // Avatar + basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardAvatar(card: card),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name.isEmpty ? '(No name)' : card.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (card.title.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (card.company.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_outlined,
                              size: 13,
                              color: Colors.white.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(
                            card.company,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),

          // Contact Info
          const Text(
            'Contact Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (card.email.isNotEmpty)
            _ContactRow(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF7C5CFC),
              value: card.email,
            ),
          if (card.phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ContactRow(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFF60A5FA),
              value: card.phone,
            ),
          ],

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Expanded(
                child: _DateInfo(
                    label: 'Created',
                    date: card.formattedCreatedAt),
              ),
              Expanded(
                child: _DateInfo(
                    label: 'Last Updated',
                    date: card.formattedUpdatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
      {required this.icon, required this.iconColor, required this.value});
  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style:
                const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _DateInfo extends StatelessWidget {
  const _DateInfo({required this.label, required this.date});
  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 12, color: Colors.white.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(date,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

// ── Assignment Section ─────────────────────────────────────────────────────

class _AssignmentSection extends StatefulWidget {
  const _AssignmentSection({required this.card});
  final OrgCard card;

  @override
  State<_AssignmentSection> createState() => _AssignmentSectionState();
}

class _AssignmentSectionState extends State<_AssignmentSection> {
final controller = Get.put(OrgUserManagementController());

     void _onAssignUser() {
    if (controller.allUsers.isEmpty) controller.fetchAllUsers();
    showDialog(
      context: context,
      builder: (_) => AssignCardDialog(
        cardId: widget.card.id,
        currentUserId: widget.card.assignedUser?.id,
        users: controller.allUsers,
        isUsersLoading: controller.isUsersLoading,
        isAssigning: controller.isAssigning,
        onAssign: (userId) async {
          final ok = await controller.assignCardToUser(widget.card.id, userId);
           Get.back();
          if (ok) CommonSnackbar.success('Card assigned successfully');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignedUser = widget.card.assignedUser;
    final isAssigned = assignedUser != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline,
                  color: Colors.white.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Assignment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (!isAssigned)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_add_outlined,
                      color: const Color(0xFFF59E0B).withOpacity(0.7),
                      size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Unassigned',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No user assigned to this card',
                    style: TextStyle(
                      color: const Color(0xFFF59E0B).withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFC).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF7C5CFC).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF7C5CFC),
                    child: Text(
                      assignedUser.fullName.isNotEmpty
                          ? assignedUser.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignedUser.fullName.isNotEmpty
                              ? assignedUser.fullName
                              : 'Assigned User',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        if (assignedUser.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            assignedUser.email,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
            onPressed: () => _onAssignUser(),
              icon: const Icon(Icons.person_add_outlined,
                  size: 16, color: Color(0xFF7C5CFC)),
              label: Text(
                isAssigned ? 'Change User' : 'Assign User',
                style: const TextStyle(color: Color(0xFF7C5CFC)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7C5CFC)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Actions Section ────────────────────────────────────────────────────────

class _ActionsSection extends StatefulWidget {
   _ActionsSection({required this.card});
  final OrgCard card;

  @override
  State<_ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<_ActionsSection> {
final controller = Get.put(OrgUserManagementController());

  // ── Empty stubs — fill in API calls when ready ──────────────────────────
  void _onViewInBrowser() {
    // TODO: launch URL — e.g. launchUrl(Uri.parse('https://yourapp.com/c/${card.shortUrl}'))
  }

  void _onAssignUser() {
    if (controller.allUsers.isEmpty) controller.fetchAllUsers();
    showDialog(
      context: context,
      builder: (_) => AssignCardDialog(
        cardId: widget.card.id,
        currentUserId: widget.card.assignedUser?.id,
        users: controller.allUsers,
        isUsersLoading: controller.isUsersLoading,
        isAssigning: controller.isAssigning,
        onAssign: (userId) async {
          final ok = await controller.assignCardToUser(widget.card.id, userId);
          Get.back();
          if (ok) CommonSnackbar.success('Card assigned successfully');
        },
      ),
    );
  }

  void _onToggleActive() {
   controller.toggleCardActive(widget.card, onSuccess: () {
     setState(() {}); // Refresh UI to reflect active status change
   });
  }

  void _onDeleteCard() {
    controller.deleteCard(widget.card.id, onSuccess: () {
      Get.back(); // Return to previous screen after deletion
    }); 
  }

  // ───────────────────────────────────────────────────────────────────────
@override
  Widget build(BuildContext context) {
    log("Card Doubt:${widget.card.id}");
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // ── View in Browser ──
          _ActionButton(
            icon: Icons.open_in_browser_outlined,
            label: 'View Card in Browser',
            color: const Color(0xFF7C5CFC),
            onPressed: () => _onViewInBrowser(),
          ),
          const SizedBox(height: 10),

          // ── Assign User ──
          _ActionButton(
            icon: Icons.person_add_outlined,
            label: widget.card.assignedUser != null
                ? 'Change Assigned User'
                : 'Assign User',
            color: const Color(0xFF60A5FA),
            onPressed: () => _onAssignUser(),
          ),
          const SizedBox(height: 10),

          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 10),

          // ── Deactivate / Activate ──
          _ActionButton(
            icon: widget.card.isActive
                ? Icons.lock_outline
                : Icons.lock_open_outlined,
            label: widget.card.isActive ? 'Deactivate Card' : 'Activate Card',
            color: Colors.redAccent,
            onPressed: () => _confirmToggleActive(context),
          ),
          const SizedBox(height: 10),

          // ── Delete ──
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'Delete Card',
            color: Colors.redAccent,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmToggleActive(BuildContext context) {
    final action = widget.card.isActive ? 'Deactivate' : 'Activate';
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: '$action Card',
        message: 'Are you sure you want to ${action.toLowerCase()} this card?',
        confirmLabel: action,
        onConfirm: _onToggleActive,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Card',
        message: 'This action cannot be undone. Are you sure you want to delete this card?',
        confirmLabel: 'Delete',
        onConfirm: _onDeleteCard,
      ),
    );
  }
}

// ── Reusable Action Button ─────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ── Reusable Confirm Dialog ────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content:
          Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: Text(confirmLabel,
              style: const TextStyle(color: Colors.redAccent)),
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