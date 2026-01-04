import 'package:flutter/material.dart';
import 'package:meal_planner/ui/recipe_edit_screen.dart';
import 'package:meal_planner/widget/category_helper.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/repository.dart';
import 'package:meal_planner/widget/recipe_helper.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final repo = Repository();
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      recipes = repo.getAllRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý món')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (_, i) {
          final r = recipes[i];
          final key = repo.recipeBox.keyAt(i) as int; // Hive key

          // Lấy nguyên liệu liên kết với món này
          final recipeIngredients = repo.recipeIngredientBox.values
              .where((ri) => ri.recipeId == key)
              .toList();

          final ingNames = recipeIngredients.map((ri) {
            final ing = repo.ingredientBox.get(ri.ingredientId);
            return '${ing?.name ?? ''} (${ri.quantity} ${ing?.unit ?? ''})';
          }).join(', ');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: buildRecipeImage(r.image, r.category),
              title: Text(r.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${viCategory(r.category)} • ${r.calories ?? 0} kcal'),
                  if (ingNames.isNotEmpty) Text('Nguyên liệu: $ingNames'),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeEditScreen(recipe: r, hiveKey: key),
                  ),
                );
                _load();
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Xóa món'),
                      content: const Text('Bạn có chắc muốn xóa món này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await repo.deleteRecipe(key);
                    _load();
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
          );
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
