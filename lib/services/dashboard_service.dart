import 'dart:convert';

import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/models/reward_model.dart';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final rewardService = RewardService();
  final eventService = EventService();

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

  Future<void> createEvent(BuildContext context, Map<String,dynamic> data) async{
    try{
      final DonationEvents events = DonationEvents(
        eventName: data['title'], 
        description: data['description'], 
        dateAndTime: Helpers.combineDateAndTime(data['eventDate'], data['eventTime']), 
        createdAt: DateTime.now(),
        location: data['location'],
      );

      final eventId = await eventService.addEvent(events);

      if(data['poster'] != null && data['poster'].toString().isNotEmpty){
        await uploadEventImage(context, data['poster'], eventId);
      }

      Helpers.showSucess(context, 'Event added sucessfully');
    } catch(e){
      Helpers.showError(context, 'Error.....');
      Helpers.debugPrintWithBorder('Error : $e');
    }
  }

  Future<String?> uploadEventImage(BuildContext context,String base64Image, String eventId) async {
    try {
      final imageBytes = base64Decode(base64Image);

      final imageName = 'event_image_$eventId.jpg';
      final imagePath = '$eventId/$imageName';

      final response = await Supabase.instance.client.storage
          .from('events')
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'), 
          );

      if (response != null) {
        final publicUrl = Supabase.instance.client.storage
            .from('events')
            .getPublicUrl(imagePath);

        Helpers.debugPrintWithBorder('Event image uploaded to: $publicUrl');
        return publicUrl;
      } else {
        Helpers.showError(context, "Failed to upload event image.");
        return null;
      }
    } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading event image.");
      return null;
    }
  }

  Future<void> createReward(BuildContext context,Map<String, dynamic> data) async {
    try {
      final dateFormat = DateFormat('d-M-yyyy');
      final Rewards reward = Rewards(
        rewardName: data['title'],
        description: data['description'],
        startDate: dateFormat.parse(data['startDate']),
        endDate: dateFormat.parse(data['endDate']),
        createdAt: DateTime.now(),
      );
      final rewardId = await rewardService.addReward(reward);

      if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
        await uploadRewardImage(context, data['poster'], rewardId);
      }

      Helpers.showSucess(context, 'Reward added successfully');
    } catch (e) {
      Helpers.showError(context, 'Error.....');
      Helpers.debugPrintWithBorder('Error : $e');
    }
  }

  Future<String?> uploadRewardImage(BuildContext context,String base64Image,String rewardId) async {
    try {
      final imageBytes = base64Decode(base64Image);
      final imageName = 'reward_image_$rewardId.jpg';
      final imagePath = '$rewardId/$imageName';

      final response = await Supabase.instance.client.storage
          .from('rewards')
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      if (response != null) {
        final publicUrl = Supabase.instance.client.storage
            .from('rewards')
            .getPublicUrl(imagePath);
        Helpers.debugPrintWithBorder('Reward image uploaded to: $publicUrl');
        return publicUrl;
      } else {
        Helpers.showError(context, "Failed to upload reward image.");
        return null;
      }
    } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading reward image.");
      return null;
    }
  }
}
