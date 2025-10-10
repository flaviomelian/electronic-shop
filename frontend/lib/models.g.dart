// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Compra _$CompraFromJson(Map<String, dynamic> json) => Compra(
  id: (json['id'] as num).toInt(),
  fecha: DateTime.parse(json['fecha'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => CompraItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CompraToJson(Compra instance) => <String, dynamic>{
  'id': instance.id,
  'fecha': instance.fecha.toIso8601String(),
  'items': instance.items,
};

CompraItem _$CompraItemFromJson(Map<String, dynamic> json) => CompraItem(
  id: (json['id'] as num).toInt(),
  producto: Producto.fromJson(json['producto'] as Map<String, dynamic>),
  cantidad: (json['cantidad'] as num).toInt(),
  precio: (json['precio'] as num).toDouble(),
);

Map<String, dynamic> _$CompraItemToJson(CompraItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'producto': instance.producto,
      'cantidad': instance.cantidad,
      'precio': instance.precio,
    };

Producto _$ProductoFromJson(Map<String, dynamic> json) =>
    Producto(id: (json['id'] as num).toInt(), nombre: json['nombre'] as String);

Map<String, dynamic> _$ProductoToJson(Producto instance) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
};
