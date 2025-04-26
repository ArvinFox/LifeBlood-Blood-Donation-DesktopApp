import 'package:blood_donation_app/components/add_data.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService dashboardService = DashboardService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final events = await dashboardService.getAllEventsForCalendar();
      setState(() {
        _events = events;
      });
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    DateTime normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  bool _hasEvents(DateTime day) {
    DateTime normalized = DateTime(day.year, day.month, day.day);
    return _events.containsKey(normalized) && _events[normalized]!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.0,
                          children: [
                            FutureBuilder<int>(
                              future: dashboardService.getTotalDonors(),
                              builder: (context, snapshot) {
                                return _dashboardCard(
                                  'Total Donors',
                                  snapshot.hasData
                                      ? snapshot.data.toString()
                                      : '...',
                                  Icons.people,
                                  Colors.red,
                                );
                              },
                            ),
                            FutureBuilder<int>(
                              future: dashboardService.getPendingRequests(),
                              builder: (context, snapshot) {
                                return _dashboardCard(
                                  'Pending Requests',
                                  snapshot.hasData
                                      ? snapshot.data.toString()
                                      : '...',
                                  Icons.pending_actions,
                                  Colors.amber,
                                );
                              },
                            ),
                            FutureBuilder<int>(
                              future: dashboardService.getUpcomingEvents(),
                              builder: (context, snapshot) {
                                return _dashboardCard(
                                  'Upcoming Events',
                                  snapshot.hasData
                                      ? snapshot.data.toString()
                                      : '...',
                                  Icons.calendar_today,
                                  Colors.green,
                                );
                              },
                            ),
                            _dashboardCard(
                              'Medical Reports',
                              '217',
                              Icons.description,
                              Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 45),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _modernButton(
                              'Request Donors',
                              Icons.search,
                              () => Navigator.pushNamed(
                                context,
                                '/request-donors',
                              ),
                            ),
                            _modernButton(
                              'View Reports',
                              Icons.description,
                              () => Navigator.pushNamed(
                                context,
                                '/medical-reports',
                              ),
                            ),
                            _modernButton(
                              'Add Event',
                              Icons.event,
                              (){
                                showDialog(
                                  context: context,
                                  builder:(_) => AddData(
                                    formType: FormType.events,
                                    onSubmit: (data) async {
                                      await dashboardService.createEvent(context, data);
                                    },
                                  ),
                                );
                              }
                            ),
                            _modernButton(
                              'Add Reward',
                              Icons.card_giftcard,
                              (){
                                showDialog(
                                  context: context,
                                  builder:(_) => AddData(
                                    formType: FormType.rewards,
                                    onSubmit: (data) async {
                                      await dashboardService.createReward(context, data);
                                    },
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 34),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FB), // Light blue
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Events Calendar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TableCalendar<String>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate:
                                (day) => isSameDay(_selectedDay, day),
                            eventLoader: _getEventsForDay,
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              outsideDaysVisible: false,
                              markerDecoration: const BoxDecoration(),
                              todayTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              // weekendTextStyle: const TextStyle(
                              //   color: Colors.black87,
                              // ),
                              // defaultTextStyle: const TextStyle(
                              //   color: Colors.black,
                              // ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                if (_hasEvents(day)) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._getEventsForDay(_selectedDay ?? _focusedDay).map(
                            (event) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 18,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(event)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  radius: isSmallScreen ? 20 : 28,
                  child: Icon(icon, color: color, size: isSmallScreen ? 20 : 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 30 : 55),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
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

  Widget _modernButton(String label, IconData icon, VoidCallback onTap) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        minimumSize: const Size(160, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
