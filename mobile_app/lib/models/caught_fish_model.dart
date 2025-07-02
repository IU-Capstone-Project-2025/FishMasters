import 'dart:convert';
import 'package:mobile_app/models/models.dart';

class CaughtFishModel {
  final int id;
  final String fisher;
  final double avgWeight;
  final FishModel fish;

  CaughtFishModel({
    required this.id,
    required this.fisher,
    required this.avgWeight,
    required this.fish,
  });

  factory CaughtFishModel.fromJson(Map<String, dynamic> json) {
    return CaughtFishModel(
      id: json['id'] as int,
      fisher: json['fisher'] as String,
      avgWeight: (json['avgWeight'] as num).toDouble(),
      fish: FishModel.fromJson(json['fish'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fisher': fisher,
      'avgWeight': avgWeight,
      'fish': fish.toJson(),
    };
  }

  CaughtFishModel parse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return CaughtFishModel.fromJson(json);
  }
}
