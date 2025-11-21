// lib/data/models/level_model.dart

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
      // Se for salvar de volta no banco, tem que usar o nome certo também:
      'order_num': order, 
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
      // CORREÇÃO AQUI: mudou de map['order'] para map['order_num']
      order: map['order_num'] ?? 0, 
      isLocked: map['isLocked'] == 1,
      // Dica: Adicione ?? 0 para segurança em requiredPoints também
      requiredPoints: map['requiredPoints'] ?? 0, 
    );
  }
}