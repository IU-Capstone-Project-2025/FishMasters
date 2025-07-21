class DiscussionOfWaterModel {
  final int id;

  DiscussionOfWaterModel({required this.id});

  factory DiscussionOfWaterModel.fromJson(Map<String, dynamic> json) {
    return DiscussionOfWaterModel(id: json['id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
