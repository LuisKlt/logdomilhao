class User {
  final int? id;
  final String username;
  final int totalPoints;
  final int currentLevel;
  final String language;

  User({
    this.id,
    required this.username,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.language = 'pt',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'language': language,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      totalPoints: map['totalPoints'],
      currentLevel: map['currentLevel'],
      language: map['language'],
    );
  }

  User copyWith({
    int? id,
    String? username,
    int? totalPoints,
    int? currentLevel,
    String? language,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      language: language ?? this.language,
    );
  }
}