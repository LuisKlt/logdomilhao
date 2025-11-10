class Exercise {
  final int? id;
  final int levelId;
  final String title;
  final String description;
  final String type; // multiple_choice, fill_blank, code_completion
  final String content;
  final String correctAnswer;
  final List<String> options;
  final int points;

  Exercise({
    this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.correctAnswer,
    required this.options,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'levelId': levelId,
      'title': title,
      'description': description,
      'type': type,
      'content': content,
      'correctAnswer': correctAnswer,
      'options': options.join('|'),
      'points': points,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      levelId: map['levelId'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      content: map['content'],
      correctAnswer: map['correctAnswer'],
      options: map['options'].split('|'),
      points: map['points'],
    );
  }
}