import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../db/databasehelper.dart';
import '../screens/edit_meal_plan_screen.dart';
import '../screens/meal_plan_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<MealPlan> savedPlans = [];
  String searchQuery = '';

  // Update meal plans from database method if action called delete/search
  Future<void> _updateMealPlans() async {
    List<MealPlan> plans;
    if (searchQuery.isEmpty) {
      plans = await DatabaseHelper.getAllMealPlans();
    } else {
      plans = (await DatabaseHelper.queryData(searchQuery)).cast<MealPlan>();
    }
    setState(() {
      savedPlans = plans;
    });
  }

  // Update screen with saved meal plans with screen initializes
  @override
  void initState() {
    super.initState();
    _updateMealPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      // app bar top
      appBar: AppBar(
        title: const Text('Meal Plan App'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Container(
            // Search bar
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Search by Date',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // Update meal plans on date search
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _updateMealPlans();
                });
              },
            ),
          ),
          Expanded(

            // If no meal plans saved print text
            child: savedPlans.isEmpty
                ? const Center(
              child: Text(
                'No meal plans currently saved',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            )

            // If meal plans saved create listview of cards with meal plan
                : ListView.separated(
              itemCount: savedPlans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10), // Adds space between cards
              itemBuilder: (context, index) {
                MealPlan mealPlan = savedPlans[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        // format date for meal plans
                        child: Text(
                          'Meal Plan on ${DateFormat('yyyy-MM-dd').format(mealPlan.date)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Total Calories: ${mealPlan.totalCalories}'),
                            ),
                            // Display meal plans on home
                            ...mealPlan.mealSelection.map(
                                  (food) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text('${food.item} - ${food.calories} cal'),
                              ),
                            ),
                          ],
                        ),

                        // Ontap of meal plan card navigate to update screen and pass selected meal plan object
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _updateMealPlans(existingMealPlan: mealPlan),
                            ),
                          );
                          _updateMealPlans();
                        },

                        // delete meal plan objct
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            DatabaseHelper.deleteMealPlan(mealPlan.id!);
                            _updateMealPlans();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Create the new meal plan button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealPlanScreen()),
          );
          _updateMealPlans();
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}

class UpdateMealPlanScreen {
}