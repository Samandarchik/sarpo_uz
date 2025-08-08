import 'package:intl/intl.dart';

String getMonthName(int month) {
  const months = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
  ];
  return months[month - 1];
}

String formatDateToYYYYMMDD(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String formatDateTimeToHHMM(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('HH:mm').format(dateTime);
  } catch (e) {
    return '';
  }
}

String formatDateTimeToDDMMYYYY(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd.MM.yyyy').format(dateTime);
  } catch (e) {
    return '';
  }
}