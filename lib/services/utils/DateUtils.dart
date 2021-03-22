import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dateutils {
  static DateFormat dateFormatter = new DateFormat('dd-MMM-yyyy');
  static DateFormat dateTimeFormatter = new DateFormat('dd MMM, yyyy h:mm a');

  static String getCurrentFormattedDate() {
    return dateFormatter.format(DateTime.now());
  }

  static getTimeAsDateTimeObject(String time) {
    DateFormat dateFormat = new DateFormat.Hm();
    DateTime now = DateTime.now();
    DateTime formattedTime = dateFormat.parse(time);
    return new DateTime(
        now.year, now.month, now.day, formattedTime.hour, formattedTime.minute);
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
      return parsedTime.hourOfPeriod.toString().padLeft(2, '0') +
          ": " +
          parsedTime.minute.toString().padLeft(2, '0') +
          " AM";
    else
      return parsedTime.hourOfPeriod.toString().padLeft(2, '0') +
          ": " +
          parsedTime.minute.toString().padLeft(2, '0') +
          " PM";
  }

  static getTimeInMinutes(String time) {
    List<String> val = time.split(':');
    return (int.parse(val[0]) * 60) + int.parse(val[1]);
  }

  static getCurrentTimeInMinutes() {
    return (DateTime.now().hour * 60) + DateTime.now().minute;
  }

  static String durationInMinutesToHoursAndMinutes(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
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
