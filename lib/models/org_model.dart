// ─── AssignedUser Sub-model ───────────────────────────────────────────────

class AssignedUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const AssignedUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

// ─── Model ───────────────────────────────────────────────────────────────────

class OrgCard {
  final String id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String profile; // base64 or url
  final String shortUrl;
  final String mode;
  final bool isActive;
  final bool isBlocked;
  final int viewCount;
  final int scanCount;
  final int saveCount;
  final int shareCount;
  final String createdAt;
  final String updatedAt;
  final AssignedUser? assignedUser;
  final Map<String, dynamic> theme;

  const OrgCard({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    required this.profile,
    required this.shortUrl,
    required this.mode,
    required this.isActive,
    required this.isBlocked,
    required this.viewCount,
    required this.scanCount,
    required this.saveCount,
    required this.shareCount,
    required this.createdAt,
    required this.updatedAt,
    required this.theme,
    this.assignedUser,
  });

  factory OrgCard.fromJson(Map<String, dynamic> json) {
    final contact = json['contact'] as Map<String, dynamic>? ?? {};
    return OrgCard(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      email: contact['email'] as String? ?? '',
      phone: contact['phone'] as String? ?? '',
      profile: json['profile'] as String? ?? '',
      shortUrl: json['shortUrl'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isBlocked: json['isBlocked'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      scanCount: json['scanCount'] as int? ?? 0,
      saveCount: json['saveCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      theme: json['theme'] as Map<String, dynamic>? ?? {},
      assignedUser: json['userId'] is Map
          ? AssignedUser.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
    );
  }

  String get displayTitle {
    final parts = [title, if (company.isNotEmpty) 'at $company'];
    return parts.join(' ');
  }

  /// Formatted date: 02/02/2026
  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String get formattedCreatedAt => _formatDate(createdAt);
  String get formattedUpdatedAt => _formatDate(updatedAt);
}