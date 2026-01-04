import 'package:hive/hive.dart';

part 'meal_plan.g.dart';

@HiveType(typeId: 3)
class MealPlan {
  @HiveField(0)
  final String date; // yyyy-MM-dd

  @HiveField(1)
  final String mealType; // breakfast / lunch / dinner / snack

  @HiveField(2)
  final int recipeId; // Hive key của Recipe

  const MealPlan({
    required this.date,
    required this.mealType,
    required this.recipeId,
  });
}
