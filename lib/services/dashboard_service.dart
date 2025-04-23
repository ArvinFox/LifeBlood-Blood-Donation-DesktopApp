import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalDonors() async {
    final snapshot = await _firestore.collection('user').get();
    return snapshot.size;
  }

  Future<int> getPendingRequests() async {
    final snapshot = await _firestore.collection('requests').get();
    return snapshot.size;
  }

  Future<int> getUpcomingEvents() async {
    try {
      final now = Timestamp.now();
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where(
                'date_and_time',
                isGreaterThan: now,
              ) //Works only for future dates
              .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching upcoming events: $e');
      return 0;
    }
  }

  // UPDATED: Fetch all events with event_name and description for calendar
  Future<Map<DateTime, List<String>>> getAllEventsForCalendar() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      final Map<DateTime, List<String>> events = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['date_and_time'] != null &&
            data['event_name'] != null &&
            data['description'] != null) {
          final DateTime date = (data['date_and_time'] as Timestamp).toDate();
          final normalizedDate = DateTime(date.year, date.month, date.day);

          final eventText = '${data['event_name']} - ${data['description']}';

          if (!events.containsKey(normalizedDate)) {
            events[normalizedDate] = [];
          }
          events[normalizedDate]!.add(eventText);
        }
      }

      return events;
    } catch (e) {
      debugPrint('Error fetching all events for calendar: $e');
      return {};
    }
  }
}
