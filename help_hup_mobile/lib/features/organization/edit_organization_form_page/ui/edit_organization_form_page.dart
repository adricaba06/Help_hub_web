import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditOrganizationScreen extends StatefulWidget {
  const EditOrganizationScreen({super.key});

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedCity;
  Uint8List? _logoPreview;
  Uint8List? _coverPreview;
  bool _isSaving = false;

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
      _logoPreview = bytes;
    });
  }

  Future<void> _pickCover() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _coverPreview = bytes;
    });
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Completa el nombre de la organizacion');
      return;
    }
    if ((_selectedCity ?? _cityController.text).trim().isEmpty) {
      _showMessage('Selecciona una ciudad');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Completa la descripcion');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    _showMessage('Cambios guardados (pendiente integrar endpoint de edicion)');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _ImagePickerCard(
                  title: 'Cambiar logo',
                  imageBytes: _logoPreview,
                  onTap: _isSaving ? null : _pickLogo,
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
                onTap: _isSaving ? null : _pickCover,
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Nombre de la organizacion'),
              const SizedBox(height: 8),
              _InputField(
                controller: _nameController,
                hint: 'Ej. Fundacion Ayuda',
                readOnly: _isSaving,
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
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final provincias = snapshot.data!;
                  return Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return const Iterable<String>.empty();
                      return provincias.where(
                        (city) => city.toLowerCase().contains(value.text.toLowerCase()),
                      );
                    },
                    fieldViewBuilder: (context, textController, focusNode, onSubmit) {
                      if (_cityController.text.isNotEmpty && textController.text.isEmpty) {
                        textController.text = _cityController.text;
                      }

                      return TextField(
                        controller: textController,
                        focusNode: focusNode,
                        enabled: !_isSaving,
                        onChanged: (value) {
                          _cityController.text = value;
                          _selectedCity = value;
                        },
                        onSubmitted: (_) => onSubmit(),
                        decoration: _inputDecoration('Ej. Madrid'),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: _EditColors.white,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: _EditColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _EditColors.grayLight),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
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
                        _selectedCity = selection;
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
                hint: 'Cuentanos sobre la mision de la organizacion...',
                enabled: !_isSaving,
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
                    Icon(Icons.info_outline, color: _EditColors.primary, size: 18),
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
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
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
              _isSaving ? 'Guardando...' : 'Guardar cambios',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _EditColors.primary,
              foregroundColor: _EditColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
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
          color: _EditColors.primary05,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _EditColors.primary, width: 1.5),
        ),
        child: imageBytes == null
            ? Column(
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

  const _CoverPickerCard({
    required this.imageBytes,
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
        child: imageBytes == null
            ? const Center(
                child: Text(
                  'Seleccionar imagen de portada',
                  style: TextStyle(
                    color: _EditColors.primary,
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
