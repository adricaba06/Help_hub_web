import 'package:flutter/material.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/features/organization/create_organization_form_page/bloc/create_organization_form_page_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppColors {
  static const Color dark = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF10B77F);
  static const Color grayMid = Color(0xFF9CA3AF);
  static const Color grayLight = Color(0xFFE5E7EB);
  static const Color grayBg = Color(0xFFF3F4F6);
  static const Color primary30 = Color(0x4D10B77F); // 30%
  static const Color primary10 = Color(0x1A10B77F); // 10%
  static const Color primary05 = Color(0x0D10B77F); // 5%
  static const Color grayMid2 = Color(0xFF6B7280);
  static const Color grayLighter = Color(0xFFF6F8F7);
}

class CrearOrganizacionScreen extends StatefulWidget {
  const CrearOrganizacionScreen({super.key});

  @override
  State<CrearOrganizacionScreen> createState() =>
      _CrearOrganizacionScreenState();
}

const List<String> spanishCities = [
  "Madrid",
  "Barcelona",
  "Valencia",
  "Sevilla",
  "Zaragoza",
  "Málaga",
  "Murcia",
  "Palma de Mallorca",
  "Las Palmas de Gran Canaria",
  "Bilbao",
  "Alicante",
  "Córdoba",
  "Valladolid",
  "Vigo",
  "Gijón",
  "L'Hospitalet de Llobregat",
  "La Coruña",
  "Granada",
  "Elche",
  "Oviedo",
  "Santa Cruz de Tenerife",
  "Badalona",
  "Cartagena",
  "Terrassa",
  "Jerez de la Frontera",
  "Sabadell",
  "Móstoles",
  "Alcalá de Henares",
  "Pamplona",
  "Fuenlabrada",
  "Almería",
  "Leganés",
  "San Sebastián",
  "Getafe",
  "Burgos",
  "Santander",
  "Albacete",
  "Castellón de la Plana",
  "Logroño",
  "Badajoz",
  "Salamanca",
  "Huelva",
  "Lleida",
  "Marbella",
  "Tarragona",
  "León",
  "Cádiz",
  "Ourense",
  "Girona",
  "Mérida",
  "Manresa",
  "Reus",
  "Torrevieja",
];

class _CrearOrganizacionScreenState extends State<CrearOrganizacionScreen> {
  late CreateOrganizationFormPageBloc createOrganizationFormPageBloc;
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? selectedCity;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return BlocProvider<CreateOrganizationFormPageBloc>(
    create: (_) => CreateOrganizationFormPageBloc(OrganizationService()),
    child: BlocConsumer<CreateOrganizationFormPageBloc,
        CreateOrganizationFormPageState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Crear Organización')),
          body: Center(child: Text('Formulario aquí')),
        );
      },
    ),
  );
}
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.dark,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const _InputField({
    this.controller,
    required this.hint,
    this.prefixIcon,
    required this.readOnly,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: AppColors.dark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grayMid, fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.grayMid, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;

  const _TextAreaField({this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      style: const TextStyle(color: AppColors.dark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grayMid, fontSize: 15),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Entry point (for testing standalone) ────────────────────────────────────
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrearOrganizacionScreen(),
    ),
  );
}

