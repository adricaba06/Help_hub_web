import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _green = Color(0xFF10B77F);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'HelpHub',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF52525B)),
            tooltip: 'Cerrar sesión',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 96,
                height: 96,
                decoration: ShapeDecoration(
                  color: _green.withValues(alpha: 0.1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                ),
                child: const Icon(Icons.check_circle_outline, color: _green, size: 52),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Sesión iniciada!',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido de nuevo, ${user?.displayName ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF52525B),
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              if (user != null) ...[
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: ShapeDecoration(
                    color: _green.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: _green.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Text(
                    user.role,
                    style: const TextStyle(
                      color: _green,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
              const SizedBox(height: 40),
              // Placeholder for future screens
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.construction, color: Color(0xFFA1A1AA), size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Próximamente: Explorar oportunidades,\nMis solicitudes y Favoritos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
