import 'package:blood_donation_app/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}