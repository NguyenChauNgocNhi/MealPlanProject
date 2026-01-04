import 'package:hive/hive.dart';

import 'model/recipe.dart';
import 'model/ingredient.dart';
import 'model/recipe_ingredient.dart';
import 'model/meal_plan.dart';
import 'model/meal_with_recipe.dart';

class Repository { 
  // Mỗi Box là một "bảng" lưu dữ liệu trong Hive
  final Box<Recipe> recipeBox = Hive.box<Recipe>('recipes');
  final Box<Ingredient> ingredientBox = Hive.box<Ingredient>('ingredients');
  final Box<RecipeIngredient> recipeIngredientBox = Hive.box<RecipeIngredient>('recipe_ingredients');
  final Box<MealPlan> mealPlanBox = Hive.box<MealPlan>('meal_plans');

  /* ===================== RECIPE ===================== */

  Future<void> addRecipe(Recipe recipe) async => recipeBox.add(recipe);

  List<Recipe> getAllRecipes() => recipeBox.values.toList();

  Recipe? getRecipeByKey(int key) => recipeBox.get(key);

  Future<void> deleteRecipe(int key) async => recipeBox.delete(key);

  /* ===================== INGREDIENT ===================== */

  Future<void> addIngredient(Ingredient ing) async => ingredientBox.add(ing);

  List<Ingredient> getAllIngredients() => ingredientBox.values.toList();

  Ingredient? getIngredientByKey(int key) => ingredientBox.get(key);

  /* ===================== RECIPE INGREDIENT ===================== */
  // Lấy danh sách nguyên liệu cho một món ăn dựa vào recipeId

  List<RecipeIngredient> getIngredientsForRecipe(int recipeKey) {
    return recipeIngredientBox.values
        .where((ri) => ri.recipeId == recipeKey)
        .toList();
  }

  /* ===================== MEAL PLAN ===================== */

  Future<int> addMeal(MealPlan meal) async {
    return await mealPlanBox.add(meal);
  }

  Future<void> removeMeal(int key) async => mealPlanBox.delete(key);

  /// Lấy danh sách món theo ngày 
  List<MealWithRecipe> getMealsByDate(String date) {
    final result = <MealWithRecipe>[];

    for (var i = 0; i < mealPlanBox.length; i++) {
      final meal = mealPlanBox.getAt(i);
      if (meal == null || meal.date != date) continue;

      final recipe = recipeBox.get(meal.recipeId);
      if (recipe == null) continue;

      result.add(
        MealWithRecipe(
          mealKey: mealPlanBox.keyAt(i),
          meal: meal,
          recipe: recipe,
        ),
      );
    }

    return result;
  }

  /// Tổng calories trong ngày (Dùng fold để cộng dồn calories của tất cả món ăn trong ngày)
  int totalCaloriesForDate(String date) {
    return getMealsByDate(date).fold(
      0,
      (sum, m) => sum + (m.recipe.calories ?? 0),
    );
  }

  /// Tổng hợp nguyên liệu trong ngày
  List<Map<String, dynamic>> aggregatedIngredientsForDate(String date) {
    final meals = getMealsByDate(date);
    final Map<int, double> ingredientTotals = {}; // Dùng map để cộng dồn nhanh theo ingredientId
    // Lấy tất cả món ăn trong ngày
    for (final m in meals) {
      final recipeIngredients =
          getIngredientsForRecipe(m.meal.recipeId);
      // Duyệt từng nguyên liệu của món, nếu nguyên liệu chưa có trong map thì mặc định 0 rồi cộng thêm
      for (final ri in recipeIngredients) {
        ingredientTotals[ri.ingredientId] =
            (ingredientTotals[ri.ingredientId] ?? 0) + ri.quantity;
      }
    }

    return ingredientTotals.entries // (cặp id–tổng số lượng)
        .map((e) {
          // Lấy object Ingredient
          final ing = ingredientBox.get(e.key);
          if (ing == null) return null;
          
          return {
            'name': ing.name,
            'unit': ing.unit,
            'total_qty': e.value,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}
