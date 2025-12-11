import 'package:flutter/material.dart';

import '../admin_home/presentation/admin_employee_request_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return const AdminEmployeeRequestScreen();
  }
}