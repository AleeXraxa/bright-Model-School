import 'package:flutter/material.dart';

class AccountantDashboardView extends StatelessWidget {
  const AccountantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accountant Dashboard')),
      body: const Center(child: Text('Welcome, Accountant')),
    );
  }
}


