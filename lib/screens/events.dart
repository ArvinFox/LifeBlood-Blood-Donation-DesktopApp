import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  Future<void> createEvent(BuildContext context, Map<String,dynamic> data) async{
    final eventService = EventService();

    try{
      final DonationEvents events = DonationEvents(
        eventName: data['title'], 
        description: data['description'], 
        dateAndTime: Helpers.combineDateAndTime(data['eventDate'], data['eventTime']), 
        createdAt: DateTime.now()
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


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Manage Events',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddData(
                        formType: FormType.events, 
                        onSubmit: (data) async{
                          await createEvent(context, data);
                        }
                      ),
                    );
                  },
                  icon: Icon(Icons.add_circle, color: Colors.redAccent),
                  label: Text(
                    'Add Event',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}