class Proveedor {
  final String id;
  final String tipoProveedor; // 'Natural' | 'Empresa'
  final String documento;
  final String razonSocial;
  final String telefono;
  final bool estado;
  final String createdAt;

  Proveedor({
    required this.id,
    required this.tipoProveedor,
    required this.documento,
    required this.razonSocial,
    required this.telefono,
    required this.estado,
    required this.createdAt,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['_id'] ?? '',
      tipoProveedor: json['tipoProveedor'] ?? 'Natural',
      documento: json['documento'] ?? '',
      razonSocial: json['razonSocial'] ?? '',
      telefono: json['telefono'] ?? '',
      estado: json['estado'] ?? true,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tipoProveedor': tipoProveedor,
      'documento': documento,
      'razonSocial': razonSocial,
      'telefono': telefono,
      'estado': estado,
      'createdAt': createdAt,
    };
  }

  /// Retorna una copia con los campos modificados
  Proveedor copyWith({
    String? razonSocial,
    String? telefono,
    bool? estado,
  }) {
    return Proveedor(
      id: id,
      tipoProveedor: tipoProveedor,
      documento: documento,
      razonSocial: razonSocial ?? this.razonSocial,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
      createdAt: createdAt,
    );
  }
}