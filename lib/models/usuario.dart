class Usuario {
  final String id;
  final String nombres;
  final String apellidos;
  final String ruc;
  final String razonSocial;

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.ruc,
    required this.razonSocial,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? '',
      nombres: json['Nombres'] ?? '',
      apellidos: json['Apellidos'] ?? '',
      ruc: json['RUC'] ?? '',
      razonSocial: json['RazonSocial'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Nombres': nombres,
      'Apellidos': apellidos,
      'RUC': ruc,
      'RazonSocial': razonSocial,
    };
  }

  String get nombreCompleto => '$nombres $apellidos';
}