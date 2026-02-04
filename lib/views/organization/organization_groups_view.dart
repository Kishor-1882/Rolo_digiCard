import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/views/organization/org_theme.dart';

class OrganizationGroupsView extends StatelessWidget {
  OrganizationGroupsView({Key? key}) : super(key: key);

  final GroupManagementController groupController = Get.put(GroupManagementController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupController.getGroups();
    });

    return Scaffold(
      backgroundColor: OrgTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   _buildHeader(),
                   const SizedBox(height: 24),
                   _buildStatsCard(),
                ],
              ),
            ),
            Expanded(
              child: _buildGroupList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: OrgTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Groups", style: OrgTheme.headerStyle),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, color: OrgTheme.textSecondary),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: OrgTheme.textSecondary),
              onPressed: () {},
            ),
             const SizedBox(width: 8),
             Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xFF5E17EB), // Dark Purple
                  shape: BoxShape.circle,
              ),
              child: const Text("DU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
      // Image shows a single wide card with:
      // Icon (purple folder), 3 Total Groups, 75 Total Cards.
      // It's a single container.
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Row(
                      children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.folder_outlined, color: Colors.purpleAccent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Obx(() => Text("${groupController.groups.length}", style: OrgTheme.cardTitleStyle)),
                                  const Text("Total Groups", style: OrgTheme.cardLabelStyle),
                              ],
                          ),
                      ],
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          // Total cards in groups? Need to calc or assume
                          Text("75", style: OrgTheme.cardTitleStyle.copyWith(fontSize: 20)),
                          const Text("Total Cards", style: OrgTheme.cardLabelStyle),
                      ],
                  ),
              ],
          ),
      );
  }


  Widget _buildGroupList() {
      return Obx(() {
        if(groupController.isLoading.value) return const Center(child: CircularProgressIndicator());

        if(groupController.groups.isEmpty) {
            return ListView(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 children: [
                     _buildGroupItem(
                         name: "Marketing Team",
                         details: "All marketing department members",
                         members: "12",
                         cards: "24",
                         isPublic: true,
                     ),
                     const SizedBox(height: 12),
                     _buildGroupItem(
                         name: "Sales Team",
                         details: "Sales representatives",
                         members: "8",
                         cards: "16",
                         isPublic: false,
                     ),
                     const SizedBox(height: 12),
                     _buildGroupItem(
                         name: "Engineering",
                         details: "Development team",
                         members: "20",
                         cards: "35",
                         isPublic: true,
                     ),
                 ],
            );
        }

        return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: groupController.groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                  final group = groupController.groups[index];
                  // Need logic for members/cards count if available in model.
                  // GroupModel has members list and cards list.
                  return _buildGroupItem(
                      name: group.name,
                      details: group.description ?? "",
                      members: "${group.members.length}",
                      cards: "${group.cards.length}",
                      isPublic: group.isShared, // Approximate isShared to Public? Or isShared means shared group?
                  );
              },
          );
      });
  }

  Widget _buildGroupItem({
      required String name,
      required String details,
      required String members,
      required String cards,
      required bool isPublic,
  }) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Row(
                              children: [
                                  Text(name, style: const TextStyle(color: OrgTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: isPublic ? OrgTheme.successColor.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                          children: [
                                              Icon(isPublic ? Icons.language : Icons.lock, size: 10, color: isPublic ? OrgTheme.successColor : Colors.pink),
                                              const SizedBox(width: 4),
                                              Text(isPublic ? "Public" : "Private", style: TextStyle(color: isPublic ? OrgTheme.successColor : Colors.pink, fontSize: 10)),
                                          ],
                                      ),
                                  )
                              ],
                          ),
                          const Icon(Icons.more_vert, color: OrgTheme.textSecondary),
                      ],
                  ),
                  const SizedBox(height: 8),
                  Text(details, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                      children: [
                          Icon(Icons.people_outline, size: 16, color: OrgTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text("$members members", style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
                          const SizedBox(width: 16),
                          Icon(Icons.credit_card, size: 16, color: OrgTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text("$cards cards", style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
                      ],
                  )
              ],
          ),
      );
  }
}
