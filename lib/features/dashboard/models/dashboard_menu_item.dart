import 'package:flutter/material.dart';

class DashboardMenuItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final String? badge;
  final bool isEnabled;

  const DashboardMenuItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.badge,
    this.isEnabled = true,
  });
}

