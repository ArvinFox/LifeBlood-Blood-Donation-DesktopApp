import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Material(
      elevation: 6,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        width: 260,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _navItem(
                    context,
                    Icons.dashboard,
                    'Dashboard',
                    '/dashboard',
                    currentRoute,
                  ),
                  _divider(),
                  _navItem(
                    context,
                    Icons.person,
                    'Donors',
                    '/donors',
                    currentRoute,
                  ),
                  _divider(),
                  _navItem(
                    context,
                    Icons.search,
                    'Request Donors',
                    '/request-donors',
                    currentRoute,
                  ),
                  _divider(),
                  _navItem(
                    context,
                    Icons.description,
                    'Medical Reports',
                    '/medical-reports',
                    currentRoute,
                  ),
                  _divider(),
                  _navItem(
                    context,
                    Icons.event,
                    'Events',
                    '/events',
                    currentRoute,
                  ),
                  _divider(),
                  _navItem(
                    context,
                    Icons.card_giftcard,
                    'Rewards',
                    '/rewards',
                    currentRoute,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    String routeName,
    String? currentRoute,
  ) {
    final bool active = currentRoute == routeName;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!active) {
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
        hoverColor: Colors.grey[100],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border:
                active
                    ? const Border(
                      left: BorderSide(color: Colors.red, width: 4),
                    )
                    : null,
            color: active ? Colors.red.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueGrey, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  }
}
