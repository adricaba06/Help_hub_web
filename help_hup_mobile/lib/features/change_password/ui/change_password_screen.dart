import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/profile_service.dart';
import '../bloc/change_password_bloc.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePasswordBloc(ProfileService()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  static const _green = Color(0xFF10B77F);
  static const _dark = Color(0xFF18181B);
  static const _muted = Color(0xFF52525B);
  static const _border = Color(0xFFE4E4E7);
  static const _inputBg = Color(0xFFFAFAFA);
  static const _placeholder = Color(0xFFA1A1AA);

  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ChangePasswordBloc>().add(
          ChangePasswordSubmitted(
            oldPassword: _oldPasswordCtrl.text,
            newPassword: _newPasswordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrasena actualizada correctamente.'),
              backgroundColor: _green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is ChangePasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFB42318),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F7),
          body: Stack(
            children: [
              Positioned(
                left: -70,
                top: -90,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    width: 420,
                    height: 420,
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
                right: -60,
                bottom: -120,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    width: 420,
                    height: 420,
                    decoration: const ShapeDecoration(
                      color: Color(0x3310B77F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9999)),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(context),
                              _buildHero(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildLabel('Contrasena actual'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _oldPasswordCtrl,
                                      obscureText: _obscureOld,
                                      enabled: !isLoading,
                                      decoration: _inputDecoration(
                                        hintText: 'Introduce tu contrasena actual',
                                        prefixIcon: Icons.lock_outline,
                                        onToggleVisibility: () {
                                          setState(() => _obscureOld = !_obscureOld);
                                        },
                                        obscure: _obscureOld,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Introduce tu contrasena actual';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('Nueva contrasena'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _newPasswordCtrl,
                                      obscureText: _obscureNew,
                                      enabled: !isLoading,
                                      decoration: _inputDecoration(
                                        hintText: 'Minimo 8 caracteres',
                                        prefixIcon: Icons.lock_reset_outlined,
                                        onToggleVisibility: () {
                                          setState(() => _obscureNew = !_obscureNew);
                                        },
                                        obscure: _obscureNew,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Introduce una nueva contrasena';
                                        }
                                        if (value.length < 8) {
                                          return 'Debe tener al menos 8 caracteres';
                                        }
                                        if (value == _oldPasswordCtrl.text) {
                                          return 'La nueva contrasena debe ser diferente';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLabel('Confirmar nueva contrasena'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _confirmPasswordCtrl,
                                      obscureText: _obscureConfirm,
                                      enabled: !isLoading,
                                      decoration: _inputDecoration(
                                        hintText: 'Repite la nueva contrasena',
                                        prefixIcon: Icons.verified_user_outlined,
                                        onToggleVisibility: () {
                                          setState(
                                            () => _obscureConfirm = !_obscureConfirm,
                                          );
                                        },
                                        obscure: _obscureConfirm,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirma tu nueva contrasena';
                                        }
                                        if (value != _newPasswordCtrl.text) {
                                          return 'Las contrasenas no coinciden';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _green,
                                        disabledBackgroundColor:
                                            _green.withValues(alpha: 0.6),
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: _green.withValues(alpha: 0.4),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Actualizar contrasena',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Expanded(
            child: Text(
              'Cambiar contrasena',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _dark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.45,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          height: 120,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0x1910B77F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(0.2, -0.2),
                      end: const Alignment(0.8, 1.2),
                      colors: [
                        const Color(0xFF10B77F).withValues(alpha: 0.25),
                        const Color(0xFF10B77F).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 48,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 18, 24, 8),
          child: Text(
            'Actualiza tu contrasena',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Text(
            'Introduce tu contrasena actual y define una nueva segura.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF3F3F46),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool obscure,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _placeholder),
      filled: true,
      fillColor: _inputBg,
      prefixIcon: Icon(prefixIcon, color: _placeholder, size: 20),
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _placeholder,
          size: 20,
        ),
      ),
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
    );
  }
}
