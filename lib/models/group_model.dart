import 'package:rolo_digi_card/models/organization_user_model.dart';
// If cards are embedded or just IDs, let's assume objects for now based on other endpoints returning objects or lists of IDs.
// Text file line 20 shows 'cardIds' in request body, but response usually includes objects or at least some details.
// Line 466 in API.txt (from earlier) showed groups having 'cards' as list of IDs strings.
// I'll support both if possible or just strings for IDs if the primary list return IDs.

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final bool isShared;
  final dynamic ownerId; // Could be String or Object based on expansion
  final List<dynamic> members; // Could be Strings (IDs) or Objects
  final List<dynamic> cards; // Could be Strings (IDs) or Objects
  final String? createdAt;
  final String? updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.isShared = false,
    this.ownerId,
    this.members = const [],
    this.cards = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isShared: json['isShared'] ?? false,
      ownerId: json['ownerId'],
      members: json['members'] ?? [],
      cards: json['cards'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'isShared': isShared,
      'ownerId': ownerId,
      'members': members,
      'cards': cards,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
