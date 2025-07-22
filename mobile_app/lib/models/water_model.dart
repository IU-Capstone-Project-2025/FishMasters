import 'dart:convert';

import 'package:mobile_app/models/discussion_model.dart';

class WaterModel {
  final double id;
  final double x;
  final double y;
  final DiscussionOfWaterModel? discussion;

  WaterModel({
    required this.id,
    required this.x,
    required this.y,
    this.discussion,
  });

  factory WaterModel.fromJson(Map<String, dynamic> json) {
    return WaterModel(
      id: (json['id'] as num).toDouble(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      discussion: json['discussion'] != null
          ? DiscussionOfWaterModel.fromJson(
              json['discussion'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'x': x, 'y': y, 'discussion': discussion?.toJson()};
  }

  WaterModel parse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return WaterModel.fromJson(json);
  }
}
