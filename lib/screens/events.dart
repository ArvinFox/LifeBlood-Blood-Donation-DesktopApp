import 'package:blood_donation_app/components/delete_confirmation_popup.dart';
import 'package:blood_donation_app/components/manage_data_form.dart';
import 'package:blood_donation_app/components/search_and_filter.dart';
import 'package:blood_donation_app/components/table.dart';
import 'package:blood_donation_app/models/event_model.dart';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/services/supabase_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final eventService = EventService();
  final _supabaseService = SupabaseService();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();

  List<DonationEvent> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  void dispose() {
    eventNameController.dispose();
    locationController.dispose();
    eventDateController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents({bool applyFilters = false}) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('events').get();

      final inputDate = eventDateController.text.isNotEmpty
        ? DateFormat('d-M-yyyy').parse(eventDateController.text)
        : null;
    
      final filtered = snapshot.docs.where((item) {
        final eventName = item['event_name']?.toString().toLowerCase() ?? '';
        final location = item['location']?.toString().toLowerCase() ?? '';
        final eventDateTimestamp = item['date_and_time'] as Timestamp?;

        final nameMatch = eventNameController.text.isEmpty || eventName.contains(eventNameController.text.toLowerCase());

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
        events = filtered.map((doc) => DonationEvent.fromFirestore(doc)).toList();
      });
    } catch (e) {
      Helpers.debugPrintWithBorder('Error fetching events: $e');
      Helpers.showError(context, 'Failed to load events');
    }
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
                      builder: (_) => ManageDataForm(
                        formType: FormType.events,
                        onSubmit: (data, isEdit) async{
                          await eventService.manageEvent(
                            context, 
                            data, 
                            onEventManaged: fetchEvents,
                          );
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildSearchAndFilter(),
                    const SizedBox(height: 20),
                    
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
                          final formattedEventDate = DateFormat('d MMM yyyy').format(event.dateAndTime);

                          return [
                            event.eventName,
                            event.description,
                            event.location,
                            formattedEventDate,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:(_) => ManageDataForm(
                                        isEditMode: true,
                                        id: event.eventId,
                                        formType: FormType.events,
                                        onSubmit: (data, isEdit) async {
                                          await eventService.manageEvent(
                                            context, 
                                            data, 
                                            isEdit: true, 
                                            eventId: 
                                            event.eventId, 
                                            onEventManaged: fetchEvents,
                                          );
                                        },
                                      ),
                                    );
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => DeleteConfirmationPopup(
                                        itemType: "event",
                                        itemName: event.eventName,
                                        onDeleteConfirmed: () async {
                                          await _supabaseService.deleteImage('event', event.eventId!);
                                          await eventService.deleteEvent(context, event.eventId!);
                                          Helpers.showSucess(context, 'Event deleted successfully');
                                          fetchEvents();
                                        },
                                      ),
                                    );
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
    return SearchAndFilter(
      title: "Search & Filter",
      searchFields: [
        buildRoundedTextField(
          controller: eventNameController,
          label: "Event Name",
          icon: Icons.event,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
        ),
        buildRoundedTextField(
          controller: locationController,
          label: "Location",
          icon: Icons.location_city,
        ),
        buildRoundedTextField(
          controller: eventDateController,
          label: "Start Date",
          icon: Icons.calendar_today,
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
        ),
      ],
      onSearch: searchEvent,
      onReset: resetFilters,
    );
  }
}