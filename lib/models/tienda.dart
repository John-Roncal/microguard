class Tienda {
  final String id;
  final String usuario;
  final String ruc;
  final String nombretienda;
  final String razonsocial;
  final String stockminimo;
  final String diasvencimiento;

  Tienda({
    required this.id,
    required this.usuario,
    required this.ruc,
    required this.nombretienda,
    required this.razonsocial,
    required this.stockminimo,
    required this.diasvencimiento,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['_id'] ?? '',
      usuario: json['Usuario'] ?? '',
      ruc: json['RUC'] ?? '',
      nombretienda: json['NombreTienda'] ?? '',
      razonsocial: json['RazonSocial'] ?? '',
      stockminimo: json['StockMinimo'] ?? '',
      diasvencimiento: json['diasAlertaVencimiento'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Usuario': usuario,
      'RUC': ruc,
      'NombreTienda': nombretienda,
      'RazonSocial': razonsocial,
      'StockMinimo': stockminimo,
      'diasAlertaVencimiento': diasvencimiento,
    };
  }
}