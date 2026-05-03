DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatDate(DateTime date, {bool includeYear = true}) {
  final value = '${monthName(date.month)} ${date.day}';
  return includeYear ? '$value, ${date.year}' : value;
}

String formatShort(DateTime date) =>
    '${monthShortName(date.month)} ${date.day}';

String monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String monthShortName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}
