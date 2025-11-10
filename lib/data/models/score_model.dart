class Score {
  final int? id;
  final int userId;
  final int exerciseId;
  final int points;
  final bool isCorrect;
  final DateTime completedAt;

  Score({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.points,
    required this.isCorrect,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'points': points,
      'isCorrect': isCorrect ? 1 : 0,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'],
      userId: map['userId'],
      exerciseId: map['exerciseId'],
      points: map['points'],
      isCorrect: map['isCorrect'] == 1,
      completedAt: DateTime.parse(map['completedAt']),
    );
  }
}