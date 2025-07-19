class DiscussionModel {
  final int id;

  DiscussionModel({required this.id});

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(id: json['id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
