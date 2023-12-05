import 'dart:convert';

import 'package:assign3_calorie_calculator/models/meal_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


import '../models/food.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbname = "Assignment3.db";

  // Create Database
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbname),
        onCreate: (db, version) async {
          await buildFoodTable(db);
          await buildMealPlanTable(db);
        },
        version: _version);
  }

  // Food table Schema
  static Future<void> buildFoodTable(Database db) async {
    await db.execute(
      "CREATE TABLE Food ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "item TEXT NOT NULL,"
          "calories INTEGER NOT NULL);",
    );
  }
  // Meal plan Table Schema
  static Future<void> buildMealPlanTable(Database db) async {
    await db.execute(
      "CREATE TABLE MealPlan ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "date TEXT NOT NULL,"
          "Items TEXT NOT NULL,"
          "totalCalories INTEGER NOT NULL);",
    );
  }
  // Add food
  static Future<int> addFood(Food food) async {
    final db = await _getDB();
    return await db.insert("Food", food.toJson());
  }
  // Delete food
  static Future<int> deleteFood(Food food) async {
    final db = await _getDB();
    return await db.delete("Food",
      where: 'id = ?',
      whereArgs: [food.id]
    );
  }

  // Delete meal plan
  static Future<void> deleteMealPlan(int id) async {
    final db = await _getDB();
    await db.delete(
      'MealPlan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all food items from Database
  static Future<List<Food>?> getAllFood() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> foodList = await db.query("Food");
    if(foodList.isEmpty) {
      return null;
    }
    return List.generate(foodList.length, (index) => Food.fromJson(foodList[index]));
  }

  //save the meal plan the user wants
  static Future<int> saveMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();

    String mealSelectionJson = jsonEncode(mealPlan.mealSelection.map((food) => food.toJson()).toList());

    Map<String, dynamic> mealPlanData = {
      'date': mealPlan.date.toIso8601String(),
      'Items': mealSelectionJson, // Saving the serialized JSON string
      'totalCalories': mealPlan.totalCalories,
    };

    // Insert the meal plan into the database
    return await db.insert("MealPlan", mealPlanData);
  }

  // Update Meal Plan
  static Future<void> updateMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();

    // Convert mealSelection to JSON string
    String mealSelectionJson =
    jsonEncode(mealPlan.mealSelection.map((food) => food.toJson()).toList());

    Map<String, dynamic> updatedData = {
      'date': mealPlan.date.toIso8601String(),
      'Items': mealSelectionJson,
      'totalCalories': mealPlan.totalCalories,
    };

    await db.update(
      'MealPlan',
      updatedData,
      where: 'id = ?',
      whereArgs: [mealPlan.num],
    );
  }


  // Get all Meal Plans from Database
  static Future<List<MealPlan>> getAllMealPlans() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> mealPlansList = await db.query("MealPlan");
    return List.generate(mealPlansList.length, (i) {
      return MealPlan.fromJson(mealPlansList[i]);
    });
  }

  static Future<List<Map<String, dynamic>>> queryData(String searchQuery) async {
    await _initializeDatabase();
    final Database db = _database! as Database;

    // Use the query method to get the data
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM food_items WHERE name LIKE ?',
      ['%$searchQuery%'],
    );

    return result;
  }

}

class _database {
}

class _initializeDatabase {
}
