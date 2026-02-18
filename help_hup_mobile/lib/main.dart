import 'package:flutter/material.dart';
import 'package:help_hup_mobile/features/opportunity/create_opportunity_form_page/ui/create_opportunity_form_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B77F)),
      ),
      debugShowCheckedModeBanner: false,
      home: const CreateOpportunityFormPageView(),
    );
  }
}