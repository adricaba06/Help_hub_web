import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:help_hup_mobile/core/models/organization/edit_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:help_hup_mobile/core/services/storage_service.dart';
import 'package:help_hup_mobile/features/organization/edit_organization_form_page/bloc/edit_organization_form_page_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditOrganizationScreen extends StatefulWidget {
  final Organization organization;

  const EditOrganizationScreen({super.key, required this.organization});

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final OrganizationService _organizationService = OrganizationService();
  List<String> _availableCities = const [];

  String? _currentLogoUrl;
  String? _currentCoverUrl;
  XFile? _logoImage;
  XFile? _coverImage;
  Uint8List? _logoPreview;
  Uint8List? _coverPreview;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.organization.name;
    _descriptionController.text = widget.organization.description ?? '';
    _cityController.text = widget.organization.city;
    _currentLogoUrl = _organizationService.buildImageUrl(
      widget.organization.logoFieldId,
    );
    _currentCoverUrl = _organizationService.buildImageUrl(
      widget.organization.coverFieldId,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
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

  Future<void> _saveChanges(BuildContext blocContext) async {
    final matchedCity = _matchCityFromList(_cityController.text);

    if (_nameController.text.trim().isEmpty) {
      _showMessage('Completa el nombre de la organizacion');
      return;
    }
    if (matchedCity == null) {
      _showMessage('Selecciona una ciudad valida de la lista');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Completa la descripcion');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bloc = blocContext.read<EditOrganizationFormPageBloc>();

    try {
      String? logoFieldId = widget.organization.logoFieldId;
      String? coverFieldId = widget.organization.coverFieldId;

      if (_logoImage != null) {
        logoFieldId = await bloc.organizationService.uploadImageFile(
          _logoImage!.path,
        );
      }
      if (_coverImage != null) {
        coverFieldId = await bloc.organizationService.uploadImageFile(
          _coverImage!.path,
        );
      }

      final request = EditOrganizationRequest(
        name: _nameController.text.trim(),
        city: matchedCity,
        description: _descriptionController.text.trim(),
        logoFieldId: logoFieldId,
        coverFieldId: coverFieldId,
      );

      if (!mounted) return;
      bloc.add(
        SubmitEditOrganization(
          organizationId: widget.organization.id,
          organizationRequest: request,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      _showMessage('Error subiendo imagenes: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditOrganizationFormPageBloc>(
      create: (_) => EditOrganizationFormPageBloc(OrganizationService()),
      child:
          BlocConsumer<
            EditOrganizationFormPageBloc,
            EditOrganizationFormPageState
          >(
            listener: (context, state) {
              if (state is EditOrganizationFormPageLoaded) {
                setState(() {
                  _isSaving = false;
                });
                _showMessage('Organizacion actualizada con exito');
                Navigator.pop(context, true);
              } else if (state is EditOrganizationFormPageError) {
                setState(() {
                  _isSaving = false;
                });
                _showMessage(state.error);
              }
            },
            builder: (context, state) {
              final busy =
                  _isSaving || state is EditOrganizationFormPageLoading;
              return Scaffold(
                backgroundColor: _EditColors.white,
                appBar: AppBar(
                  backgroundColor: _EditColors.white,
                  elevation: 0,
                  centerTitle: true,
                  leading: const BackButton(color: _EditColors.dark),
                  title: const Text(
                    'Editar Organizacion',
                    style: TextStyle(
                      color: _EditColors.dark,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                            title: 'Cambiar logo',
                            imageBytes: _logoPreview,
                            imageUrl: _currentLogoUrl,
                            onTap: busy ? null : _pickLogo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Imagen de perfil',
                            style: TextStyle(
                              color: _EditColors.dark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Imagen de portada'),
                        const SizedBox(height: 8),
                        _CoverPickerCard(
                          imageBytes: _coverPreview,
                          imageUrl: _currentCoverUrl,
                          onTap: busy ? null : _pickCover,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Nombre de la organizacion'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _nameController,
                          hint: 'Ej. Fundacion Ayuda',
                          readOnly: busy,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Ciudad'),
                        const SizedBox(height: 8),
                        FutureBuilder<List<String>>(
                          future: _loadProvincias(),
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
                              optionsBuilder: (value) {
                                if (value.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return provincias.where(
                                  (city) => city.toLowerCase().contains(
                                    value.text.toLowerCase(),
                                  ),
                                );
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textController,
                                    focusNode,
                                    onSubmit,
                                  ) {
                                    if (_cityController.text.isNotEmpty &&
                                        textController.text.isEmpty) {
                                      textController.text =
                                          _cityController.text;
                                    }

                                    return TextField(
                                      controller: textController,
                                      focusNode: focusNode,
                                      enabled: !busy,
                                      onChanged: (value) {
                                        _cityController.text = value;
                                      },
                                      onSubmitted: (_) => onSubmit(),
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
                                        color: _EditColors.white,
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 220,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _EditColors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: _EditColors.grayLight,
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
                              onSelected: (selection) {
                                setState(() {
                                  _cityController.text = selection;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Descripcion'),
                        const SizedBox(height: 8),
                        _TextAreaField(
                          controller: _descriptionController,
                          hint:
                              'Cuentanos sobre la mision de la organizacion...',
                          enabled: !busy,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _EditColors.primary10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _EditColors.primary30),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: _EditColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Edita la informacion visible para voluntarios y colaboradores.',
                                  style: TextStyle(
                                    color: _EditColors.primary,
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
                      onPressed: busy ? null : () => _saveChanges(context),
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _EditColors.white,
                              ),
                            )
                          : const Icon(Icons.save_alt_outlined, size: 20),
                      label: Text(
                        busy ? 'Guardando...' : 'Guardar cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _EditColors.primary,
                        foregroundColor: _EditColors.white,
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

class _EditColors {
  static const Color dark = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF10B77F);
  static const Color grayMid = Color(0xFF9CA3AF);
  static const Color grayLight = Color(0xFFE5E7EB);
  static const Color primary30 = Color(0x4D10B77F);
  static const Color primary10 = Color(0x1A10B77F);
  static const Color primary05 = Color(0x0D10B77F);
}

class _ImagePickerCard extends StatelessWidget {
  final String title;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _ImagePickerCard({
    required this.title,
    required this.imageBytes,
    required this.imageUrl,
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
          color: _EditColors.primary05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _EditColors.primary, width: 1.5),
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              )
            : imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _AuthorizedNetworkImage(
                  url: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: _LogoPlaceholder(title: title),
                ),
              )
            : _LogoPlaceholder(title: title),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final String title;

  const _LogoPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_a_photo_outlined,
          color: _EditColors.primary,
          size: 36,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: _EditColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CoverPickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _CoverPickerCard({
    required this.imageBytes,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: _EditColors.primary05,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _EditColors.primary, width: 1.2),
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              )
            : imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _AuthorizedNetworkImage(
                  url: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: const _CoverPlaceholder(),
                ),
              )
            : const _CoverPlaceholder(),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Seleccionar imagen de portada',
        style: TextStyle(
          color: _EditColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
        color: _EditColors.dark,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

Future<List<String>> _loadProvincias() async {
  final jsonString = await rootBundle.loadString('assets/data/spain.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  return List<String>.from(jsonData['provincias']);
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _EditColors.grayMid, fontSize: 15),
    filled: true,
    fillColor: _EditColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _EditColors.grayLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _EditColors.grayLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _EditColors.primary, width: 1.5),
    ),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;

  const _InputField({
    required this.controller,
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
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  const _TextAreaField({
    required this.controller,
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

class _AuthorizedNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget placeholder;

  const _AuthorizedNetworkImage({
    required this.url,
    required this.fit,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return placeholder;
        }

        return Image.network(
          url,
          fit: fit,
          headers: <String, String>{'Authorization': 'Bearer $token'},
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      },
    );
  }
}
