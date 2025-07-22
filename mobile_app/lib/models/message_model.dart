class MessageModel {
  final int id;
  final String content;
  final String fisherEmail;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.fisherEmail,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      fisherEmail: json['fisherEmail'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'fisherEmail': fisherEmail,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CreateMessageRequestModel {
  final int discussionId;
  final String content;
  final String fisherEmail;

  CreateMessageRequestModel({
    required this.discussionId,
    required this.content,
    required this.fisherEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'discussionId': discussionId,
      'content': content,
      'fisherEmail': fisherEmail,
    };
  }

  static CreateMessageRequestModel fromJson(Map<String, dynamic> json) {
    return CreateMessageRequestModel(
      discussionId: json['discussionId'],
      content: json['content'],
      fisherEmail: json['fisherEmail'],
    );
  }
}
