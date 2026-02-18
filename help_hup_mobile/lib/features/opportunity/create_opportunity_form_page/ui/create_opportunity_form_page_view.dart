import 'package:flutter/material.dart';

class CreateOpportunityFormPageView extends StatefulWidget {
  const CreateOpportunityFormPageView({super.key});

  @override
  State<CreateOpportunityFormPageView> createState() => _CreateOpportunityFormPageViewState();
}

class _CreateOpportunityFormPageViewState extends State<CreateOpportunityFormPageView> {
    final _formKey = GlobalKey<FormState>();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOpen = true;
  int _numberOfSeats = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nueva Oportunidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        
      ),
      body: SingleChildScrollView(
        child: Container(
          
          decoration: BoxDecoration(color: const Color(0xFFF6F8F7), border: Border(top: BorderSide(color: const Color(0xFFECECEC),width: 2))),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        
                children: [
                  // Título de la Oportunidad
                  Text(
                    'Título de la Oportunidad',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Acompañamiento a Mayores',
                      hintStyle: TextStyle(color: const Color(0xFF757575)),
                      enabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
        
                      ),
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
        
                      ),
                      
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un título';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
        
                  // Descripción
                  Text(
                    'Descripción',
                    style: TextStyle(
                      
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe las tareas y requisitos del puesto de voluntariado...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      enabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
        
                      ),
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: const Color(0xFFE0E0E0)!),
        
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una descripción';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
        
                  // Ciudad / Ubicación
                  Text(
                    'Ciudad / Ubicación',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Indique una ciudad',
                      hintStyle: TextStyle(color: const Color(0xFF757575)),
                      enabledBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
        
                      ),
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
        
                      ),
                      
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una ciudad';
                      }
                      return null;
                    },
                  ),
                   
                  SizedBox(height: 24),
        
                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha Inicio',
                              style: TextStyle(
                                fontSize: 15,
                      fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Text(
                                  _startDate == null
                                      ? 'mm/dd/yyyy'
                                      : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _startDate == null ? Colors.grey[600] : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha Fin',
                              style: TextStyle(
                                fontSize: 15,
                      fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Text(
                                  
                                  _endDate == null
                                      ? 'mm/dd/yyyy'
                                      : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _endDate == null ? Colors.grey[600] : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
        
                  // Número de Plazas y Estado
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número de Plazas',
                              style: TextStyle(
                                fontSize: 15,
                      fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              initialValue: '0',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                enabledBorder:OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                border:OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              onChanged: (value) {
                                setState(() => _numberOfSeats = int.tryParse(value) ?? 0);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado',
                              style: TextStyle(
                                fontSize: 15,
                      fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Switch(
                                  value: _isOpen,
                                  onChanged: (value) {
                                    setState(() => _isOpen = value);
                                  },
                                  activeThumbColor : Color(0xFF10B77F),
                                  
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _isOpen ? 'Abierta' : 'Cerrada',
                                  style: TextStyle(
                                    color: _isOpen ? Color(0xFF10B77F) : Colors.grey,
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
                  SizedBox(height: 24),
        
                  // Mensaje
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(34, 16, 183, 127),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: Color(0xFF10B77F), size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Haz que tu impacto crezca',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B77F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
        
                  // Botón Publicar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Aquí va la lógica para publicar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Oportunidad publicada')),
                          );
                        }
                      },
                      icon: Icon(Icons.arrow_forward_ios_outlined, fontWeight: FontWeight.w700,color: Colors.white),
                      label: Text('Publicar Oportunidad', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B77F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  }


