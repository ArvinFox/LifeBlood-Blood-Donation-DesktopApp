import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final rewardService = RewardService();
  final eventService = EventService();

  Future<int> getDonorsCount() async {
    try {
      final snapshot = await _firestore.collection('user').get();
      return snapshot.size; 

    } catch (e) {
      Helpers.debugPrintWithBorder("Error fetching donors count: $e");
      return 0;
    }
  }

  Future<int> getPendingRequestsCount() async {
    try {
      final snapshot = await _firestore.collection('requests').get();
      return snapshot.size; 

    } catch (e) {
      Helpers.debugPrintWithBorder("Error fetching pending requests count: $e");
      return 0;
    }
  }

  Future<int> getUpcomingEventsCount() async {
    try {
      final now = Timestamp.now();
      final querySnapshot =
          await _firestore
              .collection('events')
              .where(
                'date_and_time',
                isGreaterThan: now,
              ) //Works only for future dates
              .get();

      return querySnapshot.docs.length;

    } catch (e) {
      Helpers.debugPrintWithBorder('Error fetching upcoming events: $e');
      return 0;
    }
  }

  Future<int> getMedicalReportsCount() async {
    try {
      final snapshot = await _firestore.collection('medical_reports').get();
      return snapshot.size; 

    } catch (e) {
      Helpers.debugPrintWithBorder("Error fetching medical reports count: $e");
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
