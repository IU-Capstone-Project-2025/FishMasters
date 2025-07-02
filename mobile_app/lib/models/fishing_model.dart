import 'dart:convert';
import 'package:mobile_app/models/models.dart';

class FishingModel {
  final int id;
  final String userEmail;
  final String startTime;
  final String? endTime;
  final List<CaughtFishModel> caughtFish;
  final WaterModel water;

  FishingModel({
    required this.id,
    required this.userEmail,
    required this.startTime,
    required this.endTime,
    required this.caughtFish,
    required this.water,
  });

  factory FishingModel.fromJson(Map<String, dynamic> json) {
    return FishingModel(
      id: json['id'] as int,
      userEmail: json['userEmail'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      caughtFish: (json['caughtFish'] as List)
          .map((e) => CaughtFishModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      water: WaterModel.fromJson(json['water'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'startTime': startTime,
      'endTime': endTime,
      'caughtFish': caughtFish.map((e) => e.toJson()).toList(),
      'water': water.toJson(),
    };
  }

  FishingModel parse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return FishingModel.fromJson(json);
  }
}
