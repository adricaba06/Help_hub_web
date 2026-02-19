import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_hup_mobile/features/register_page/bloc/register_page_bloc.dart';

class RegisterPageView extends StatefulWidget {
  const RegisterPageView({super.key});

  @override
  State<RegisterPageView> createState() => _RegisterPageViewState();
}

class _RegisterPageViewState extends State<RegisterPageView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _selectedRole = 'user_normal';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  String _roleForApi() {
    if (_selectedRole == 'manager') return 'MANAGER';
    return 'USER';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contrasenas no coinciden')),
      );
      return;
    }

    context.read<RegisterPageBloc>().add(
      RegisterSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
        role: _roleForApi(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterPageBloc, RegisterPageState>(
      listener: (context, state) {
        if (state is RegisterPageError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        //Esto lo muestro aqui hasta que lo una con el login y me inicie la sesión directamente.
        if (state is RegisterPageSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar( SnackBar(content: Text('Registro exitoso')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Registrarse',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          backgroundColor: const Color(0x2418C289),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: Color(0x2418C289)),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(text: 'Únete a '),
                                    TextSpan(
                                      text: 'HelpHub',
                                      style: TextStyle(
                                        color: Color(0xFF2FBC6F),
                                        
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                      
                      SizedBox(height: 7),
                      Text(
                        'Crea tu cuenta para empezar a marcar la diferencia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Container(
                color: const Color(0xFFF6F8F7),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          '¿Cómo quieres participar?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedRole = 'user_normal');
                            },

                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedRole == 'user_normal'
                                      ? Color(0xFF2FBC6F)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _selectedRole == 'user_normal'
                                    ? Color(0xFFE0F7F5)
                                    : Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: _selectedRole == 'user_normal'
                                          ? Color(0xFF2FBC6F)
                                          : Colors.black,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Voluntario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'user_normal'
                                          ? Color(0xFF2FBC6F)
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Quiero ayudar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedRole = 'manager');
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedRole == 'manager'
                                      ? Color(0xFF2FBC6F)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _selectedRole == 'manager'
                                    ? Color(0xFFE0F7F5)
                                    : Colors.white,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: _selectedRole == 'manager'
                                          ? Color(0xFF2FBC6F)
                                          : Colors.black,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Manager',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'manager'
                                          ? Color(0xFF2FBC6F)
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Gestiono una ONG',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                          
                        SizedBox(height: 15),
                        Text(
                          'Nombre completo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Pepe Lobato',
                            prefixIcon:  Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
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
                              return 'Por favor ingresa tu nombre';
                            }
                            if (value.trim().split(' ').length < 2) {
                              return 'Por favor ingresa tu nombre completo';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Correo electrónico',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'tu@email.com',
                            prefixIcon:  Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
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
                              return 'Por favor ingresa tu email';
                            }
                            if (!_isValidEmail(value.trim())) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: '********',
                            prefixIcon:  Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
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
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 7) {
                              return 'Debe tener al menos 7 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Confirmar contraseña',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirmPassword,
                          decoration: InputDecoration(
                            hintText: '********',
                            prefixIcon:  Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showConfirmPassword =
                                      !_showConfirmPassword,
                                );
                              },
                            ),
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
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 25),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<RegisterPageBloc, RegisterPageState>(
                    builder: (context, state) {
                      final loading = state is RegisterPageLoading;
                      return ElevatedButton.icon(
                        onPressed: loading ? null : _submit,
                        icon: loading
                            ?  SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            :  Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: Colors.white,
                              ),
                        label: Text(
                          loading ? 'Registrando...' : 'Registrarse',
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xFF10B77F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[700]),
                    children:  [
                      TextSpan(text: '¿Ya tienes una cuenta? '),
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: TextStyle(
                          color: Color(0xFF2FBC6F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}