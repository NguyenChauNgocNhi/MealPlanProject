import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/model/meal_with_recipe.dart';
import 'package:meal_planner/state/day_provider.dart';
import 'package:meal_planner/state/meal_day_viewmodel.dart';
import 'package:meal_planner/ui/pick_recipe_screen.dart';
import 'package:meal_planner/widget/recipe_helper.dart';
import 'package:provider/provider.dart';

class MealSection extends StatelessWidget {
  final String title;
  final String mealType;

  const MealSection({
    super.key,
    required this.title,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    final day = context.watch<DayProvider>().selectedDay; // cung cấp ngày hiện tại
    final vm = context.watch<MealDayViewModel>(); // quản lý danh sách món ăn, calories, nguyên liệu

    // Lọc món theo loại bữa
    final items = vm.meals
        .where((m) => m.meal.mealType == mealType)
        .toList();

    // Recipe đã chọn
    final selected = items.map((m) => m.meal.recipeId).toSet();

    // Tổng calories
    final totalCalories = items.fold<int>(
      0,
      (sum, m) => sum + (m.recipe.calories ?? 0),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          /* ===================== HEADER ===================== */
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PickRecipeScreen(initiallySelected: selected),
                  ),
                );

                if (result == null) return;

                final dayStr =
                    DateFormat('yyyy-MM-dd').format(day);

                // Xóa món cũ
                for (final m in items) {
                  await context
                      .read<MealDayViewModel>()
                      .removeMeal(m.mealKey, dayStr);
                }

                // Thêm món mới
                if (result is List<int>) {
                  await context
                      .read<MealDayViewModel>()
                      .addMeals(dayStr, mealType, result);
                } else {
                  await context
                      .read<MealDayViewModel>()
                      .addMeal(dayStr, mealType, result as int);
                }
              },
            ),
          ),

          /* ===================== LIST ===================== */
          for (int i = 0; i < items.length; i++) ...[
            Dismissible( // cho phép vuốt để xóa món ăn
              key: ValueKey(items[i].mealKey),
              background: Container(color: Colors.red),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xóa món'),
                    content: const Text(
                        'Bạn có chắc muốn xóa món này khỏi thực đơn hôm nay?'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                context.read<MealDayViewModel>().removeMeal(
                      items[i].mealKey,
                      DateFormat('yyyy-MM-dd').format(day),
                    );
              },
              child: _MealTile(item: items[i]),
            ),
            if (i < items.length - 1)
              const SizedBox(height: 8),
          ],

          /* ===================== TOTAL ===================== */
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
                right: 16,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tổng: $totalCalories kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ===================== TILE ===================== */
// thông tin từng món ăn
class _MealTile extends StatelessWidget {
  final MealWithRecipe item;

  const _MealTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final recipe = item.recipe;

    return ListTile(
      leading: buildRecipeImage(
        recipe.image,
        recipe.category,
      ),
      title: Text(recipe.name), 
      trailing: Text('${recipe.calories ?? 0} kcal'),
    );
  }
}
