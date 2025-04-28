import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/services/supabase_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseService _supabaseService = SupabaseService();
  
  // Create event
  Future<void> _createEvent(DonationEvent event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
    } catch (e) {
      Helpers.debugPrintWithBorder("Error adding event: $e");
    }
  }

  // Get next ID
  String _getNextEventDocId() {
    return _firestore.collection('events').doc().id;
  }

  // Get event by ID
  Future<DonationEvent?> getEventById(String eventId) async {
    try {
      DocumentSnapshot eventDoc = await _firestore.collection("events").doc(eventId).get();
      if (!eventDoc.exists) return null;

      return DonationEvent.fromFirestore(eventDoc);
      
    } catch (e) {
      throw Exception("Failed to get event by id: $e");
    }
  }

  // Update event
  Future<void> _updateEvent(DonationEvent event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).update(event.toFirestore());
    } catch (e) {
      throw Exception("Failed to update event: $e");
    }
  }

  // Add/Edit event
  Future<void> manageEvent(BuildContext context, Map<String,dynamic> data, {String? eventId, bool isEdit = false, Future<void> Function()? onEventManaged}) async{
    try{
      final DonationEvent event = DonationEvent(
        eventName: data['title'], 
        description: data['description'],
        location: data['location'], 
        dateAndTime: Helpers.combineDateAndTime(data['eventDate'], data['eventTime']), 
      );

      if (!isEdit) {
        final now = DateTime.now();
        event.createdAt = now;
        event.updatedAt = now;
        
        final newEventId = _getNextEventDocId();
        event.eventId = newEventId;

        if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
          final imageName = await _uploadEventImage(context, data['poster'], newEventId);
          event.imageName = imageName;
        }

        await _createEvent(event);
        
      } else {
        event.eventId = eventId;
        event.createdAt = data['createdAt'];
        event.updatedAt = DateTime.now();

        if (data['poster'] != null && data['poster'].toString().isNotEmpty) {
          final imageName = await _uploadEventImage(context, data['poster'], eventId!);
          event.imageName = imageName;
        }

        await _updateEvent(event);
      }

      Helpers.showSucess(context, 'Event ${isEdit ? 'updated' : 'added'} sucessfully');
    
      if (onEventManaged != null) {
        await onEventManaged();
      }

    } catch(e){
      Helpers.showError(context, 'Error ${isEdit ? 'updating' : 'adding'} event');
      Helpers.debugPrintWithBorder('Error ${isEdit ? 'updating' : 'creating'} event: $e');
    }
  }

  Future<String?> _uploadEventImage(BuildContext context,String base64Image, String eventId) async {
    try {
      final imageName = await _supabaseService.uploadImage('event', base64Image, eventId);
      return imageName;

    } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading event image.");
      return null;
    }
  }

   // Delete event
  Future<void> deleteEvent(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(docId).delete();
    } catch (e) {
      Helpers.showError(context, 'Failed to delete event');
      Helpers.debugPrintWithBorder('Error deleting event: $e');
    }
  }
}