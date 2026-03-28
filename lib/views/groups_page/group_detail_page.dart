import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/individual_group_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/groups_page/add_cards_to_group_dialog.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/qr_details.dart';
import 'package:share_plus/share_plus.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupModel group;
  const GroupDetailPage({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final IndividualGroupController controller = Get.find<IndividualGroupController>();
  String _searchQuery = '';
  bool _isGridView = false;

  GroupModel get currentGroup {
    // Always pull the latest version of this group from the controller
    return controller.groups.firstWhere(
      (g) => g.id == widget.group.id,
      orElse: () => widget.group,
    );
  }

  // Cards that belong to this group (from myCards, matched by cardIds)
  List<CardModel> get groupCards {
    final ids = currentGroup.cardIds.toSet();
    return controller.myCards.where((c) => ids.contains(c.id)).toList();
  }

  List<CardModel> get filteredCards {
    if (_searchQuery.isEmpty) return groupCards;
    return groupCards.where((c) =>
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (c.company?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
      (c.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141E),
      body: SafeArea(
        child: Obx(() {
          final group = currentGroup;
          final totalCards = group.cardIds.length;
          final activeCards = groupCards.where((c) => true).length; // CardModel has no isActive, show total

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      // Back row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                          ),
                          // const Spacer(),
                          // GestureDetector(
                          //   onTap: () => AddCardsToGroupDialog.show(context, group),
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          //     decoration: BoxDecoration(
                          //       color: Colors.white.withValues(alpha: 0.15),
                          //       borderRadius: BorderRadius.circular(8),
                          //       border: Border.all(color: Colors.white30),
                          //     ),
                          //     child: const Row(
                          //       children: [
                          //         Icon(Icons.group_add_outlined, color: Colors.white, size: 16),
                          //         SizedBox(width: 6),
                          //         Text('Add Cards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Group identity
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.group_outlined, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Group Overview',
                                  style: TextStyle(color: Colors.white60, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                           GestureDetector(
                            onTap: () => AddCardsToGroupDialog.show(context, group),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.group_add_outlined, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text('Add Cards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if ((group.description ?? '').isNotEmpty) ...[
                        const Text('Description', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            group.description ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Stats row
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(Icons.credit_card, 'Total Cards', '$totalCards', const Color(0xFF1E3A5F))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(Icons.remove_red_eye_outlined, 'Active Cards', '$activeCards', const Color(0xFF0D3B2D))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cards in Group section header
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.credit_card, color: Color(0xFF8B5CF6), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Cards in Group', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(
                                        '$totalCards card${totalCards != 1 ? 's' : ''} · $activeCards active',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                // View toggle
                                // Container(
                                //   decoration: BoxDecoration(
                                //     color: const Color(0xFF2A2A38),
                                //     borderRadius: BorderRadius.circular(6),
                                //     border: Border.all(color: Colors.white12),
                                //   ),
                                //   child: Row(
                                //     children: [
                                //       _buildToggleIcon(Icons.list, !_isGridView, () => setState(() => _isGridView = false)),
                                //       _buildToggleIcon(Icons.grid_view_rounded, _isGridView, () => setState(() => _isGridView = true)),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Search bar
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF14141E),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: TextField(
                                onChanged: (val) => setState(() => _searchQuery = val),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Search cards...',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 18),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Card list or empty state
              if (filteredCards.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(group))
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCardTile(filteredCards[index], group.id),
                      childCount: filteredCards.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCardTile(filteredCards[index], group.id),
                      ),
                      childCount: filteredCards.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white38, size: 16),
      ),
    );
  }

  Widget _buildCardTile(CardModel card, String groupId) {
    final initials = card.name.isNotEmpty ? card.name[0].toUpperCase() : '?';
    final title = card.title ?? '';
    final company = card.company ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF8B5CF6),
            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(card.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (title.isNotEmpty)
                  Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (company.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.grey[600], size: 11),
                      const SizedBox(width: 3),
                      Expanded(child: Text(company, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active', style: TextStyle(color: AppColors.textGreen, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showCardDetail(card),
                    child: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _confirmRemoveCard(groupId, card.id),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(GroupModel group) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.credit_card, color: Colors.white38, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No cards found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Add your first card to this group and start managing your network efficiently.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => AddCardsToGroupDialog.show(context, group),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_add_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Add Your First Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetail(CardModel card) {
    final title = card.title ?? '';
    final company = card.company ?? '';
    final email = card.contact?.email ?? '';
    final phone = card.contact?.phone ?? '';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF8B5CF6),
                child: Text(
                  card.name.isNotEmpty ? card.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              const SizedBox(height: 12),
              Text(card.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(title, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14)),
                ),
              if (company.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(company, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    if (email.isNotEmpty)
                      _buildDetailRow(Icons.email_outlined, email),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.phone_outlined, phone),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Public Card toggle row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 16, color: Colors.white60),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Public Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Anyone can view', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: true,
                      onChanged: null,
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons row 1: Copy & Share
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.copy_outlined,
                      label: 'Copy',
                      onTap: () {
                        Navigator.pop(context);
                        final url = card.publicUrl ?? '';
                        if (url.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: url));
                          CommonSnackbar.success('Card link copied!');
                        } else {
                          CommonSnackbar.error('No public URL available');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () {
                        Navigator.pop(context);
                        _shareContact(card);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Action Buttons row 2: Save & QR
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.person_add_outlined,
                      label: 'Save',
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await _saveContactToPhone(card);
                          CommonSnackbar.success('Contact saved!');
                        } catch (e) {
                          CommonSnackbar.error(
                            e.toString().contains('denied')
                                ? 'Contacts permission required'
                                : 'Failed to save contact',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.qr_code_2_outlined,
                      label: 'QR',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => QRCodeSharePage(card: card));
                      },
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

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A38),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContactToPhone(CardModel card) async {
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) throw Exception('Contacts permission denied');

    String phone = card.contact?.phone ?? '';
    phone = phone.replaceFirst(RegExp(r'\s+ext\.\s*\S+\$', caseSensitive: false), '').trim();

    final contact = Contact(
      name: Name(first: card.name),
      phones: phone.isNotEmpty ? [Phone(phone)] : [],
      emails: (card.contact?.email?.isNotEmpty ?? false) ? [Email(card.contact!.email!)] : [],
      organizations: (card.company?.isNotEmpty ?? false)
          ? [Organization(company: card.company ?? '', title: card.title ?? '')]
          : [],
    );
    await FlutterContacts.openExternalInsert(contact);
  }

  Future<void> _shareContact(CardModel card) async {
    final vcf = '''
BEGIN:VCARD
VERSION:3.0
FN:${card.name}
N:${card.name};;;;
ORG:${card.company ?? ''}
TITLE:${card.title ?? ''}
TEL;TYPE=CELL:${card.contact?.phone ?? ''}
EMAIL:${card.contact?.email ?? ''}
END:VCARD'''.trim();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${card.name}.vcf');
    await file.writeAsString(vcf);
    await Share.shareXFiles([XFile(file.path)], text: 'Contact details for ${card.name}');
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }

  void _confirmRemoveCard(String groupId, String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Remove Card', style: TextStyle(color: Colors.white)),
        content: const Text('Remove this card from the group?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.removeCardFromGroup(groupId, cardId);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
