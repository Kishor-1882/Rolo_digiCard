import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/card_management_controller.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/views/organization/org_theme.dart';

class OrganizationCardsView extends StatelessWidget {
  OrganizationCardsView({Key? key}) : super(key: key);

  final CardManagementController cardController = Get.put(CardManagementController());
  final AnalyticsController analyticsController = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cardController.getOrganizationCards();
      analyticsController.getOverview();
    });

    return Scaffold(
      backgroundColor: OrgTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildStatsRow(),
                   const SizedBox(height: 24),
                   _buildSearchAndFilters(),
                   const SizedBox(height: 16),
                   _buildTabs(),
                   const SizedBox(height: 16),
                   Obx(() => Text("${cardController.orgCards.length} cards created", style: const TextStyle(color: OrgTheme.textSecondary))),
                ],
              ),
            ),
            Expanded(
              child: _buildCardList(),
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

  Widget _buildStatsRow() {
    return Obx(() {
        final total = cardController.orgCards.length;
        final active = cardController.orgCards.where((c) => c.isActive ?? false).length;
        final inactive = total - active;

        return Row(
            children: [
                 Expanded(child: _buildStatCard(
                    icon: Icons.credit_card,
                    color: Colors.purpleAccent,
                    value: "$total",
                    label: "Total Cards"
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(
                    icon: Icons.visibility,
                    color: OrgTheme.successColor,
                    value: "$active",
                    label: "Active"
                )),
                // const SizedBox(width: 12),
                // Expanded(child: _buildStatCard(
                //     icon: Icons.power_settings_new,
                //     color: OrgTheme.warningColor,
                //     value: "$inactive",
                //     label: "Deactivated"
                // )),
            ],
        );
    });
  }

  Widget _buildStatCard({required IconData icon, required Color color, required String value, required String label}) {
     return Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(value, style: OrgTheme.cardTitleStyle),
                const SizedBox(height: 4),
                Text(label, style: OrgTheme.cardLabelStyle),
            ],
          ),
      );
  }

  Widget _buildSearchAndFilters() {
      return Column(
          children: [
               TextField(
                decoration: InputDecoration(
                    hintText: "Search cards...",
                    hintStyle: const TextStyle(color: OrgTheme.textSecondary),
                    filled: true,
                    fillColor: OrgTheme.cardBackgroundColor,
                    prefixIcon: const Icon(Icons.search, color: OrgTheme.textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                    ),
                ),
                style: const TextStyle(color: OrgTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
                children: [
                     _buildDropdown("Mode: All Modes"),
                     const SizedBox(width: 8),
                     _buildDropdown("Visibility: All"),
                     const SizedBox(width: 8),
                     _buildDropdown("Status: All"),
                ],
            )
          ],
      );
  }

  Widget _buildDropdown(String text) {
      return Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: OrgTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(text, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
                    const Icon(Icons.keyboard_arrow_down, color: OrgTheme.textSecondary, size: 16),
                ],
            ),
        ),
      );
  }

  Widget _buildTabs() {
      return Row(
          children: [
               _buildTabItem("All", isSelected: true),
               _buildTabItem("Saved"),
               _buildTabItem("My Cards"),
               _buildTabItem("Assigned"),
          ],
      );
  }

  Widget _buildTabItem(String text, {bool isSelected = false}) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: isSelected 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A), // Dark Purple
                borderRadius: BorderRadius.circular(20)
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
        : Text(text, style: const TextStyle(color: OrgTheme.textSecondary)),
      );
  }

  Widget _buildCardList() {
      return Obx(() {
        if(cardController.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        final list = cardController.orgCards;
        if(list.isEmpty) {
             return ListView(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 children: [
                     _buildCardItem(
                         initial: "K", 
                         name: "Kishor", 
                         role: "Developer", 
                         company: "DigiSailor", 
                         views: "3", 
                         scans: "0", 
                         theme: "Glassmorphic", 
                         isPublic: true,
                         color: Colors.deepPurple,
                     ),
                     const SizedBox(height: 12),
                     _buildCardItem(
                         initial: "J", 
                         name: "John Doe", 
                         role: "Product Manager", 
                         company: "TechCorp", 
                         views: "156", 
                         scans: "12", 
                         theme: "Minimal", 
                         isPublic: false,
                         color: Colors.deepPurpleAccent,
                     ),
                      const SizedBox(height: 12),
                     _buildCardItem(
                         initial: "J", 
                         name: "Jane Smith", 
                         role: "Designer", 
                         company: "DesignStudio", 
                         views: "0", 
                         scans: "0", 
                         theme: "Glassmorphic", 
                         isPublic: true,
                         color: Colors.deepPurple,
                     ),
                 ],
             );
        }

        return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
                final card = list[index];
                return _buildCardItem(
                    initial: (card.name != null && card.name!.isNotEmpty) ? card.name!.substring(0,1).toUpperCase() : "C",
                    name: card.name ?? "Unknown",
                    role: card.title ?? "No Title",
                    company: card.company ?? "No Company",
                    views: "${card.viewCount ?? 0}",
                    scans: "0", // Model field?
                    theme: "Default",
                    isPublic: true, // Field?
                    color: Colors.deepPurple,
                );
            },
        );
      });
  }

  Widget _buildCardItem({
      required String initial,
      required String name,
      required String role,
      required String company,
      required String views,
      required String scans,
      required String theme,
      required bool isPublic,
      required Color color,
  }) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Column(
              children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(initial, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Row(
                                          children: [
                                              Text(name, style: const TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(width: 8),
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
                                      const SizedBox(height: 4),
                                      Text(role, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
                                      Text(company, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
                                  ],
                              ),
                          ),
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.qr_code, color: Colors.purpleAccent, size: 20),
                          ),
                           const SizedBox(width: 8),
                          const Icon(Icons.more_vert, color: OrgTheme.textSecondary),
                      ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                      children: [
                          Icon(Icons.remove_red_eye_outlined, size: 14, color: OrgTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(views, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.qr_code_scanner, size: 14, color: OrgTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(scans, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
                          const Spacer(),
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(theme, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
                          ),
                      ],
                  )
              ],
          ),
      );
  }
}
