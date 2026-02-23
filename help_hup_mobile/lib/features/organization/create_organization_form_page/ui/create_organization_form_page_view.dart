import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/features/organization/create_organization_form_page/bloc/create_organization_form_page_bloc.dart';
import 'package:help_hup_mobile/features/organization/organization_list/ui/organization_list_manager_view.dart';
import 'package:image_picker/image_picker.dart';

class AppColors {
  static const Color dark = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF10B77F);
  static const Color grayMid = Color(0xFF9CA3AF);
  static const Color grayLight = Color(0xFFE5E7EB);
  static const Color primary30 = Color(0x4D10B77F);
  static const Color primary10 = Color(0x1A10B77F);
  static const Color primary05 = Color(0x0D10B77F);
}

class CrearOrganizacionScreen extends StatefulWidget {
  const CrearOrganizacionScreen({super.key});

  @override
  State<CrearOrganizacionScreen> createState() =>
      _CrearOrganizacionScreenState();
}

class _CrearOrganizacionScreenState extends State<CrearOrganizacionScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _availableCities = const [];

  String? selectedCity;
  XFile? _logoImage;
  XFile? _coverImage;
  Uint8List? _logoPreview;
  Uint8List? _coverPreview;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  String? _matchCityFromList(String value) {
    final input = value.trim().toLowerCase();
    if (input.isEmpty) return null;
    for (final city in _availableCities) {
      if (city.toLowerCase() == input) {
        return city;
      }
    }
    return null;
  }

  Future<void> _pickLogo() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _logoImage = picked;
      _logoPreview = bytes;
    });
  }

  Future<void> _pickCover() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _coverImage = picked;
      _coverPreview = bytes;
    });
  }

  Future<void> _submit(BuildContext blocContext) async {
    final matchedCity = _matchCityFromList(_ciudadController.text);
    if (_nombreController.text.trim().isEmpty || matchedCity == null) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre y selecciona una ciudad de la lista'),
        ),
      );
      return;
    }
    if (_descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        blocContext,
      ).showSnackBar(const SnackBar(content: Text('Completa la descripcion')));
      return;
    }
    if (_logoImage == null || _coverImage == null) {
      ScaffoldMessenger.of(blocContext).showSnackBar(
        const SnackBar(content: Text('Sube logo y portada obligatoriamente')),
      );
      return;
    }

    final bloc = blocContext.read<CreateOrganizationFormPageBloc>();
    String? logoFieldId;
    String? coverFieldId;

    setState(() {
      _isSubmitting = true;
    });

    try {
      logoFieldId = await bloc.organizationService.uploadImageFile(
        _logoImage!.path,
      );
      coverFieldId = await bloc.organizationService.uploadImageFile(
        _coverImage!.path,
      );

      final request = CreateOrganizationRequest(
        name: _nombreController.text.trim(),
        city: matchedCity,
        logoFieldId: logoFieldId,
        coverFieldId: coverFieldId,
        description: _descripcionController.text.trim(),
      );

      bloc.add(SubmitCreateOrganization(organizationRequest: request));
    } catch (e) {
      if (!mounted || !blocContext.mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(
        blocContext,
      ).showSnackBar(SnackBar(content: Text('Error subiendo imagenes: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateOrganizationFormPageBloc>(
      create: (_) => CreateOrganizationFormPageBloc(OrganizationService()),
      child:
          BlocConsumer<
            CreateOrganizationFormPageBloc,
            CreateOrganizationFormPageState
          >(
            listener: (context, state) {
              if (state is CreateOrganizationFormPageLoaded) {
                setState(() {
                  _isSubmitting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organizacion creada con exito'),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrganizationListManagerView(),
                  ),
                );
              } else if (state is CreateOrganizationFormPageError) {
                setState(() {
                  _isSubmitting = false;
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
            builder: (context, state) {
              final busy =
                  _isSubmitting || state is CreateOrganizationFormPageLoading;

              return Scaffold(
                backgroundColor: AppColors.white,
                appBar: AppBar(
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  leading: const BackButton(color: AppColors.dark),
                  title: const Text(
                    'Crear Organizacion',
                    style: TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  centerTitle: true,
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: _ImagePickerCard(
                            title: 'Subir logo',
                            imageBytes: _logoPreview,
                            onTap: busy ? null : _pickLogo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Imagen de perfil',
                            style: TextStyle(
                              color: AppColors.dark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Imagen de cover'),
                        const SizedBox(height: 8),
                        _CoverPickerCard(
                          imageBytes: _coverPreview,
                          onTap: busy ? null : _pickCover,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Nombre de la organizacion'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _nombreController,
                          hint: 'Ej. Fundacion Ayuda',
                          readOnly: busy,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Ciudad'),
                        const SizedBox(height: 8),
                        FutureBuilder<List<String>>(
                          future: cargarProvincias(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final provincias = snapshot.data!;
                            _availableCities = provincias;
                            return Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return provincias.where(
                                      (provincia) =>
                                          provincia.toLowerCase().contains(
                                            textEditingValue.text.toLowerCase(),
                                          ),
                                    );
                                  },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    if (_ciudadController.text.isNotEmpty &&
                                        textController.text !=
                                            _ciudadController.text) {
                                      textController.text =
                                          _ciudadController.text;
                                    }
                                    return TextField(
                                      controller: textController,
                                      focusNode: focusNode,
                                      enabled: !busy,
                                      onChanged: (value) {
                                        _ciudadController.text = value;
                                        selectedCity = _matchCityFromList(
                                          value,
                                        );
                                      },
                                      onSubmitted: (_) => onFieldSubmitted(),
                                      decoration: _inputDecoration(
                                        'Ej. Madrid',
                                      ),
                                    );
                                  },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        color: AppColors.white,
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 220,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.grayLight,
                                            ),
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options.elementAt(
                                                index,
                                              );
                                              return InkWell(
                                                onTap: () => onSelected(option),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                  child: Text(option),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                              onSelected: (String selection) {
                                setState(() {
                                  selectedCity = selection;
                                  _ciudadController.text = selection;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Descripcion'),
                        const SizedBox(height: 8),
                        _TextAreaField(
                          controller: _descripcionController,
                          hint:
                              'Cuentanos sobre la mision de la organizacion...',
                          enabled: !busy,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary30),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Esta informacion sera publica y ayudara a los voluntarios a conocer mejor vuestra labor.',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : () => _submit(context),
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.save_alt_outlined, size: 20),
                      label: Text(
                        busy ? 'Guardando...' : 'Guardar Organizacion',
                        style: const TextStyle(
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

class _ImagePickerCard extends StatelessWidget {
  final String title;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;

  const _ImagePickerCard({
    required this.title,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.primary05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}

class _CoverPickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback? onTap;

  const _CoverPickerCard({required this.imageBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.primary05,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: imageBytes == null
            ? const Center(
                child: Text(
                  'Seleccionar imagen de portada',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}

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

Future<List<String>> cargarProvincias() async {
  final String jsonString = await rootBundle.loadString(
    'assets/data/spain.json',
  );
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  return List<String>.from(jsonData['provincias']);
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.grayMid, fontSize: 15),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool readOnly;

  const _InputField({
    this.controller,
    required this.hint,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: _inputDecoration(hint),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool enabled;

  const _TextAreaField({
    this.controller,
    required this.hint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      enabled: enabled,
      decoration: _inputDecoration(hint),
    );
  }
}
