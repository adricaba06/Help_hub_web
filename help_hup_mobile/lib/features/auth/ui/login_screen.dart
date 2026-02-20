import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:help_hup_mobile/features/register_page/ui/register_page_view.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _green = Color(0xFF10B77F);
  static const _dark = Color(0xFF18181B);
  static const _muted = Color(0xFF52525B);
  static const _label = Color(0xFF3F3F46);
  static const _placeholder = Color(0xFFA1A1AA);
  static const _border = Color(0xFFE4E4E7);
  static const _bg = Color(0xFFFAFAFA);

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  static const _testAccounts = [
    (label: 'Voluntario', email: 'voluntario@helphub.com', password: 'password123', icon: Icons.volunteer_activism),
    (label: 'Manager', email: 'manager@helphub.com', password: 'password123', icon: Icons.business_center),
    (label: 'Admin', email: 'admin@helphub.com', password: 'password123', icon: Icons.admin_panel_settings),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context
        .read<AuthProvider>()
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  void _fillTestAccount(String email, String password) {
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            left: -71,
            top: -99,
            child: Opacity(
              opacity: 0.20,
              child: Container(
                width: 500,
                height: 500,
                decoration: const ShapeDecoration(
                  color: Color(0x4C10B77F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -39,
            bottom: -100,
            child: Opacity(
              opacity: 0.20,
              child: Container(
                width: 500,
                height: 500,
                decoration: const ShapeDecoration(
                  color: Color(0x3310B77F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 10,
                          offset: Offset(0, 8),
                          spreadRadius: -6,
                        ),
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 25,
                          offset: Offset(0, 20),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          _buildHeroSection(),
                          _buildFormSection(isLoading, auth),
                          _buildTestAccountsSection(isLoading),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF4F4F5))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
              onPressed: () {},
            ),
          ),
          Expanded(
            child: Text(
              'HelpHub',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _dark,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.45,
              ),
            ),
          ),
          const SizedBox(width: 40), // balance
        ],
      ),
    );
  }

  // ── Hero (green banner) ─────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Column(
      children: [
        // Green banner with bubbles
        Container(
          margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          height: 164,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0x1910B77F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Stack(
            children: [
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(0.26, -0.26),
                      end: const Alignment(0.74, 1.26),
                      colors: [
                        const Color(0xFF10B77F).withValues(alpha: 0.2),
                        const Color(0xFF10B77F).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Bubble top-left
              Positioned(
                left: -16,
                top: -16,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const ShapeDecoration(
                    color: Color(0x3310B77F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9999)),
                    ),
                  ),
                ),
              ),
              // Bubble bottom-right
              Positioned(
                right: -16,
                bottom: -16,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const ShapeDecoration(
                    color: Color(0x3310B77F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9999)),
                    ),
                  ),
                ),
              ),
              // Icon
              const Center(
                child: Icon(
                  Icons.volunteer_activism,
                  size: 64,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
        // Title
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            '¡Bienvenido de\nnuevo!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
        // Subtitle
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'Tu ayuda importa: entra para seguir\nmarcando la diferencia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
        ),
      ],
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────────
  Widget _buildFormSection(bool isLoading, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          const Text(
            'Correo electrónico',
            style: TextStyle(
              color: _label,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            decoration: _inputDecoration(
              hintText: 'ejemplo@helphub.com',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce tu correo';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contraseña',
                style: TextStyle(
                  color: _label,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.43,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: _green,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePassword,
            enabled: !isLoading,
            decoration: _inputDecoration(
              hintText: '••••••••',
              prefixIcon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: _placeholder,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Introduce tu contraseña';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Error banner
          if (auth.status == AuthStatus.error && auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: auth.clearError,
                    child: const Icon(Icons.close, color: Color(0xFFDC2626), size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Login button
          ElevatedButton(
            onPressed: isLoading ? null : () => _submit(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: _green.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: _green.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Test accounts ────────────────────────────────────────────────────────────
  Widget _buildTestAccountsSection(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x7FFAFAFA),
        border: Border.symmetric(
          horizontal: const BorderSide(color: Color(0xFFF4F4F5)),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'CUENTAS DE PRUEBA',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.20,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _testAccounts
                .map((acc) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: acc == _testAccounts.first ? 0 : 6,
                          right: acc == _testAccounts.last ? 0 : 6,
                        ),
                        child: _TestAccountButton(
                          label: acc.label,
                          icon: acc.icon,
                          isLoading: isLoading,
                          onTap: () {
                            _fillTestAccount(acc.email, acc.password);
                            Future.microtask(() => _submit());
                          },
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF4F4F5))),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '¿No tienes una cuenta? ',
              style: TextStyle(
                color: _muted,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'Registrarse',
              style: TextStyle(
                color: _green,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()
              ..onTap = (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPageView()));
              }
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _placeholder, fontFamily: 'Inter'),
      filled: true,
      fillColor: _bg,
      prefixIcon: Icon(prefixIcon, color: _placeholder, size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
    );
  }
}

// ── Test Account Button ───────────────────────────────────────────────────────
class _TestAccountButton extends StatelessWidget {
  const _TestAccountButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE4E4E7)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF52525B)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F3F46),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
