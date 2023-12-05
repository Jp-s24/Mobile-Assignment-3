import 'package:flutter/material.dart';

import '../db/databasehelper.dart';
import '../models/food.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {

  // Food object list
  late List<Food> foodList = [];

  // Text input Controllers
  final TextEditingController foodItemController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();

  // Function create food object upload to database
  Future<void> addFood() async {
    final String item = foodItemController.text;
    final int? calories = int.tryParse(calorieController.text);
    // check that user input name and calories
    if (item.isNotEmpty && calories != null) {
      final food = Food(id:null, item: item, calories: calories);
      // add to db
      await DatabaseHelper.addFood(food);
      foodItemController.clear();
      calorieController.clear();
      updateFoodList();
    }
  }

  Future<void> updateFoodList() async {
    final List<Food>? foods = await DatabaseHelper.getAllFood();
    if (foods != null) {
      setState(() {
        foodList = foods;
      });
    }
  }

  // Initialize food list
  @override
  void initState() {
    super.initState();
    updateFoodList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Call the function to add the food item
                _addFoodDialogue();
              },
              child: const Text('Add Food Items to List'),
            ),
            // List view for Food Items Available
            const SizedBox(height: 20),
            const Text(
              'Available Food Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: foodList.length,
                itemBuilder: (BuildContext context, int i) {
                  final food = foodList[i];
                  return ListTile(
                    title: Text('${food.item}: ${food.calories} cal'),
                    onTap: () {
                      Navigator.pop(context, food);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogue (form) for adding food to database
  Future<void> _addFoodDialogue() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Food item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: foodItemController,
                decoration: const InputDecoration(labelText: 'Food Item'),
              ),
              TextFormField(
                controller: calorieController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                addFood();
                Navigator.of(context).pop();
              },
              child: const Text('Add Food'),
            ),
          ],
        );
      },
    );
  }
}
