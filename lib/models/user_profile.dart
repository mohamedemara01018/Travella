class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String location; // <--- 1. NEW FIELD

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.location, // <--- 2. ADD TO CONSTRUCTOR
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'location': location, // <--- 3. ADD TO MAP
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      location: map['location'] ?? '', // <--- 4. READ FROM MAP
    );
  }
}