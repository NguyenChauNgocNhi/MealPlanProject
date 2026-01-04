import 'package:flutter/material.dart';
import 'package:meal_planner/model/meal_plan.dart';
import 'package:meal_planner/model/meal_with_recipe.dart';
import 'package:meal_planner/repository.dart';

                                // thông báo cho UI khi dữ liệu thay đổi
class MealDayViewModel extends ChangeNotifier {
  final Repository repo;
  MealDayViewModel(this.repo);

  List<MealWithRecipe> meals = [];
  int totalCalories = 0;
  List<Map<String, dynamic>> aggregatedIngredients = [];  // danh sách nguyên liệu đã tổng hợp (tên, đơn vị, tổng số lượng)
  bool loading = false; // trạng thái đang tải dữ liệu

  /* ===================== LOAD dữ liệu theo ngày ===================== */

  Future<void> loadForDate(String date) async {
    loading = true;
    notifyListeners();

    meals = repo.getMealsByDate(date);
    _calculateStats(date); 

    debugPrint('📅 $date | ${meals.length} món | $totalCalories kcal');

    loading = false;
    notifyListeners();
  }

  void _calculateStats(String date) {
    totalCalories = meals.fold(0, (sum, m) => sum + (m.recipe.calories ?? 0));
    aggregatedIngredients = repo.aggregatedIngredientsForDate(date); // gọi hàm trong Repository để gom nguyên liệu
  }

  /* ===================== ADD ===================== */

  Future<void> addMeal(String date, String mealType, int recipeKey) async {
    final meal = MealPlan(date: date, mealType: mealType, recipeId: recipeKey);
    final key = await repo.addMeal(meal);

    debugPrint('✅ Add meal: recipeKey=$recipeKey | mealType=$mealType | hiveKey=$key');
    await loadForDate(date);  // refresh dữ liệu
  }

  Future<void> addMeals(String date, String mealType, List<int> recipeKeys) async {
    // Duyệt danh sách recipeKeys và thêm từng món
    for (final recipeKey in recipeKeys) {
      await repo.addMeal(MealPlan(date: date, mealType: mealType, recipeId: recipeKey));
    }

    debugPrint('✅ Add ${recipeKeys.length} meals | $mealType | $date');
    await loadForDate(date); // refresh dữ liệu
  }

  /* ===================== REMOVE ===================== */

  Future<void> removeMeal(int mealKey, String date) async {
    await repo.removeMeal(mealKey);
    debugPrint('❌ Remove meal | hiveKey=$mealKey | date=$date');
    await loadForDate(date);
  }

  /* ===================== REPLACE ===================== */

  Future<void> replaceMeals(String date, String mealType, dynamic recipeKeys) async {
    // Xóa tất cả món theo loại bữa
    final oldMeals = meals.where((m) => m.meal.mealType == mealType).toList();
    for (final m in oldMeals) {
      await repo.removeMeal(m.mealKey);
    }

    // Thêm món mới
    if (recipeKeys is List<int>) {
      for (final key in recipeKeys) {
        await repo.addMeal(MealPlan(date: date, mealType: mealType, recipeId: key));
      }
    } else if (recipeKeys is int) {
      await repo.addMeal(MealPlan(date: date, mealType: mealType, recipeId: recipeKeys));
    }

    debugPrint('🔄 Replace meals | $mealType | $date');
    await loadForDate(date);
  }

  /* ===================== Lọc món theo loại bữa ===================== */

  List<MealWithRecipe> mealsByType(String mealType) {
    return meals.where((m) => m.meal.mealType == mealType).toList();
  }
}
