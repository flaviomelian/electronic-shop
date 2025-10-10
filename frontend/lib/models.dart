import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class Compra {
  final int id;
  final DateTime fecha;
  final List<CompraItem> items;

  Compra({required this.id, required this.fecha, required this.items});

  factory Compra.fromJson(Map<String, dynamic> json) => _$CompraFromJson(json);
  Map<String, dynamic> toJson() => _$CompraToJson(this);
}

@JsonSerializable()
class CompraItem {
  final int id;
  final Producto producto;
  final int cantidad;
  final double precio;

  CompraItem({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precio,
  });

  factory CompraItem.fromJson(Map<String, dynamic> json) =>
      _$CompraItemFromJson(json);
  Map<String, dynamic> toJson() => _$CompraItemToJson(this);
}

@JsonSerializable()
class Producto {
  final int id;
  final String nombre;

  Producto({required this.id, required this.nombre});

  factory Producto.fromJson(Map<String, dynamic> json) =>
      _$ProductoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductoToJson(this);
}
