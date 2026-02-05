import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:rolo_digi_card/views/organization/organization_saved_view.dart';
import 'package:rolo_digi_card/views/profile_page/profile_page.dart';
import 'package:rolo_digi_card/views/saved_cards_page/saved_cards.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _isOrg = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(OrganizationController());
    Get.put(SavedItemsController());
    Get.put(CardManagementController());
    Get.put(GroupManagementController());
    Get.put(AnalyticsController());
  }
  

  final List<Widget> _pages = [
     DashboardPage(),
    const MyCardsPage(),
    const SavedCards(),
    const ProfilePage(),
  ];


  final List<Widget> _orgPages = [
    OrganizationDashboardView(),
     OrganizationSavedView(),
     OrganizationCardsView(),
     OrganizationGroupsView(),
     AnalyticsView(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isOrg ? _orgPages[_currentIndex] : _pages[_currentIndex],
      bottomNavigationBar: Container(
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
            padding: const EdgeInsets.only(left: 16,  right:16,bottom: 8),
            child: 
            _isOrg?
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildNavItemOrg(
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard',
                    index: 0,
                  ),
                ),
                Expanded(
                  child: _buildNavItemOrg(
                    icon: Icons.bookmark_outline,
                    label: 'Saved',
                    index: 1,
                  ),
                ),
                Expanded(
                  child: _buildNavItemOrg(
                    icon: Icons.credit_card,
                    label: 'Cards',
                    index: 2,
                  ),
                ),
                Expanded(
                  child: _buildNavItemOrg(
                    icon: Icons.group_outlined,
                    label: 'Groups',
                    index: 3,
                  ),
                ),
                Expanded(
                  child: _buildNavItemOrg(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    index: 4,
                  ),
                ),
              ],
            )
            :Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.credit_card,
                  label: 'My Cards',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.bookmark_outline,
                  label: 'Saved',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient indicator at the top (only for selected item)
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFF6339A),
                  Color(0xFF9810FA),
                ],
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
                    color: isSelected ? Color(0xFFFB64B6) : Color(0xFF6A7282),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient indicator at the top (only for selected item)
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFF6339A),
                  Color(0xFF9810FA),
                ],
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
                    color: isSelected ? Color(0xFFFB64B6) : Color(0xFF6A7282),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
