import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class RegistroScreen2 extends StatefulWidget {
  final String nombres;
  final String apellidos;
  final String celular;
  final String nombreNegocio;
  final String ruc;

  const RegistroScreen2({
    super.key,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    required this.nombreNegocio,
    required this.ruc,
  });

  @override
  State<RegistroScreen2> createState() => _RegistroScreen2State();
}

class _RegistroScreen2State extends State<RegistroScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      _showErrorDialog('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.registro(
      nombres: widget.nombres,
      apellidos: widget.apellidos,
      correo: _correoController.text.trim(),
      celular: widget.celular,
      contrasena: _contrasenaController.text,
      ruc: widget.ruc,
      nombreTienda: widget.nombreNegocio,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Registro exitoso!'),
        content: const Text('Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text('Ir a iniciar sesión'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                _buildHeader(),

                const SizedBox(height: 32),

                const Text(
                  'Para iniciar sesión debe registrarse con un correo ya existente',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // Campo de correo
                _buildEmailField(),

                const SizedBox(height: 16),

                // Campo de contraseña
                _buildPasswordField(),

                const SizedBox(height: 16),

                // Campo de confirmar contraseña
                _buildConfirmPasswordField(),

                const SizedBox(height: 32),

                // Botón de registrarse
                _buildRegisterButton(),

                const SizedBox(height: 16),

                // Botón volver
                _buildBackButton(),

                const SizedBox(height: 24),

                // Link para iniciar sesión
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Micro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontFamily: 'Poppins',
              ),
            ),
            TextSpan(
              text: 'Guard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _correoController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo Electronico',
        hintText: 'example@gmail.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su correo';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingrese un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _contrasenaController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '•••••••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmarContrasenaController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirmar Contraseña',
        hintText: '•••••••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirme su contraseña';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegistro,
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : const Text('Registrarse'),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Volver',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Si tienes una cuenta. ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text(
              'Inicie aquí',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}