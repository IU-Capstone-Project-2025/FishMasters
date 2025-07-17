class FishSearchRequestModel {
  final String description;
  final int topK;
  final String mode;

  FishSearchRequestModel({
    required this.description,
    this.topK = 5,
    this.mode = "auto",
  });

  factory FishSearchRequestModel.fromJson(Map<String, dynamic> json) {
    return FishSearchRequestModel(
      description: json['description'] as String,
      topK: json['top_k'] as int,
      mode: json['mode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'top_k': topK, 'mode': mode};
  }
}

class FishResultModel {
  final int id;
  final String name;
  final int similarityScore;
  final String genus;
  final String species;
  final String fbname;
  final String description;

  FishResultModel({
    required this.id,
    required this.name,
    required this.similarityScore,
    required this.genus,
    required this.species,
    required this.fbname,
    required this.description,
  });

  factory FishResultModel.fromJson(Map<String, dynamic> json) {
    return FishResultModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      similarityScore: (json['similarity_score'] as num).toInt(),
      genus: json['genus'] as String? ?? '',
      species: json['species'] as String? ?? '',
      fbname: json['fbname'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'similarity_score': similarityScore,
      'genus': genus,
      'species': species,
      'fbname': fbname,
      'description': description,
    };
  }
}

class FishSearchResponseModel {
  final bool success;
  final List<FishResultModel> results;
  final String query;
  final String modeUsed;
  final Map<String, dynamic> timing;
  final double totalTime;

  FishSearchResponseModel({
    required this.success,
    required this.results,
    required this.query,
    required this.modeUsed,
    required this.timing,
    required this.totalTime,
  });

  factory FishSearchResponseModel.fromJson(Map<String, dynamic> json) {
    var resultsJson = json['results'] as List? ?? [];
    List<FishResultModel> resultsList = resultsJson
        .map((item) => FishResultModel.fromJson(item))
        .toList();

    return FishSearchResponseModel(
      success: json['success'] as bool? ?? false,
      results: resultsList,
      query: json['query'] as String? ?? '',
      modeUsed: json['mode_used'] as String? ?? '',
      timing: json['timing'] as Map<String, dynamic>? ?? {},
      totalTime: (json['total_time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'results': results.map((item) => item.toJson()).toList(),
      'query': query,
      'mode_used': modeUsed,
      'timing': timing,
      'total_time': totalTime,
    };
  }
}
