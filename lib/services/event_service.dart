import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  //create event
  Future<String> addEvent(DonationEvent event) async {
    final docRef = _firestore.collection('events').doc(); 
    final newEventData = {
      'event_name': event.eventName,
      'description': event.description,
      'date_and_time': event.dateAndTime,
      'created_at': event.createdAt,
      'location': event.location,
    };

    await docRef.set(newEventData); 

    // get document id
    return docRef.id;
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
  Future<void> updateEvent(DonationEvent event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).update(event.toFirestore());
    } catch (e) {
      throw Exception("Failed to update event: $e");
    }
  }

   //delete event
  Future<void> deleteEvent(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(docId).delete();
    } catch (e) {
      Helpers.showError(context, 'Failed to delete event');
      Helpers.debugPrintWithBorder('Delete error: $e');
    }
  }

  //delete reward poster from supabase when deleting a rewad
  Future<void> deleteEventImage(String eventId) async {
    try {
      final imageName = 'event_image_$eventId.jpg';
      final imagePath = '$eventId/$imageName';

      final response = await Supabase.instance.client.storage
          .from('events')
          .remove([imagePath]);

      if (response.isEmpty) {
        print('Image deleted successfully from Supabase Storage.');
      } else {
        print('Some files were not deleted: $response');
      }
    } catch (e) {
      print('Error deleting image from Supabase Storage: $e');
    }
  }
}