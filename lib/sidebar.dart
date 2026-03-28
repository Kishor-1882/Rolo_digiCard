import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/controllers/organization/card_management_controller.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/controllers/organization/saved_items_controller.dart';
import 'package:rolo_digi_card/views/home_page/home_page.dart';
import 'package:rolo_digi_card/views/my_cards_page/my_cards.dart';
import 'package:rolo_digi_card/views/organization/analytics_view.dart';
import 'package:rolo_digi_card/views/organization/organization_cards_view.dart';
import 'package:rolo_digi_card/views/organization/organization_dashboard_view.dart';
import 'package:rolo_digi_card/views/organization/organization_groups_view.dart';
import 'package:rolo_digi_card/views/organization/organization_user_management.dart';
import 'package:rolo_digi_card/views/profile_page/profile_page.dart';
import 'package:rolo_digi_card/views/saved_cards_page/saved_cards.dart';
import 'package:rolo_digi_card/views/groups_page/groups_page.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late OrganizationController _orgController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _orgController = Get.put(OrganizationController());
    Get.put(SavedItemsController());
    Get.put(CardManagementController());
    Get.put(GroupManagementController());
    Get.put(AnalyticsController());
  }

  final List<Widget> _pages = [
    DashboardPage(),
    const MyCardsPage(),
    const SavedCards(),
    const MyGroupsPage(),
  ];

  final List<Widget> _orgPages = [
    OrganizationDashboardView(),
    // OrganizationSavedView(),
    OrganizationUserManagement(),
    OrganizationCardsView(),
    OrganizationGroupsView(),
    AnalyticsView(),
  ];

  /// Nav config for individual: (index, permission, label, icon)
  static const _individualNav = [
    (0, 'card:read', 'Home', Icons.grid_view_rounded),
    (1, 'card:read', 'My Cards', Icons.credit_card),
    (2, 'card:read', 'Saved', Icons.bookmark_outline),
    (3, 'card:read', 'Groups', Icons.group_outlined),
  ];

  /// Nav config for organization: (index, permission, label, icon)
  static const _orgNav = [
    (0, 'analytics:read', 'Dashboard', Icons.grid_view_rounded),
    (1, 'user:read', 'Users', Icons.account_circle_outlined),
    (2, 'card:read', 'Cards', Icons.credit_card),
    (3, 'group:read', 'Groups', Icons.group_outlined),
    (4, 'analytics:read', 'Analytics', Icons.analytics_outlined),
  ];

  List<({int index, String? permission, String label, IconData icon})> _visibleNavItems(bool isOrg) {
    final items = isOrg ? _orgNav : _individualNav;
    return items
        .where((e) => e.$2 == null || _authController.hasPermission(e.$2!))
        .map((e) => (index: e.$1, permission: e.$2, label: e.$3, icon: e.$4))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOrg = _authController.userType.value == 'organization';
      final visible = _visibleNavItems(isOrg);
      var currentIndex = _orgController.selectedNavIndex.value;
      if (visible.isEmpty) {
        currentIndex = 0;
      } else if (!visible.any((e) => e.index == currentIndex)) {
        currentIndex = visible.first.index;
        _orgController.selectedNavIndex.value = currentIndex;
      }

      return Scaffold(
        body: isOrg
            ? _orgPages[currentIndex]
            : _pages[currentIndex],
        bottomNavigationBar: visible.isEmpty
            ? null
            : Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: visible.map((item) {
                  final useOrgStyle = isOrg && visible.length > 3;
                  return Expanded(
                    child: useOrgStyle
                        ? _buildNavItemOrg(
                            icon: item.icon,
                            label: item.label,
                            index: item.index,
                          )
                        : _buildNavItem(
                            icon: item.icon,
                            label: item.label,
                            index: item.index,
                          ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _orgController.selectedNavIndex.value == index;
    return GestureDetector(
      onTap: () {
        _orgController.selectedNavIndex.value = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFF6339A).withOpacity(0.20)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.pink.shade300 : Colors.grey[600],
                    size: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFB64B6)
                        : const Color(0xFF6A7282),
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemOrg({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _orgController.selectedNavIndex.value == index;
    return GestureDetector(
      onTap: () {
        _orgController.selectedNavIndex.value = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFF6339A).withOpacity(0.20)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.pink.shade300 : Colors.grey[600],
                    size: 23,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFB64B6)
                        : const Color(0xFF6A7282),
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
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
