import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/components/table.dart';
import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final eventService = EventService();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> createEvent(BuildContext context, Map<String,dynamic> data) async{
    try{
      final DonationEvent events = DonationEvent(
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

  Future<void> fetchEvents({bool applyFilters = false}) async {
    try {
      final query = await FirebaseFirestore.instance.collection('events');

      final snapshot = await query.get();

      final inputDate = eventDateController.text.isNotEmpty
        ? DateFormat('d-M-yyyy').parse(eventDateController.text)
        : null;
    
      final filtered = snapshot.docs.where((item) {
        final rewardName = item['event_name']?.toString().toLowerCase() ?? '';
        final location = item['location']?.toString().toLowerCase() ?? '';
        final eventDateTimestamp = item['date_and_time'] as Timestamp?;

        final nameMatch = eventNameController.text.isEmpty || rewardName.contains(eventNameController.text.toLowerCase());

        final locationMatch = locationController.text.isEmpty || location.contains(locationController.text.toLowerCase());

        final dateMatch = inputDate == null || (
          eventDateTimestamp != null &&
          eventDateTimestamp.toDate().year == inputDate.year &&
          eventDateTimestamp.toDate().month == inputDate.month &&
          eventDateTimestamp.toDate().day == inputDate.day
        );

        return nameMatch && dateMatch && locationMatch;
      }).toList();

      setState(() {
        events = filtered.map((doc) {
          final docData = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'event_name': (docData['event_name'] ?? '').toString(),
            'description': (docData['description'] ?? '').toString(),
            'location': (docData['location'] ?? '').toString(),
            'date_and_time': docData['date_and_time'],

          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
      Helpers.showError(context, 'Failed to load events');
    }
  }

  Future<void> editEventDialog(BuildContext context,String docId,Map<String, dynamic> data) async {
    final TextEditingController eventNameController = TextEditingController(
      text: data['event_name'],
    );
    final TextEditingController descriptionController = TextEditingController(
      text: data['description'],
    );
    final TextEditingController locationController = TextEditingController(
      text: data['location'],
    );
    final TextEditingController eventDateController = TextEditingController(
      text: DateFormat('d-M-yyyy').format(data['date_and_time'].toDate()),
    );
    final TextEditingController eventTimeController = TextEditingController(
      text: DateFormat('hh:mm a').format(data['date_and_time'].toDate()),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Event'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _styledInput(eventNameController, 'Event Name'),
                const SizedBox(height: 10),
                _styledInput(descriptionController, 'Description'),
                const SizedBox(height: 10),
                _styledInput(locationController, 'Location'),
                const SizedBox(height: 10),
                _buildDateField(context, eventDateController, 'Date'),
                const SizedBox(height: 10),
                _buildTimeField(context, eventTimeController, 'Time'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final DateTime date = DateFormat('d-M-yyyy').parse(eventDateController.text);
                final TimeOfDay time = TimeOfDay.fromDateTime(
                  DateFormat('hh:mm a').parse(eventTimeController.text),
                );

                final DateTime combinedDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                final updatedData = {
                  'event_name': eventNameController.text,
                  'description': descriptionController.text,
                  'location': locationController.text,
                  'date_and_time': combinedDateTime,
                };
                eventService.updateEvent(docId, updatedData);
                Navigator.of(context).pop();
                Helpers.showSucess(context, 'Event updated successfully');
              } catch (e) {
                Helpers.showError(context, 'Failed to update event');
                Helpers.debugPrintWithBorder('Edit error: $e');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void searchEvent() {
    fetchEvents();
  }

  void resetFilters() {
    eventNameController.clear();
    eventDateController.clear();
    locationController.clear();
    fetchEvents();
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String eventName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Confirmation",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this event?',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(120),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Event Name:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(eventName),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); 
              await eventService.deleteEventImage(docId);
              await eventService.deleteEvent(context, docId);
              Helpers.showSucess(context, 'Event deleted successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );
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
            const Center(
              child: Text(
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
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.redAccent),
                  label: const Text(
                    'Add Event',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            //search and filter
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildSearchAndFilter(),
                    const SizedBox(height: 20),
                    // Display message if no events
                    if (events.isEmpty) 
                      Center(
                        child: Text(
                          'No Events Available.',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      )
                    else 
                      DynamicTable(
                        columns: [
                          'Name',
                          'Description',
                          'Location',
                          'Date',
                          'Action',
                        ],
                        rows:events.map((event) {
                          final eventDate = (event['date_and_time'] as Timestamp).toDate();
                          final formattedEventDate = DateFormat('d MMM yyyy').format(eventDate);

                          return [
                            event['event_name'],
                            event['description'],
                            event['location'],
                            formattedEventDate,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    editEventDialog(context, event['id'],event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[800],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), 
                                    ),
                                  ),
                                  child: Text("Edit"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmation(context, event['id']!, event['event_name']!);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), 
                                    ),
                                  ),
                                  child: Text("Delete"),
                                ),
                              ],
                            )
                          ];
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return ExpansionTile(
      title: const Text(
        'Search & Filter',
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.redAccent),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromARGB(33, 158, 158, 158),
      collapsedBackgroundColor: const Color(0xFFF5F5F5),
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: eventNameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        prefixIcon: Icon(Icons.event),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: "Location",
                        prefixIcon: Icon(Icons.location_city),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: eventDateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          String formattedDate = DateFormat('d-M-yyyy').format(pickedDate);
                          setState(() {
                            eventDateController.text = formattedDate;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: resetFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: searchEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text(
                        "Search",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _styledInput(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('d-M-yyyy').format(pickedDate);
            }
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(DateTime.now()),
            );
            if (picked != null) {
              final now = DateTime.now();
              final formattedTime = DateFormat('hh:mm a').format(
                DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
              );
              controller.text = formattedTime;
            }
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}