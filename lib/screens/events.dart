import 'dart:convert';
import 'package:blood_donation_app/components/add_data.dart';
import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<Map<String, dynamic>> _eventData = const [
    {'id': 'E001', 'description': 'Community Blood Drive at Town Hall'},
    {'id': 'E002', 'description': 'Hospital Donation Camp - July'},
    {'id': 'E003', 'description': 'University Blood Donation Program'},
    {'id': 'E004', 'description': 'Long Event Description Example to show horizontal overflow that needs scrolling'},
    {'id': 'E005', 'description': 'Another event with a slightly longer description'},
  ];

  Future<void> createEvent(BuildContext context, Map<String,dynamic> data) async{
    final eventService = EventService();

    try{
      final DonationEvent event = DonationEvent(
        eventName: data['title'], 
        description: data['description'], 
        dateAndTime: Helpers.combineDateAndTime(data['eventDate'], data['eventTime']), 
        createdAt: DateTime.now(),
        location: data['location'],
      );

      final eventId = await eventService.addEvent(event);

      if(data['poster'] != null && data['poster'].toString().isNotEmpty){
        await uploadEventImage(context, data['poster'], eventId);
      }

      Helpers.showSucess(context, 'Event added sucessfully');
    } catch(e){
      Helpers.showError(context, 'Error.....');
      Helpers.debugPrintWithBorder('Error : $e');
    }
  }

  Future<void> uploadEventImage(BuildContext context,String base64Image, String eventId) async {
    try {
      final imageBytes = base64Decode(base64Image);

      final imageName = 'event_image_$eventId.jpg';
      final imagePath = '$eventId/$imageName';

      await Supabase.instance.client.storage
        .from('events')
        .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'), 
        );

      final publicUrl = Supabase.instance.client.storage
        .from('events')
        .getPublicUrl(imagePath);

      Helpers.debugPrintWithBorder('Event image uploaded to: $publicUrl');
      
        } catch (e) {
      Helpers.debugPrintWithBorder('Image upload error: $e');
      Helpers.showError(context, "Error uploading event image.");
    }
  }

  // Layout for very small screens (e.g., mobile - less common for desktop)
  Widget _buildSmallScreenLayout() {
    return ListView.builder(
      itemCount: _eventData.length,
      itemBuilder: (context, index) {
        final event = _eventData[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${event['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Description: ${event['description']}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(onPressed: () {}, child: const Text('Edit')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Layout for small desktop windows / wider tablets
  Widget _buildSmallDesktopLayout() {
    return ListView.builder(
      itemCount: _eventData.length,
      itemBuilder: (context, index) {
        final event = _eventData[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('ID: ${event['id']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: Text('Description: ${event['description']}')),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Edit')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Layout for medium-sized desktop windows - Dynamic sizing with LayoutBuilder
  Widget _buildMediumDesktopLayout(BuildContext context, BoxConstraints constraints) {
    double screenWidth = constraints.maxWidth;
    double baseFontSize = 14.0;
    double scaledFontSize = baseFontSize + (screenWidth - 900) * 0.04; // Adjust scaling factor
    double baseColumnSpacing = 16.0;
    double scaledColumnSpacing = baseColumnSpacing + (screenWidth - 900) * 0.08; // Adjust scaling factor

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200), // Use BoxConstraints from LayoutBuilder or a fixed max
          child: DataTable(
            columnSpacing: scaledColumnSpacing.clamp(baseColumnSpacing, 32.0), // Clamp within range
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 20.0), fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Description', style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 20.0), fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 20.0), fontWeight: FontWeight.bold)),
              ),
            ],
            rows: _eventData.map((event) => DataRow(
              cells: [
                DataCell(Text(event['id'], style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 20.0)))),
                DataCell(Text(event['description'], style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 20.0)))),
                DataCell(
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Edit', style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 18.0))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        child: Text('Delete', style: TextStyle(fontSize: scaledFontSize.clamp(baseFontSize, 18.0))),
                      ),
                    ],
                  ),
                ),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  // Layout for large desktop windows (1200px to < 2000px) - Using ListView.builder with Row
  Widget _buildLargeDesktopLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Row(
              children: [
                Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const Divider(),
            // Table Rows
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _eventData.length,
              itemBuilder: (context, index) {
                final event = _eventData[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(event['id']))),
                        Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(event['description']))),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(onPressed: () {}, child: const Text('Edit')),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Layout for extra-large desktop windows (2000px and above) - Using ListView.builder with Row
  Widget _buildExtraLargeDesktopLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Row(
              children: [
                Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 4, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const Divider(),
            // Table Rows
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _eventData.length,
              itemBuilder: (context, index) {
                final event = _eventData[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(event['id']))),
                        Expanded(flex: 4, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(event['description']))),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(onPressed: () {}, child: const Text('Edit')),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
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
                        onSubmit: (data) async {
                          await createEvent(context, data);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.redAccent),
                  label: const Text(
                    'Add Event',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth < 600) {
                    return _buildSmallScreenLayout();
                  } else if (constraints.maxWidth < 900) {
                    return _buildSmallDesktopLayout();
                  } else if (constraints.maxWidth < 1200) {
                    return _buildMediumDesktopLayout(context, constraints); // Pass constraints
                  } else if (constraints.maxWidth < 2000) {
                    return _buildLargeDesktopLayout();
                  } else {
                    return _buildExtraLargeDesktopLayout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}