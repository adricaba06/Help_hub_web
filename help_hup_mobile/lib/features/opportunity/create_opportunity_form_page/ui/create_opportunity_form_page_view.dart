import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:help_hup_mobile/core/services/opportunity_service.dart';
import 'package:help_hup_mobile/core/services/organization/organization_service.dart';
import 'package:image_picker/image_picker.dart';

class CreateOpportunityFormPageView extends StatefulWidget {
  final int organizationId;

  const CreateOpportunityFormPageView({
    super.key,
    required this.organizationId,
  }) : assert(organizationId > 0, 'organizationId must be greater than 0');

  @override
  State<CreateOpportunityFormPageView> createState() =>
      _CreateOpportunityFormPageViewState();
}

class _CreateOpportunityFormPageViewState
    extends State<CreateOpportunityFormPageView> {
  final _formKey = GlobalKey<FormState>();
  final OpportunityService _opportunityService = OpportunityService();
  final OrganizationService _organizationService = OrganizationService();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOpen = true;
  int _numberOfSeats = 0;
  bool _isSubmitting = false;

  XFile? _opportunityImage;
  Uint8List? _opportunityImagePreview;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickOpportunityImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _opportunityImage = picked;
      _opportunityImagePreview = bytes;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha de inicio y fin')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha fin no puede ser menor que la fecha inicio'),
        ),
      );
      return;
    }

    if (_numberOfSeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El numero de plazas debe ser mayor a 0')),
      );
      return;
    }

    if (_opportunityImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una imagen')),
      );
      return;
    }

    if (widget.organizationId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de organizacion invalido')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final coverFieldId = await _organizationService.uploadImageFile(
        _opportunityImage!.path,
      );

      await _opportunityService.createOpportunity(
        title: _titleController.text.trim(),
        city: _cityController.text.trim(),
        dateFrom: _startDate!,
        dateTo: _endDate!,
        seats: _numberOfSeats,
        status: _isOpen ? 'OPEN' : 'CLOSED',
        orgId: widget.organizationId,
        coverFieldId: coverFieldId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Oportunidad publicada')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final message = _buildErrorMessage(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _buildErrorMessage(Object error) {
    final raw = error.toString();

    if (raw.contains('NO_TOKEN') || raw.contains('UNAUTHORIZED')) {
      return 'Sesion expirada. Inicia sesion de nuevo.';
    }

    final match = RegExp(r'HTTP_(\d+)_(.*)$', dotAll: true).firstMatch(raw);
    if (match == null) {
      return 'No se pudo publicar la oportunidad';
    }

    final statusCode = int.tryParse(match.group(1) ?? '');
    final body = (match.group(2) ?? '').trim();

    if (statusCode == 400) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final detail = decoded['detail']?.toString();
          if (detail != null && detail.isNotEmpty) return detail;
        }
      } catch (_) {}
      return 'Datos invalidos. Revisa titulo (minimo 5), portada y campos obligatorios.';
    }

    if (statusCode == 403) return 'No tienes permisos para crear oportunidades.';
    if (statusCode == 404) return 'Organizacion no encontrada.';

    return 'No se pudo publicar la oportunidad';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Oportunidad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F8F7),
            border: Border(top: BorderSide(color: Color(0xFFECECEC), width: 2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _OpportunityImagePickerCard(
                      imageBytes: _opportunityImagePreview,
                      onTap: _isSubmitting ? null : _pickOpportunityImage,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Imagen de la oportunidad',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Titulo de la Oportunidad',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Acompanamiento a Mayores',
                      hintStyle: const TextStyle(color: Color(0xFF757575)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un titulo';
                      }
                      if (value.trim().length < 5) {
                        return 'El titulo debe tener al menos 5 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ciudad / Ubicacion',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Indique una ciudad',
                      hintStyle: const TextStyle(color: Color(0xFF757575)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa una ciudad';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha Inicio',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  _startDate == null
                                      ? 'mm/dd/yyyy'
                                      : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _startDate == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha Fin',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  _endDate == null
                                      ? 'mm/dd/yyyy'
                                      : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _endDate == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Numero de Plazas',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: '0',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _numberOfSeats = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Switch(
                                  value: _isOpen,
                                  onChanged: (value) {
                                    setState(() => _isOpen = value);
                                  },
                                  activeThumbColor: const Color(0xFF10B77F),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isOpen ? 'Abierta' : 'Cerrada',
                                  style: TextStyle(
                                    color: _isOpen
                                        ? const Color(0xFF10B77F)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(34, 16, 183, 127),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.eco, color: Color(0xFF10B77F), size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Haz que tu impacto crezca',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B77F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitOpportunity,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isSubmitting
                            ? 'Publicando...'
                            : 'Publicar Oportunidad',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B77F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpportunityImagePickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback? onTap;

  const _OpportunityImagePickerCard({
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
          color: const Color(0x0D10B77F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B77F), width: 1.5),
        ),
        child: imageBytes == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF10B77F),
                    size: 36,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Subir imagen',
                    style: TextStyle(
                      color: Color(0xFF10B77F),
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
