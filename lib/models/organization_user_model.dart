class OrganizationUserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final bool isEmailVerified;
  final String platformRole;
  final String userType;
  final String? organizationName;
  final String? organizationLogo;
  final String? userState;
  final bool isActive;
  final bool isBlocked;
  final bool twoFactorEnabled;
  final List<String> permissions;
  final String? organizationId;
  final String? organizationRole;
  final String? invitedAt;
  final String? lastLogin;
  final int cardCount;
  final String? createdAt;

  OrganizationUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.location,
    this.city,
    this.state,
    this.country,
    this.isEmailVerified = false,
    required this.platformRole,
    required this.userType,
    this.organizationName,
    this.organizationLogo,
    this.userState,
    this.isActive = true,
    this.isBlocked = false,
    this.twoFactorEnabled = false,
    required this.permissions,
    this.organizationId,
    this.organizationRole,
    this.invitedAt,
    this.lastLogin,
    this.cardCount = 0,
    this.createdAt,
  });

  factory OrganizationUserModel.fromJson(Map<String, dynamic> json) {
    return OrganizationUserModel(
      id: json['_id'] ?? json['id'] ?? '', // Handle both _id and id
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      location: json['location'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      platformRole: json['platformRole'] ?? 'user',
      userType: json['userType'] ?? 'individual',
      organizationName: json['organizationName'],
      organizationLogo: json['organizationLogo'],
      userState: json['userState'],
      isActive: json['isActive'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      permissions: json['permissions'] != null ? List<String>.from(json['permissions']) : [],
      organizationId: json['organizationId'],
      organizationRole: json['organizationRole'],
      invitedAt: json['invitedAt'],
      lastLogin: json['lastLogin'],
      cardCount: json['cardCount'] ?? 0,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'isEmailVerified': isEmailVerified,
      'platformRole': platformRole,
      'userType': userType,
      'organizationName': organizationName,
      'organizationLogo': organizationLogo,
      'userState': userState,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'twoFactorEnabled': twoFactorEnabled,
      'permissions': permissions,
      'organizationId': organizationId,
      'organizationRole': organizationRole,
      'invitedAt': invitedAt,
      'lastLogin': lastLogin,
      'cardCount': cardCount,
      'createdAt': createdAt,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return 'JD';
    String res = '';
    if (firstName.isNotEmpty) res += firstName[0];
    if (lastName.isNotEmpty) res += lastName[0];
    return res.toUpperCase();
  }
}
