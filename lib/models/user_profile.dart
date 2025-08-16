class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicture;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePicture,
  });

  // Serverdan kelgan JSON ma'lumotidan UserProfile obyekti yaratish
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // Backend'dan keladigan kalit so'zlarni moslashtiring
      uid: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? 'Noma\'lum',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'], // Bu null bo'lishi mumkin
    );
  }

  // Obyektni nusxalash uchun yordamchi metod
  UserProfile copyWith({
    String? fullName,
    String? profilePicture,
  }) {
    return UserProfile(
      uid: uid, email: email, phone: phone, // Bu qiymatlar o'zgarmaydi
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}