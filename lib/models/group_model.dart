import 'dart:developer';

import 'package:rolo_digi_card/models/org_model.dart';

import 'check_card_model.dart'; // reuse your existing CheckCardModel

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String groupType;
  final bool isActive;
  final bool isPublic;
  final String creatorRole;
  final GroupOwner? ownerId;
  final String organizationId;
  final List<GroupMember> members;
  final List<OrgCard> cards;
  final List<dynamic> linkedGroups;
  final String? createdAt;
  final String? updatedAt;
  final int version;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.groupType,
    required this.isActive,
    required this.isPublic,
    required this.creatorRole,
    this.ownerId,
    required this.organizationId,
    required this.members,
    required this.cards,
    required this.linkedGroups,
    this.createdAt,
    this.updatedAt,
    required this.version,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    log("Parsing GroupModel from JSON: ${json.toString()}");
  return GroupModel(
    id: json['_id'] ?? json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    groupType: json['groupType'] ?? '',
    isActive: json['isActive'] ?? false,
    isPublic: json['isPublic'] ?? false,
    creatorRole: json['creatorRole'] ?? '',
    ownerId: json['ownerId'] is Map<String, dynamic>
        ? GroupOwner.fromJson(json['ownerId'])
        : null,
    organizationId: json['organizationId'] ?? '',
    members: (json['members'] as List<dynamic>? ?? [])
        .where((e) => e is Map<String, dynamic>) // skip plain strings
        .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
        .toList(),
    cards: (json['cards'] as List<dynamic>? ?? [])
        .where((e) => e is Map<String, dynamic>) // skip plain strings
        .map((e) => OrgCard.fromJson(e as Map<String, dynamic>))
        .toList(),
    linkedGroups: json['linkedGroups'] ?? [],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    version: json['__v'] ?? 0,
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'groupType': groupType,
      'isActive': isActive,
      'isPublic': isPublic,
      'creatorRole': creatorRole,
      'ownerId': ownerId?.toJson(),
      'organizationId': organizationId,
      'members': members.map((e) => e.toJson()).toList(),
      // 'cards': cards.map((e) => e.t()).toList(),
      'linkedGroups': linkedGroups,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}

class GroupOwner {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String organizationRole;

  GroupOwner({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.organizationRole,
  });

  factory GroupOwner.fromJson(Map<String, dynamic> json) {
    return GroupOwner(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      organizationRole: json['organizationRole'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'organizationRole': organizationRole,
      };
}

class GroupMember {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String organizationRole;

  GroupMember({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.organizationRole,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      organizationRole: json['organizationRole'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'organizationRole': organizationRole,
      };
}