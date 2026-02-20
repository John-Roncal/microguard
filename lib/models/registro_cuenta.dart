class RegistroCuenta {
  final String nombres;
  final String apellidos;
  final String correo;
  final String celular;
  final String contrasena;
  final String ruc;
  final String nombretienda;

  RegistroCuenta({
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.celular,
    required this.contrasena,
    required this.ruc,
    required this.nombretienda,
  });

  factory RegistroCuenta.fromJson(Map<String, dynamic> json) {
    return RegistroCuenta(
      nombres: json['Nombres'] ?? '',
      apellidos: json['Apellidos'] ?? '',
      correo: json['Correo'] ?? '',
      celular: json['Celular'] ?? '',
      contrasena: json['Contrasena'] ?? '',
      ruc: json['RUC'] ?? '',
      nombretienda: json['NombreTienda'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Nombres': nombres,
      'Apellidos': apellidos,
      'Correo': correo,
      'Celular': celular,
      'Contrasena': contrasena,
      'RUC': ruc,
      'NombreTienda': nombretienda,
    };
  }

  String get nombreCompleto => '$nombres $apellidos';
}