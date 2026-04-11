import 'package:flutter/material.dart';

class DateFilterDropdown extends StatelessWidget {
  final DateFilterOption selected;
  final ValueChanged<DateFilterOption> onChanged;

  const DateFilterDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _bgColor = Color(0xFF1E1E2E);
  static const _borderColor = Color(0xFF2E2E45);
  static const _accentColor = Color(0xFF7C5CFC);
  static const _selectedBg = Color(0xFF2A2A3E);
  static const _textColor = Color(0xFFE8E8F0);
  static const _mutedColor = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: _accentColor, size: 14),
            const SizedBox(width: 6),
            Text(
              selected.label,
              style: const TextStyle(
                color: _textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _mutedColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<DateFilterOption>(
      context: context,
      position: position,
      color: const Color(0xFF1A1A28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2E2E45)),
      ),
      elevation: 12,
      items: DateFilterOption.values.map((option) {
        final isSelected = option == selected;
        return PopupMenuItem<DateFilterOption>(
          value: option,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            color: isSelected ? _selectedBg : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? _accentColor : _textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (result != null) onChanged(result);
  }
}

enum DateFilterOption {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last30Days,
  thisYear,
  lastYear,
}

extension DateFilterOptionLabel on DateFilterOption {
  String get label {
    switch (this) {
      case DateFilterOption.today:
        return 'Today';
      case DateFilterOption.yesterday:
        return 'Yesterday';
      case DateFilterOption.thisWeek:
        return 'This Week';
      case DateFilterOption.lastWeek:
        return 'Last Week';
      case DateFilterOption.thisMonth:
        return 'This Month';
      case DateFilterOption.lastMonth:
        return 'Last Month';
      case DateFilterOption.last30Days:
        return 'Last 30 Days';
      case DateFilterOption.thisYear:
        return 'This Year';
      case DateFilterOption.lastYear:
        return 'Last Year';
    }
  }

  int get days {
    switch (this) {
      case DateFilterOption.today:
        return 1;
      case DateFilterOption.yesterday:
        return 2;
      case DateFilterOption.thisWeek:
        return 7;
      case DateFilterOption.lastWeek:
        return 14;
      case DateFilterOption.thisMonth:
        return 30;
      case DateFilterOption.lastMonth:
        return 60;
      case DateFilterOption.last30Days:
        return 30;
      case DateFilterOption.thisYear:
        return 365;
      case DateFilterOption.lastYear:
        return 730;
    }
  }

  /// Logic mirrors your API: day boundaries are at 18:30 UTC (midnight IST).
  Map<String, String> get dateRange {
    final now = DateTime.now().toUtc();

    // IST midnight = 18:30 UTC previous day
    // "Start of today" in IST means 18:30 UTC of the previous calendar day.
    DateTime todayStart =
        DateTime.utc(now.year, now.month, now.day - 1, 18, 30, 0, 0);
    // If current UTC time is already past 18:30, today's IST start is today at 18:30 UTC
    if (now.hour > 18 || (now.hour == 18 && now.minute >= 30)) {
      todayStart = DateTime.utc(now.year, now.month, now.day, 18, 30, 0, 0);
    }
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    DateTime start;
    DateTime end;

    switch (this) {
      case DateFilterOption.today:
        start = todayStart;
        end = todayEnd;
        break;

      case DateFilterOption.yesterday:
        start = todayStart.subtract(const Duration(days: 1));
        end = todayStart.subtract(const Duration(milliseconds: 1));
        break;

      case DateFilterOption.thisWeek:
        // Week starts Monday IST
        final daysFromMonday = now.weekday - 1; // Monday = 1
        start = todayStart.subtract(Duration(days: daysFromMonday));
        end = todayEnd;
        break;

      case DateFilterOption.lastWeek:
        final daysFromMonday = now.weekday - 1;
        end = todayStart
            .subtract(Duration(days: daysFromMonday))
            .subtract(const Duration(milliseconds: 1));
        start = end
            .subtract(const Duration(days: 6))
            .copyWith(hour: 18, minute: 30, second: 0, millisecond: 0);
        break;

      case DateFilterOption.thisMonth:
        // Start of current month in IST = last day of previous month at 18:30 UTC
        start = DateTime.utc(now.year, now.month, 1)
            .subtract(const Duration(hours: 5, minutes: 30));
        end = todayEnd;
        break;

      case DateFilterOption.lastMonth:
        final firstOfThisMonth = DateTime.utc(now.year, now.month, 1)
            .subtract(const Duration(hours: 5, minutes: 30));
        end = firstOfThisMonth.subtract(const Duration(milliseconds: 1));
        start = DateTime.utc(now.year, now.month - 1, 1)
            .subtract(const Duration(hours: 5, minutes: 30));
        break;

      case DateFilterOption.last30Days:
        start = todayStart.subtract(const Duration(days: 30));
        end = todayEnd;
        break;

      case DateFilterOption.thisYear:
        start = DateTime.utc(now.year, 1, 1)
            .subtract(const Duration(hours: 5, minutes: 30));
        end = todayEnd;
        break;

      case DateFilterOption.lastYear:
        start = DateTime.utc(now.year - 1, 1, 1)
            .subtract(const Duration(hours: 5, minutes: 30));
        end = DateTime.utc(now.year, 1, 1)
            .subtract(const Duration(hours: 5, minutes: 30, milliseconds: 1));
        break;
    }

    return {
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
    };
  }
}
