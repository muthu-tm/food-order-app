import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  static DateFormat dateFormatter = new DateFormat('dd-MMM-yyyy');
  static DateFormat dateTimeFormatter = new DateFormat('dd-MMM-yyyy h:mm a');

  static String getCurrentFormattedDate() {
    return dateFormatter.format(DateTime.now());
  }

  static String getFormattedDateFromEpoch(int epoch) {
    return dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(epoch));
  }

  static int getUTCDateEpoch(DateTime dateTime) {
    return DateTime.utc(
            dateTime.year, dateTime.month, dateTime.day, 0, 0, 0, 0, 0)
        .millisecondsSinceEpoch;
  }

  static String formatDate(DateTime dateTime) {
    if (dateTime == null) {
      return "";
    }

    return dateFormatter.format(dateTime);
  }

  static getFormattedTime(String time) {
    List<String> val = time.split(':');
    TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(val[0]),
      minute: int.parse(val[1]),
    );

    if (parsedTime.period == DayPeriod.am)
      return parsedTime.hourOfPeriod.toString() +
          "." +
          parsedTime.minute.toString().padLeft(2, '0') +
          " AM";
    else
      return parsedTime.hourOfPeriod.toString() +
          "." +
          parsedTime.minute.toString().padLeft(2, '0') +
          " PM";
  }

  static String formatDateTime(DateTime dateTime) {
    if (dateTime == null) {
      return "";
    }

    return dateTimeFormatter.format(dateTime);
  }

  static DateTime getCurrentDate() {
    DateTime thisInstant = DateTime.now();
    return DateTime(
        thisInstant.year, thisInstant.month, thisInstant.day, 0, 0, 0, 0, 0);
  }

  static DateTime getFormattedDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0, 0, 0);
  }

  static List<int> getDaysInBeteween(DateTime startDate, DateTime endDate) {
    List<int> days = [];

    for (int index = 0;
        index <= endDate.difference(startDate).inDays;
        index++) {
      DateTime newDate = startDate.add(Duration(days: index));

      days.add(
          DateTime.utc(newDate.year, newDate.month, newDate.day, 0, 0, 0, 0, 0)
              .millisecondsSinceEpoch);
    }
    return days;
  }
}
