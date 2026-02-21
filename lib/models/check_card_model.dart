class CheckCardModel {
  final String id;
  final Contact contact;
  final SocialLinks socialLinks;
  final ThemeConfig theme;

  final UserInfo? userId;
  final UserInfo? createdBy;

  final String organizationId;
  final String name;
  final String title;
  final String company;
  final String industry;

  final String profile;
  final String profileFileName;
  final String linkedinUrl;
  final bool isLinkedinVerified;

  final String website;
  final String bio;
  final String location;

  final List<String> tags;
  final String qrCodeUrl;
  final String shortUrl;

  final bool isPublic;
  final String mode;
  final bool isMinimalMode;
  final bool isBlocked;
  final bool isActive;

  final int viewCount;
  final int scanCount;
  final int saveCount;
  final int shareCount;

  final List<dynamic> customLinks;

  final DateTime createdAt;
  final DateTime updatedAt;

  final int version;

  CheckCardModel({
    required this.id,
    required this.contact,
    required this.socialLinks,
    required this.theme,
    this.userId,
    this.createdBy,
    required this.organizationId,
    required this.name,
    required this.title,
    required this.company,
    required this.industry,
    required this.profile,
    required this.profileFileName,
    required this.linkedinUrl,
    required this.isLinkedinVerified,
    required this.website,
    required this.bio,
    required this.location,
    required this.tags,
    required this.qrCodeUrl,
    required this.shortUrl,
    required this.isPublic,
    required this.mode,
    required this.isMinimalMode,
    required this.isBlocked,
    required this.isActive,
    required this.viewCount,
    required this.scanCount,
    required this.saveCount,
    required this.shareCount,
    required this.customLinks,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CheckCardModel.fromJson(Map<String, dynamic> json) {
    return CheckCardModel(
      id: json['_id'] ?? '',
      contact: Contact.fromJson(json['contact'] ?? {}),
      socialLinks: SocialLinks.fromJson(json['socialLinks'] ?? {}),
      theme: ThemeConfig.fromJson(json['theme'] ?? {}),
userId: json['userId'] is Map<String, dynamic>
    ? UserInfo.fromJson(json['userId'])
    : null,
createdBy: json['createdBy'] is Map<String, dynamic>
    ? UserInfo.fromJson(json['createdBy'])
    : null,      organizationId: json['organizationId'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      industry: json['industry'] ?? '',
      profile: json['profile'] ?? '',
      profileFileName: json['profileFileName'] ?? '',
      linkedinUrl: json['linkedinUrl'] ?? '',
      isLinkedinVerified: json['isLinkedinVerified'] ?? false,
      website: json['website'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      shortUrl: json['shortUrl'] ?? '',
      isPublic: json['isPublic'] ?? false,
      mode: json['mode'] ?? '',
      isMinimalMode: json['isMinimalMode'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isActive: json['isActive'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      scanCount: json['scanCount'] ?? 0,
      saveCount: json['saveCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      customLinks: json['customLinks'] ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'contact': contact.toJson(),
      'socialLinks': socialLinks.toJson(),
      'theme': theme.toJson(),
      'userId': userId?.toJson(),
      'createdBy': createdBy?.toJson(),
      'organizationId': organizationId,
      'name': name,
      'title': title,
      'company': company,
      'industry': industry,
      'profile': profile,
      'profileFileName': profileFileName,
      'linkedinUrl': linkedinUrl,
      'isLinkedinVerified': isLinkedinVerified,
      'website': website,
      'bio': bio,
      'location': location,
      'tags': tags,
      'qrCodeUrl': qrCodeUrl,
      'shortUrl': shortUrl,
      'isPublic': isPublic,
      'mode': mode,
      'isMinimalMode': isMinimalMode,
      'isBlocked': isBlocked,
      'isActive': isActive,
      'viewCount': viewCount,
      'scanCount': scanCount,
      'saveCount': saveCount,
      'shareCount': shareCount,
      'customLinks': customLinks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class Contact {
  final String email;
  final String phone;
  final String personalEmail;
  final String personalPhone;
  final bool hidePersonalEmail;
  final bool hidePersonalPhone;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final bool isPhoneVerified;

  Contact({
    required this.email,
    required this.phone,
    required this.personalEmail,
    required this.personalPhone,
    required this.hidePersonalEmail,
    required this.hidePersonalPhone,
    required this.isEmailVerified,
    required this.isMobileVerified,
    required this.isPhoneVerified,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      personalEmail: json['personalEmail'] ?? '',
      personalPhone: json['personalPhone'] ?? '',
      hidePersonalEmail: json['hidePersonalEmail'] ?? false,
      hidePersonalPhone: json['hidePersonalPhone'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isMobileVerified: json['isMobileVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'personalEmail': personalEmail,
        'personalPhone': personalPhone,
        'hidePersonalEmail': hidePersonalEmail,
        'hidePersonalPhone': hidePersonalPhone,
        'isEmailVerified': isEmailVerified,
        'isMobileVerified': isMobileVerified,
        'isPhoneVerified': isPhoneVerified,
      };
}

class SocialLinks {
  final String linkedin;
  final String twitter;
  final String facebook;
  final String instagram;
  final String github;
  final String youtube;

  SocialLinks({
    required this.linkedin,
    required this.twitter,
    required this.facebook,
    required this.instagram,
    required this.github,
    required this.youtube,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      github: json['github'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'linkedin': linkedin,
        'twitter': twitter,
        'facebook': facebook,
        'instagram': instagram,
        'github': github,
        'youtube': youtube,
      };
}

class ThemeConfig {
  final String cardStyle;
  final String primaryColor;
  final String backgroundColor;
  final String textColor;
  final String template;

  ThemeConfig({
    required this.cardStyle,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.template,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      cardStyle: json['cardStyle'] ?? '',
      primaryColor: json['primaryColor'] ?? '',
      backgroundColor: json['backgroundColor'] ?? '',
      textColor: json['textColor'] ?? '',
      template: json['template'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cardStyle': cardStyle,
        'primaryColor': primaryColor,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'template': template,
      };
}

class UserInfo {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? organizationRole;

  UserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.organizationRole,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      organizationRole: json['organizationRole'],
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