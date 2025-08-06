import 'package:flutter/material.dart';

class DateSelectionScreen extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const DateSelectionScreen({super.key, this.onDateSelected});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  int? selectedDay;
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  bool _isSelecting = false;

  final DateTime today = DateTime.now();
  final List<String> monthNames = [
    'Januar',
    'Februar',
    'Mart',
    'April',
    'Maj',
    'Jun',
    'Jul',
    'Avgust',
    'Septembar',
    'Oktobar',
    'Novembar',
    'Decembar',
  ];

  int getDaysInMonth(int month, int year) {
    if (month == 2) {
      return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
          ? 29
          : 28;
    }
    return [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
  }

  int getFirstDayOfMonth(int month, int year) {
    return (DateTime(year, month, 1).weekday - 1) % 7;
  }

  List<List<int?>> generateCalendarWeeks() {
    int daysInMonth = getDaysInMonth(currentMonth, currentYear);
    int firstDay = getFirstDayOfMonth(currentMonth, currentYear);

    List<List<int?>> weeks = [];
    List<int?> currentWeek = List.filled(7, null);
    int dayCounter = 1;

    for (int i = firstDay; i < 7 && dayCounter <= daysInMonth; i++) {
      currentWeek[i] = dayCounter++;
    }
    weeks.add(List.from(currentWeek));

    while (dayCounter <= daysInMonth) {
      currentWeek = List.filled(7, null);
      for (int i = 0; i < 7 && dayCounter <= daysInMonth; i++) {
        currentWeek[i] = dayCounter++;
      }
      weeks.add(List.from(currentWeek));
    }

    return weeks;
  }

  void _previousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
      int daysInNewMonth = getDaysInMonth(currentMonth, currentYear);
      if (selectedDay != null && selectedDay! > daysInNewMonth) {
        selectedDay = null;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
      int daysInNewMonth = getDaysInMonth(currentMonth, currentYear);
      if (selectedDay != null && selectedDay! > daysInNewMonth) {
        selectedDay = null;
      }
    });
  }

  bool isDateInFuture(int day, int month, int year) {
    return DateTime(year, month, day).isAfter(today);
  }

  bool canNavigateToNextMonth() {
    int nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    int nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
    return !DateTime(
      nextYear,
      nextMonth,
      1,
    ).isAfter(DateTime(today.year, today.month, 1));
  }

  Future<void> _handleDateSelection() async {
    if (selectedDay == null || widget.onDateSelected == null) return;

    setState(() => _isSelecting = true);

    try {
      final selectedDate = DateTime(currentYear, currentMonth, selectedDay!);
      debugPrint('📅 Selected date: $selectedDate');
      widget.onDateSelected!(selectedDate);
    } catch (e) {
      debugPrint('❌ Error selecting date: $e');
    } finally {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxContentWidth = screenSize.width * 0.87;

    return Container(
      key: const ValueKey('dateSelection'),
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: maxContentWidth,
              margin: EdgeInsets.only(top: screenSize.height * 0.094),
              child: Text(
                'Kada ste prestali konzumirati nikotin?',
                style: TextStyle(
                  fontFamily: 'Rethink Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  height: 1.3,
                  color: const Color(0xFF000000),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: maxContentWidth,
              margin: EdgeInsets.only(top: screenSize.height * 0.047),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF9A6CD6),
                    ),
                  ),
                  Text(
                    '${monthNames[currentMonth - 1]} $currentYear',
                    style: const TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      height: 1.3,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: canNavigateToNextMonth() ? _nextMonth : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: canNavigateToNextMonth()
                          ? const Color(0xFF9A6CD6)
                          : const Color(0xFF949494),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: maxContentWidth,
              margin: EdgeInsets.only(top: screenSize.height * 0.039),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WeekHeader('PON'),
                  _WeekHeader('UTO'),
                  _WeekHeader('SRI'),
                  _WeekHeader('ČET'),
                  _WeekHeader('PET'),
                  _WeekHeader('SUB'),
                  _WeekHeader('NED'),
                ],
              ),
            ),
            Container(
              width: maxContentWidth,
              margin: EdgeInsets.only(top: screenSize.height * 0.023),
              child: Column(
                children: generateCalendarWeeks()
                    .map(
                      (week) => Column(
                        children: [
                          _buildWeekRow(week),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const Spacer(),
            Container(
              width: maxContentWidth,
              margin: EdgeInsets.only(bottom: screenSize.height * 0.08),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: (selectedDay != null && !_isSelecting)
                      ? _handleDateSelection
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: (selectedDay != null && !_isSelecting)
                        ? const Color(0xFF9A6CD6)
                        : const Color(0xFF949494),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSelecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Nastavi',
                          style: TextStyle(
                            fontFamily: 'Rethink Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.3,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(List<int?> days) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _buildDayCell(day)).toList(),
    );
  }

  Widget _buildDayCell(int? day) {
    if (day == null) return const SizedBox(width: 40, height: 40);

    bool isSelected = selectedDay == day;
    bool isFutureDate = isDateInFuture(day, currentMonth, currentYear);

    return GestureDetector(
      onTap: !isFutureDate ? () => setState(() => selectedDay = day) : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9A6CD6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Rethink Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: isFutureDate
                  ? const Color(0xFFCCCCCC)
                  : isSelected
                  ? Colors.white
                  : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final String day;
  const _WeekHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 16,
      child: Text(
        day,
        style: const TextStyle(
          fontFamily: 'Rethink Sans',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.3,
          color: Color(0xFF676767),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
