// return a formatted data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  // timestamp is the object we retrieve from firebase
  // so to display it, let convert it to a String
  DateTime dateTime = timestamp.toDate();

  // get year
  String year = dateTime.year.toString();

  // get month
  String month = dateTime.month.toString();

  // get day
  String day = dateTime.day.toString();

  //final formatted date
  String formattedDate = '$day/$month/$year';

  return formattedDate;
}

String create14DayTimer(Timestamp timestamp) {
  DateTime originalDate = timestamp.toDate();
  DateTime targetDate = originalDate.add(const Duration(days: 21));

  Duration remainingDuration = targetDate.difference(DateTime.now());
  if (remainingDuration.inSeconds > 0) {
    int days = remainingDuration.inDays;
    int hours = (remainingDuration.inHours % 24);
    int minutes = (remainingDuration.inMinutes % 60);
    int seconds = (remainingDuration.inSeconds % 60);

    String formattedTimeLeft = '$days.d $hours.h $minutes.min $seconds.sec';
    return formattedTimeLeft;
  } else {
    // Timer has reached its target date
    return 'Timer Expired';
  }
}
