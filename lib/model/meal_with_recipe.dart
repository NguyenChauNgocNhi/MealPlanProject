import 'meal_plan.dart';
import 'recipe.dart';

/// Model trung gian dùng cho View / ViewModel

class MealWithRecipe {
  final int mealKey;     // Hive key của MealPlan
  final MealPlan meal;   // Dữ liệu kế hoạch bữa ăn
  final Recipe recipe;   // Dữ liệu món ăn

  const MealWithRecipe({
    required this.mealKey,
    required this.meal,
    required this.recipe,
  });
}
