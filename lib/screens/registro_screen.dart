import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'registro_screen_2.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _celularController = TextEditingController();
  final _nombreNegocioController = TextEditingController();
  final _rucController = TextEditingController();

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _nombreNegocioController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  void _continuar() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistroScreen2(
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            celular: _celularController.text.trim(),
            nombreNegocio: _nombreNegocioController.text.trim(),
            ruc: _rucController.text.trim(),
          ),
        ),
      );
    }
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
                  'Completa los campos para registrarte',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // Campos del formulario
                _buildTextField(
                  controller: _nombresController,
                  label: 'Nombre',
                  hint: 'Juan',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre';
                    }
                    if (!RegExp(r'^[A-Za-zÑñÁÉÍÓÚáéíóú\s]+$').hasMatch(value)) {
                      return 'Solo se permiten letras';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _apellidosController,
                  label: 'Apellidos',
                  hint: 'Pérez',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese sus apellidos';
                    }
                    if (!RegExp(r'^[A-Za-zÑñÁÉÍÓÚáéíóú\s]+$').hasMatch(value)) {
                      return 'Solo se permiten letras';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _celularController,
                  label: 'Celular',
                  hint: '987654321',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su celular';
                    }
                    if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                      return 'Ingrese un número válido de 9 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nombreNegocioController,
                  label: 'Nombre del Negocio',
                  hint: 'Tiendita de Don Pepe',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre del negocio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _rucController,
                  label: 'Ruc',
                  hint: '12345678912',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el RUC';
                    }
                    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                      return 'El RUC debe tener 11 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Botón continuar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continuar,
                    child: const Text('Continuar'),
                  ),
                ),

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: validator,
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
            onTap: () => Navigator.of(context).pop(),
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