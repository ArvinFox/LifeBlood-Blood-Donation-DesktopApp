import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _navItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),
                _divider(),
                _navItem(context, Icons.person, 'Donors', '/donors'),
                _divider(),
                _navItem(context, Icons.search, 'Request Donors', null),
                _divider(),
                _navItem(context, Icons.description, 'Medical Reports', null),
                _divider(),
                _navItem(context, Icons.event, 'Events', null),
                _divider(),
                _navItem(context, Icons.card_giftcard, 'Rewards', null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    String? routeName,
  ) {
    return Expanded(
      child: InkWell(
        onTap: routeName != null
            ? () {
                Navigator.pushNamed(context, routeName);
              }
            : null,
        hoverColor: Colors.grey[200],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 26),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 21, color: Colors.black, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE0E0E0),
    );
  }
}
