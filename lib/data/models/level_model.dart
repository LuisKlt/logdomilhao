class Level {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int order;
  final bool isLocked;
  final int requiredPoints;

  Level({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.order,
    this.isLocked = true,
    required this.requiredPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'order': order,
      'isLocked': isLocked ? 1 : 0,
      'requiredPoints': requiredPoints,
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      order: map['order'],
      isLocked: map['isLocked'] == 1,
      requiredPoints: map['requiredPoints'],
    );
  }
}