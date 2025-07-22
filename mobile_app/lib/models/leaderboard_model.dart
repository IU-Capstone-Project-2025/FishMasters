class LeaderboardModel {
  final List<LeaderboardItem> items;

  LeaderboardModel({required this.items});

  factory LeaderboardModel.fromJson(List<dynamic> json) {
    return LeaderboardModel(
      items: json.map((item) => LeaderboardItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }
}

class LeaderboardItem {
  final String email;
  final String name;
  final String surname;
  final String password;
  final int score;
  final String? photo;

  LeaderboardItem({
    required this.email,
    required this.name,
    required this.surname,
    required this.password,
    required this.score,
    this.photo,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      email: json['email'],
      name: json['name'],
      surname: json['surname'],
      password: json['password'],
      photo: json['photo'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'password': password,
      'photo': photo,
      'score': score,
    };
  }
}
