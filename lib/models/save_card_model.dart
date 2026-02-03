// models/saved_card_model.dart
import 'card_model.dart';

class SavedCardModel {
  final String id;
  final String userId;
  final SavedCard card;
  final bool isFavorite;
  final DateTime savedAt;

  SavedCardModel({
    required this.id,
    required this.userId,
    required this.card,
    required this.isFavorite,
    required this.savedAt,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      card: SavedCard.fromJson(json['cardId'] ?? {}),
      isFavorite: json['isFavorite'] ?? false,
      savedAt: DateTime.parse(json['savedAt']),
    );
  }
}

// models/card_model.dart
class SavedCard {
  final String id;
  final String name;
  final String title;
  final String company;
  final String industry;
  final String shortUrl;

  SavedCard({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.industry,
    required this.shortUrl,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      industry: json['industry'] ?? '',
      shortUrl: json['shortUrl'] ?? '',
    );
  }
}
