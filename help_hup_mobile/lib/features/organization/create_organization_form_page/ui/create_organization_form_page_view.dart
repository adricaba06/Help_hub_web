import 'package:flutter/material.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/features/organization/create_organization_form_page/bloc/create_organization_form_page_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';

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
      child: BlocConsumer<CreateOrganizationFormPageBloc, CreateOrganizationFormPageState>(
        listener: (context, state) {
          if (state is CreateOrganizationFormPageLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se ha creado la organización con exito'),
              ),
            );
          } else if (state is CreateOrganizationFormPageError) {
            debugPrint('CreateOrganizationFormPageError: ${state.error}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: const BackButton(color: AppColors.dark),
              title: const Text(
                'Crear Organización',
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Logo Upload ──────────────────────────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                // TODO: pick image
                              },
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: AppColors.primary05,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Subir logo',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Imagen de marca',
                              style: TextStyle(
                                color: AppColors.dark,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Center(
                            child: Text(
                              'PNG, JPG o GIF. Máx. 2MB',
                              style: TextStyle(
                                color: AppColors.grayMid,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          //  Nombre ───────────────────────────────────────────────
                          const _FieldLabel('Nombre de la organización'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _nombreController,
                            hint: 'Ej. Fundación Ayuda',
                            readOnly: false,
                          ),

                          const SizedBox(height: 20),

                          // Ciudad ───────────────────────────────────────────────
                          const _FieldLabel('Ciudad'),
                          const SizedBox(height: 8),

                          DropdownButtonFormField<String>(
                            value: selectedCity,
                            decoration: InputDecoration(
                              labelText: 'Ciudad',
                              labelStyle: const TextStyle(
                                color: AppColors.grayMid,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.grayLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.grayLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.location_city,
                                color: AppColors.grayMid,
                                size: 20,
                              ),
                            ),
                            dropdownColor: AppColors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.grayMid,
                            ),
                            style: const TextStyle(
                              color: AppColors.dark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            items: spanishCities
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // ── Descripción ──────────────────────────────────────────
                          const _FieldLabel('Descripción'),
                          const SizedBox(height: 8),
                          _TextAreaField(
                            controller: _descripcionController,
                            hint:
                                'Cuéntanos sobre la misión de la organización...',
                          ),

                          const SizedBox(height: 20),

                          // ── Info Banner ──────────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary10,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary30),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Esta información será pública y ayudará a los voluntarios a conocer mejor vuestra labor social.',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 100,
                          ), // space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Guardar button ─────────────────────────────────────────────────────
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_nombreController.text.isEmpty ||
                        selectedCity == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('INVALIDO')));
                      return;
                    }

                    //ahora creo un dto que le voy a pasar al .add que recibe un evento

                    final request = CreateOrganizationRequest(
                      name: _nombreController.text,
                      city: selectedCity!,
                      logoFieldId: 1,
                    );

                    context.read<CreateOrganizationFormPageBloc>().add(
                      SubmitCreateOrganization(organizationRequest: request),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const OrganizationListManagerView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_alt_outlined, size: 20),
                  label: const Text(
                    'Guardar Organización',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
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
