import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/controllers/individual_group_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/views/groups_page/create_group_page.dart';
import 'package:rolo_digi_card/views/groups_page/add_cards_to_group_dialog.dart';
import 'package:rolo_digi_card/views/groups_page/group_detail_page.dart';

class MyGroupsPage extends StatefulWidget {
  const MyGroupsPage({Key? key}) : super(key: key);

  @override
  State<MyGroupsPage> createState() => _MyGroupsPageState();
}

class _MyGroupsPageState extends State<MyGroupsPage> {
  bool isGridView = true;
  String sortOption = 'Sort by Date';
  final IndividualGroupController controller = Get.put(IndividualGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground ?? const Color(0xFF14141E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Groups',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage Your Personal Groups',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(() => const CreateGroupPage());
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'New Group',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // const SizedBox(height: 16),

            //  Align(
            //   alignment: Alignment.topRight,
            //    child: GestureDetector(
            //           onTap: () {
            //             Get.to(() => const CreateGroupPage());
            //           },
            //           child: Container(
            //             width: 150,
            //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //             decoration: BoxDecoration(
            //               gradient: const LinearGradient(
            //                 colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
            //               ),
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             child: const Row(
            //               children: [
            //                 Icon(Icons.add, color: Colors.white, size: 18),
            //                 SizedBox(width: 4),
            //                 Text(
            //                   'New Group',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontWeight: FontWeight.w600,
            //                     fontSize: 14,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //  ),

  const SizedBox(height: 16),

            // Search Bar & Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search groups...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sortOption,
                        dropdownColor: const Color(0xFF2A2A38),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: ['Sort by Date', 'Sort by Name']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => sortOption = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Icon(Icons.filter_list, color: Colors.grey[400], size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Meta Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Showing 1 of 1 cards',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Cards/List View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() {
                  if (controller.isLoading.value && controller.groups.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                  }
                  
                  if (controller.filteredGroups.isEmpty) {
                    return Center(
                      child: Text(
                        'No groups found',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }
                  
                  return isGridView ? _buildGridView() : _buildListView();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: controller.filteredGroups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        return _buildGroupCard(controller.filteredGroups[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: controller.filteredGroups.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildGroupCard(controller.filteredGroups[index]),
        );
      },
    );
  }

  Widget _buildGroupCard(GroupModel group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Container(
              //   width: 16,
              //   height: 16,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            group.description ?? 'No description provided',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                '${group.totalCards} cards',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Show Add Cards Bottom Sheet
                  AddCardsToGroupDialog.show(context, group);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add Cards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent, size: 20),
                onPressed: () {
                  Get.to(() => GroupDetailPage(group: group));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.green, size: 20),
                onPressed: () {
                  Get.to(() => CreateGroupPage(group: group));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(group.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Delete Group', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this group?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteGroup(groupId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
