class Food {
  // Attributes
  final int? id;
  final String item;
  final int calories;

  Food({
    this.id,
    required this.item,
    required this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'calories': calories,
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int?,
      item: json['item'] as String,
      calories: json['calories'] as int,
    );
  }
}
