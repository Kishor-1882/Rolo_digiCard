import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/organization_user_management_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AssignCardDialog
// ─────────────────────────────────────────────────────────────────────────────

class AssignCardDialog extends StatefulWidget {
  const AssignCardDialog({
    super.key,
    required this.cardId,
    required this.users,
    required this.isUsersLoading,
    required this.isAssigning,
    required this.onAssign,
    this.currentUserId,
  });

  final String cardId;
  final String? currentUserId;

  /// Pass your controller's RxList<OrgUser> here
  final RxList<OrgUser> users;
  final RxBool isUsersLoading;
  final RxBool isAssigning;

  /// Called with the selected userId when user taps "Assign"
  final Future<void> Function(String userId) onAssign;

  @override
  State<AssignCardDialog> createState() => _AssignCardDialogState();
}

class _AssignCardDialogState extends State<AssignCardDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  OrgUser? _selectedUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrgUser> _filtered(List<OrgUser> users) {
    if (_query.isEmpty) return users;
    return users.where((u) {
      final name = '${u.firstName} ${u.lastName}'.toLowerCase();
      final email = u.email.toLowerCase();
      return name.contains(_query) || email.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.person_add_outlined,
                    color: Color(0xFF7C5CFC), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Assign Card to User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white.withOpacity(0.4), size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              'Select a user to assign this card to',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45), fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.3), size: 18),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.white.withOpacity(0.3), size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7C5CFC)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── User list ───────────────────────────────────────────────────
          Obx(() {
            if (widget.isUsersLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF7C5CFC), strokeWidth: 2),
                ),
              );
            }

            final filtered = _filtered(widget.users);

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_search_outlined,
                          color: Colors.white.withOpacity(0.2), size: 40),
                      const SizedBox(height: 10),
                      Text(
                        _query.isEmpty
                            ? 'No users available'
                            : 'No results for "$_query"',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  final isSelected = _selectedUser?.id == user.id;
                  final isCurrent = widget.currentUserId == user.id;

                  return _UserTile(
                    user: user,
                    isSelected: isSelected,
                    isCurrent: isCurrent,
                    onTap: () {
                      if (!isCurrent) {
                        setState(() {
                          _selectedUser = isSelected ? null : user;
                        });
                      }
                    },
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),

          // ── Footer buttons ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final busy = widget.isAssigning.value;
                    final canAssign =
                        _selectedUser != null && !busy;

                    return ElevatedButton(
                      onPressed: canAssign
                          ? () async {
                              await widget.onAssign(_selectedUser!.id);
                          
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5CFC),
                        disabledBackgroundColor:
                            const Color(0xFF7C5CFC).withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Assign',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  final OrgUser user;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = '${user.firstName} ${user.lastName}'
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C5CFC).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C5CFC).withOpacity(0.5)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected
                  ? const Color(0xFF7C5CFC)
                  : Colors.white.withOpacity(0.1),
              child: Text(
                initials.isNotEmpty ? initials : '?',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}'.trim().isEmpty
                            ? 'Unknown User'
                            : '${user.firstName} ${user.lastName}'.trim(),
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C5CFC).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Color(0xFF7C5CFC),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (user.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(
                            isCurrent ? 0.25 : 0.45),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Check indicator
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF7C5CFC), size: 20)
            else if (isCurrent)
              Icon(Icons.check_circle_outline,
                  color: Colors.white.withOpacity(0.2), size: 20)
            else
              Icon(Icons.radio_button_unchecked,
                  color: Colors.white.withOpacity(0.15), size: 20),
          ],
        ),
      ),
    );
  }
}