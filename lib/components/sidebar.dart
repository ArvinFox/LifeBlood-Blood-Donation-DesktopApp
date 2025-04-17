import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _navItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),
          _navItem(context, Icons.person, 'Donors', '/donors'),
          _navItem(context, Icons.search, 'Request Donors', null),
          _navItem(context, Icons.description, 'Medical Reports', null),
          _navItem(context, Icons.event, 'Events', null),
          _navItem(context, Icons.card_giftcard, 'Rewards', null),
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
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label),
      onTap: routeName != null
          ? () {
              Navigator.pushNamed(context, routeName);
            }
          : null,
    );
  }
}
