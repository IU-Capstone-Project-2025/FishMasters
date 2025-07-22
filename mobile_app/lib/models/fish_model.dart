import 'dart:convert';

class FishModel {
  final int id;
  final String name;
  final String? photo;

  FishModel({required this.id, required this.name, this.photo});

  factory FishModel.fromJson(Map<String, dynamic> json) {
    return FishModel(
      id: json['id'] as int,
      name: json['name'] as String,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photo': photo};
  }

  FishModel parse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return FishModel.fromJson(json);
  }
}
