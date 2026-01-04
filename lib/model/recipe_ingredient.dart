import 'package:hive/hive.dart';

part 'recipe_ingredient.g.dart'; 

@HiveType(typeId: 2) 
class RecipeIngredient {
  @HiveField(0)
  int recipeId;

  @HiveField(1)
  int ingredientId;

  @HiveField(2)
  double quantity;

  RecipeIngredient({
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
  });
}
