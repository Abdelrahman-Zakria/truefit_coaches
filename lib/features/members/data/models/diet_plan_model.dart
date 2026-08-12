import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/diet_plan_entity.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.title,
    required super.time,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fats,
    required super.items,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      calories: (map['calories'] ?? 0).toInt(),
      protein: (map['protein'] ?? 0).toInt(),
      carbs: (map['carbs'] ?? 0).toInt(),
      fats: (map['fats'] ?? 0).toInt(),
      items: List<String>.from(map['items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'items': items,
    };
  }
}

class DietPlanModel extends DietPlan {
  const DietPlanModel({
    required super.id,
    required super.totalCalories,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatsGoal,
    required super.waterGoal,
    required super.currentWater,
    required super.meals,
  });

  factory DietPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final mealsList = (data['meals'] as List<dynamic>? ?? [])
        .map((m) => MealModel.fromMap(m as Map<String, dynamic>))
        .toList();

    return DietPlanModel(
      id: doc.id,
      totalCalories: data['total_calories']?.toString() ?? '0',
      proteinGoal: data['protein_goal']?.toString() ?? '0g',
      carbsGoal: data['carbs_goal']?.toString() ?? '0g',
      fatsGoal: data['fats_goal']?.toString() ?? '0g',
      waterGoal: data['water_goal']?.toString() ?? '0',
      currentWater: (data['current_water'] ?? 0.0).toDouble(),
      meals: mealsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_calories': totalCalories,
      'protein_goal': proteinGoal,
      'carbs_goal': carbsGoal,
      'fats_goal': fatsGoal,
      'water_goal': waterGoal,
      'current_water': currentWater,
      'meals': meals.map((m) => (m as MealModel).toMap()).toList(),
    };
  }
}
