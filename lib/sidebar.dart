import 'package:flutter/material.dart';
import 'package:rolo_digi_card/views/home_page/home_page.dart';
import 'package:rolo_digi_card/views/my_cards_page/my_cards.dart';
import 'package:rolo_digi_card/views/profile_page/profile_page.dart';
import 'package:rolo_digi_card/views/saved_cards_page/saved_cards.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
     DashboardPage(),
    const MyCardsPage(),
    const SavedCards(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
            child: Row(
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
}
