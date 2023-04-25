class User {
  final String creationTime;
  final String email;
  final String uid;
  final String? fcmToken;
  final String displayName;
  final String? photoUrl;
  final List<dynamic>? groups;
  final List<dynamic>? contacts;

  User({
    this.contacts,
    this.groups,
    required this.creationTime,
    required this.email,
    required this.uid,
    this.fcmToken,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "groups": groups,
      "contacts": contacts,
      "creationTime": creationTime,
      "fcmToken": fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        creationTime: map['creationTime'],
        email: map['email'],
        uid: map['uid'],
        displayName: map['displayName'],
        photoUrl: map['photoUrl'],
        fcmToken: map['fcmToken'],
        contacts: map['contacts'],
        groups: ['groups']);
  }
}
