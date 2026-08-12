import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String id;
  final String title;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<String> items;

  const Meal({
    required this.id,
    required this.title,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.items,
  });

  @override
  List<Object?> get props => [id, title, time, calories, protein, carbs, fats, items];
}

class DietPlan extends Equatable {
  final String id;
  final String totalCalories;
  final String proteinGoal;
  final String carbsGoal;
  final String fatsGoal;
  final String waterGoal;
  final double currentWater;
  final List<Meal> meals;

  const DietPlan({
    required this.id,
    required this.totalCalories,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatsGoal,
    required this.waterGoal,
    required this.currentWater,
    required this.meals,
  });

  @override
  List<Object?> get props => [id, totalCalories, proteinGoal, carbsGoal, fatsGoal, waterGoal, currentWater, meals];
}
