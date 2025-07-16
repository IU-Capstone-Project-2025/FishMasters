import 'package:mobile_app/models/models.dart';

class FishingSessionModel {
  final String fisherEmail;
  final WaterModel water;

  FishingSessionModel({required this.fisherEmail, required this.water});

  factory FishingSessionModel.fromJson(Map<String, dynamic> json) {
    return FishingSessionModel(
      fisherEmail: json['fisherEmail'] as String,
      water: WaterModel.fromJson(json['water'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'fisherEmail': fisherEmail, 'water': water.toJson()};
  }
}
