import 'package:assign3_calorie_calculator/models/meal_plan.dart';
import 'package:assign3_calorie_calculator/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/databasehelper.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class MealPlanSearch extends SearchDelegate<MealPlan> {
  final List<MealPlan> mealPlans;

  MealPlanSearch(this.mealPlans);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // If the query is not empty, clear it; otherwise, close with null
        if (query.isEmpty) {
        } else {
          query = '';
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final searchResults = query.isEmpty
        ? mealPlans
        : mealPlans.where((plan) {
      // Check if any food item contains the search query
      return plan.mealSelection.any((food) =>
          food.item.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        MealPlan mealPlan = searchResults[index];
        return ListTile(
          title: Text('Meal Plan on ${DateFormat('yyyy-MM-dd').format(mealPlan.date)}'),
          subtitle: Text('Total Calories: ${mealPlan.totalCalories}'),
          onTap: () {
            close(context, mealPlan);
          },
        );
      },
    );
  }
}


class _HomeState extends State<Home> {

  List<MealPlan> savedPlans = [];


  Future<void> _updateMealPlans() async {
      List<MealPlan> plans = await DatabaseHelper.getAllMealPlans();
      setState(() {
        savedPlans = plans;
      });
  }

  @override
  void initState() {
    super.initState();
    _updateMealPlans();
  }

  // Home Page Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[477],
      appBar: AppBar(
        title: const Text('Meal Plan App'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final MealPlan? result = await showSearch(
                context: context,
                delegate: MealPlanSearch(savedPlans),
              );

              // Handle the result, if needed
              if (result != null) {
                // Do something with the selected meal plan
              }
            },
          ),
        ],
      ),


      body: savedPlans.isEmpty
          ? const Center(
          child: Text(
              'No meal plans currently saved',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IndieFlower'
              )
          )
      )
          : ListView.builder(
        itemCount: savedPlans.length,
        itemBuilder: (context, index) {
          MealPlan mealPlan = savedPlans[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    'Meal Plan on ${DateFormat('yyyy-MM-dd').format(mealPlan.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Container(height: 1, color: Colors.black),  // Straight black line
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          'Your Total Calories: ${mealPlan.totalCalories}',
                          style: const TextStyle(
                            color: Colors.red,  // Set text color to red
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ...mealPlan.mealSelection.map(
                            (food) => Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Text('${food.item} - ${food.calories} cal'),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to MealPlanScreen with the selected meal plan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealPlanScreen(existingMealPlan: mealPlan),
                      ),
                    ).then((value) {
                      // Refresh the list if the meal plan was updated
                      if (value == true) {
                        _updateMealPlans();
                      }
                    });
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  // delete meal plan
                  child: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.deepOrange),
                    onPressed: () {
                      DatabaseHelper.deleteMealPlan(mealPlan.num!);
                      _updateMealPlans();
                    },
                  ),
                ),
              ],
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        onPressed: () { Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealPlanScreen())
        ); },
        elevation: 6.0,
        child: const Icon(
          Icons.note_add_sharp,
          size: 20.0,
        ),
      ),
    );
  }
}
