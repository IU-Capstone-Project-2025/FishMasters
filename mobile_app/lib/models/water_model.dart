import 'dart:convert';

class WaterModel {
  final int id;
  final double x;
  final double y;

  WaterModel({required this.id, required this.x, required this.y});

  factory WaterModel.fromJson(Map<String, dynamic> json) {
    return WaterModel(
      id: json['id'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'x': x, 'y': y};
  }

  WaterModel parse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return WaterModel.fromJson(json);
  }
}
