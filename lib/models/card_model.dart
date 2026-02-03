class ContactModel {
  final String? email;
  final String? phone;
  final String? mobileNumber;
  final String? personalEmail;
  final String? personalPhone;
  final bool hidePersonalEmail;
  final bool hidePersonalPhone;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final bool isPhoneVerified;

  ContactModel({
    this.email,
    this.phone,
    this.mobileNumber,
    this.personalEmail,
    this.personalPhone,
    this.hidePersonalEmail = false,
    this.hidePersonalPhone = false,
    this.isEmailVerified = false,
    this.isMobileVerified = false,
    this.isPhoneVerified = false,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    print("Test:$json");
    return ContactModel(
      email: json['email'],
      phone: json['phone'],
      mobileNumber: json['mobileNumber'],
      personalEmail: json['personalEmail'],
      personalPhone: json['personalPhone'],
      hidePersonalEmail: json['hidePersonalEmail'] ?? false,
      hidePersonalPhone: json['hidePersonalPhone'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isMobileVerified: json['isMobileVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'mobileNumber': mobileNumber,
      'personalEmail': personalEmail,
      'personalPhone': personalPhone,
      'hidePersonalEmail': hidePersonalEmail,
      'hidePersonalPhone': hidePersonalPhone,
      'isEmailVerified': isEmailVerified,
      'isMobileVerified': isMobileVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }
}

class AddressModel {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  AddressModel({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
    };
  }
}

// theme_model.dart
class ThemeModel {
  final String cardStyle;
  final String primaryColor;
  final String backgroundColor;
  final String textColor;
  final String template;

  ThemeModel({
    this.cardStyle = 'professional',
    this.primaryColor = '#0066cc',
    this.backgroundColor = '#ffffff',
    this.textColor = '#000000',
    this.template = 'default',
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      cardStyle: json['cardStyle'] ?? 'professional',
      primaryColor: json['primaryColor'] ?? '#0066cc',
      backgroundColor: json['backgroundColor'] ?? '#ffffff',
      textColor: json['textColor'] ?? '#000000',
      template: json['template'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardStyle': cardStyle,
      'primaryColor': primaryColor,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'template': template,
    };
  }
}

// card_model.dart
class CardModel {
  final String id;
  final String userId;
  final String name;
  final String title;
  final String company;
  final String industry;
  final String? profile;
  final String? profileFileName;
  final bool isLinkedinVerified;
  final String bio;
  final List<String> tags;
  final String qrCodeUrl;
  final String shortUrl;
  final String publicUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? githubUrl;
  final String? facebookUrl;
  final String? youtubeUrl;
  final String? website;
  final AddressModel? address;
  final bool isPublic;
  final bool isMinimalMode;
  final bool isBlocked;
  final bool isActive;
  final int viewCount;
  final int scanCount;
  final int saveCount;
  final int shareCount;
  final List<dynamic> customLinks;
  final ContactModel contact;
  final ThemeModel theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.title,
    required this.company,
    required this.industry,
    this.profile,
    this.linkedinUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.githubUrl,
    this.facebookUrl,
    this.youtubeUrl,
    this.website,
    this.address,
    this.profileFileName,
    this.isLinkedinVerified = false,
    required this.bio,
    required this.tags,
    required this.qrCodeUrl,
    required this.shortUrl,
    required this.publicUrl,
    this.isPublic = true,
    this.isMinimalMode = false,
    this.isBlocked = false,
    this.isActive = true,
    this.viewCount = 0,
    this.scanCount = 0,
    this.saveCount = 0,
    this.shareCount = 0,
    required this.customLinks,
    required this.contact,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['_id'],
      userId: json['userId'] ?? '',
      name: json['name'],
      title: json['title'],
      linkedinUrl: json['linkedinUrl'],
      twitterUrl: json['twitterUrl'],
      instagramUrl: json['instagramUrl'],
      githubUrl: json['githubUrl'],
      facebookUrl: json['facebookUrl'],
      youtubeUrl: json['youtubeUrl'],
      website: json['website'],
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
      company: json['company'],
      industry: json['industry'],
      profile: json['profile'],
      profileFileName: json['profileFileName'],
      isLinkedinVerified: json['isLinkedinVerified'] ?? false,
      bio: json['bio'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      qrCodeUrl: json['qrCodeUrl'],
      shortUrl: json['shortUrl'],
      publicUrl: json['publicUrl'],
      isPublic: json['isPublic'] ?? true,
      isMinimalMode: json['isMinimalMode'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isActive: json['isActive'] ?? true,
      viewCount: json['viewCount'] ?? 0,
      scanCount: json['scanCount'] ?? 0,
      saveCount: json['saveCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      customLinks: json['customLinks'] ?? [],
      contact: ContactModel.fromJson(json['contact']),
      theme: ThemeModel.fromJson(json['theme']),
      createdAt:json['createdAt']== null ? DateTime.now(): DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt']== null ? DateTime.now(): DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'title': title,
      'company': company,
      'industry': industry,
      'profile': profile,
      'linkedinUrl': linkedinUrl,
      'twitterUrl': twitterUrl,
      'instagramUrl': instagramUrl,
      'githubUrl': githubUrl,
      'facebookUrl': facebookUrl,
      'youtubeUrl': youtubeUrl,
      'website': website,
      'address': address?.toJson(),
      'profileFileName': profileFileName,
      'isLinkedinVerified': isLinkedinVerified,
      'bio': bio,
      'tags': tags,
      'qrCodeUrl': qrCodeUrl,
      'shortUrl': shortUrl,
      'publicUrl': publicUrl,
      'isPublic': isPublic,
      'isMinimalMode': isMinimalMode,
      'isBlocked': isBlocked,
      'isActive': isActive,
      'viewCount': viewCount,
      'scanCount': scanCount,
      'saveCount': saveCount,
      'shareCount': shareCount,
      'customLinks': customLinks,
      'contact': contact.toJson(),
      'theme': theme.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// pagination_model.dart
class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'pages': pages,
    };
  }
}

// cards_response_model.dart
class CardsResponseModel {
  final List<CardModel> cards;
  final PaginationModel pagination;

  CardsResponseModel({
    required this.cards,
    required this.pagination,
  });

  factory CardsResponseModel.fromJson(Map<String, dynamic> json) {
    return CardsResponseModel(
      cards: (json['cards'] as List)
          .map((card) => CardModel.fromJson(card))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}