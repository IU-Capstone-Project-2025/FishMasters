class FishPredictionModel {
  final String prediction;
  final double confidence;
  final String status;

  FishPredictionModel({
    required this.prediction,
    required this.confidence,
    required this.status,
  });

  factory FishPredictionModel.fromJson(Map<String, dynamic> json) {
    return FishPredictionModel(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'status': status,
    };
  }
}
