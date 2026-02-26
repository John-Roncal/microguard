import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class RecuperarContrasenaScreen2 extends StatefulWidget {
  final String correo;

  const RecuperarContrasenaScreen2({
    super.key,
    required this.correo,
  });

  @override
  State<RecuperarContrasenaScreen2> createState() => _RecuperarContrasenaScreen2State();
}

class _RecuperarContrasenaScreen2State extends State<RecuperarContrasenaScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _nuevaContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleRestablecer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.restablecerContrasena(
      widget.correo,
      _codigoController.text.trim(),
      _nuevaContrasenaController.text,
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
        title: const Text('¡Contraseña restablecida!'),
        content: const Text('Tu contraseña ha sido actualizada correctamente. Ahora puedes iniciar sesión.'),
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
                const SizedBox(height: 40),

                // Título
                const Text(
                  'Recuperación de cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción con email
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      const TextSpan(text: 'Ingresa el '),
                      const TextSpan(
                        text: 'código',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' que te enviamos a tu correo: '),
                      TextSpan(
                        text: widget.correo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Campo de código
                _buildCodigoField(),

                const SizedBox(height: 16),

                // Campo de nueva contraseña
                _buildNuevaContrasenaField(),

                const SizedBox(height: 32),

                // Botón de enviar
                _buildEnviarButton(),

                const SizedBox(height: 16),

                // Botón de volver
                _buildVolverButton(),

                const SizedBox(height: 40),

                // Divisor
                _buildDivider(),

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

  Widget _buildCodigoField() {
    return TextFormField(
      controller: _codigoController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: const InputDecoration(
        labelText: 'Codigo',
        hintText: '123456',
        prefixIcon: Icon(Icons.lock_outline),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese el código';
        }
        if (value.length != 6) {
          return 'El código debe tener 6 dígitos';
        }
        return null;
      },
    );
  }

  Widget _buildNuevaContrasenaField() {
    return TextFormField(
      controller: _nuevaContrasenaController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Nueva contraseña',
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
          return 'Por favor ingrese una nueva contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildEnviarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRestablecer,
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : const Text('Enviar'),
      ),
    );
  }

  Widget _buildVolverButton() {
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

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.textSecondary)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textSecondary)),
      ],
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