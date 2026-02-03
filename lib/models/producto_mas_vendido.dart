class ProductoMasVendido {
  final String nombre;
  final int unidades;
  final double precio;
  final String? imagenUrl;

  ProductoMasVendido({
    required this.nombre,
    required this.unidades,
    required this.precio,
    this.imagenUrl,
  });

  factory ProductoMasVendido.fromJson(Map<String, dynamic> json) {
    return ProductoMasVendido(
      nombre: json['nombre'] ?? '',
      unidades: json['unidades'] ?? 0,
      precio: (json['precio'] ?? 0).toDouble(),
      imagenUrl: json['imagenUrl'],
    );
  }
}