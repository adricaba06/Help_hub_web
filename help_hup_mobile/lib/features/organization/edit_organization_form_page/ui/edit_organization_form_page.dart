import 'package:flutter/material.dart';

class EditOrganizationScreen extends StatelessWidget {
  const EditOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(child: _Content()),
            _SaveButton(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: const Text(
        "Editar Organización",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(),
        const SizedBox(height: 24),
        _InfoBox(),
        const SizedBox(height: 24),
        _TextField(label: "Nombre de la organización", hint: "Ej. Fundación Ayuda"),
        const SizedBox(height: 24),
        _TextField(label: "Ciudad", hint: "Ej. Sevilla"),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Imagen de portada
        SizedBox(
          width: double.infinity,
          height: 150,
          child: Stack(
            children: [
              Opacity(
                opacity: 0.2,
                child: Image.network(
                  "https://placehold.co/390x131",
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x1910B77F),
                  border: Border.all(color: const Color(0x4C10B77F), width: 2),
                ),
              ),
            ],
          ),
        ),

        // Avatar
        Positioned(
          left: 24,
          bottom: -40,
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 4, color: Colors.white),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Center(
              child: Text(
                "IMAGEN DE PERFIL",
                style: TextStyle(
                  color: Color(0xFF10B77F),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1910B77F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x3310B77F)),
      ),
      child: const Text(
        "Esta información será pública y ayudará a los voluntarios a conocer mejor vuestra labor.",
        style: TextStyle(
          color: Color(0xFF334155),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;

  const _TextField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              hint,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF10B77F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3310B77F),
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Guardar Cambios",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
