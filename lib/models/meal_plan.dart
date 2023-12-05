import 'dart:convert';

import 'food.dart';

class MealPlan {
  int? num;
  late DateTime date;
  late List <Food> mealSelection;
  late int totalCalories;

  MealPlan({
    this.num,
    required this.date,
    required this.mealSelection,
  }) : totalCalories = calculateTotalCalories(mealSelection);

  get id => null;

  static int calculateTotalCalories(List<Food> mealSelection) {
    int total = 0;
    for (var foodItem in mealSelection) {
      total += foodItem.calories;
    }
    return total;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': num,
      'date': date.toIso8601String(),
      'mealSelection': mealSelection.map((foodItem) => foodItem.toJson()).toList(),
      'totalCalories': totalCalories,
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final String itemsJsonString = json['Items'] as String;
    final List<dynamic> mealSelectionData = jsonDecode(itemsJsonString);

    // Converting the list into a dynamic list for food objects
    final List<Food> mealSelection = mealSelectionData
        .map((foodItemData) => Food.fromJson(foodItemData as Map<String, dynamic>))
        .toList();

    return MealPlan(
      num: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      mealSelection: mealSelection,
    );
  }
}

