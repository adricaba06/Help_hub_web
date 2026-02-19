import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/services/UserService.dart';
import 'package:help_hup_mobile/features/register_page/bloc/register_page_bloc.dart';
import 'package:help_hup_mobile/features/register_page/ui/register_page_view.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B77F)),
      ),
      home: BlocProvider(
        create: (_) => RegisterPageBloc(userService: Userservice()),
        child: const RegisterPageView(),
      ),
    );
  }
}
