import 'package:flutter/material.dart';
import 'package:help_hup_mobile/features/opportunity/create_opportunity_form_page/ui/create_opportunity_form_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color(0xFF10B77F)),
      ),
      home: CreateOpportunityFormPageView(),
    );
  }
}
