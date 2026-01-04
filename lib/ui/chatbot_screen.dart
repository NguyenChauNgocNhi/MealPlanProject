import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/model/meal_plan.dart';
import 'package:meal_planner/repository.dart';
import 'package:meal_planner/state/day_provider.dart';
import 'package:meal_planner/state/meal_day_viewmodel.dart';
import 'package:meal_planner/widget/slide_in_notification.dart';
import 'package:meal_planner/widget/recipe_helper.dart';
import 'package:meal_planner/widget/category_helper.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final repo = Repository();
  final controller = TextEditingController();
  String selectedMealType = 'breakfast';

  // Gợi ý sẽ là danh sách MapEntry để có cả key (Hive) và Recipe (value)
  List<MapEntry<dynamic, Recipe>> suggestions = [];
  Set<dynamic> selectedKeys = {};
  int totalCalories = 0;

  void suggestRecipes(int targetCalories) {
    // lấy toàn bộ entries: key (Hive) và value (Recipe)
    final entries = repo.recipeBox.toMap().entries.toList();

    // lọc theo loại bữa (category)
    final filtered = entries.where((e) => e.value.category == selectedMealType).toList();
    filtered.sort((a, b) => (a.value.calories ?? 0).compareTo(b.value.calories ?? 0));

    final result = <MapEntry<dynamic, Recipe>>[];
    int total = 0;

    for (final e in filtered) {
      final cal = e.value.calories ?? 0;
      if (total + cal <= targetCalories) {
        result.add(e);
        total += cal;
      }
    }

    setState(() {
      suggestions = result;
      selectedKeys = result.map((e) => e.key).toSet(); // mặc định chọn hết
      totalCalories = total;
    });
  }

  Future<void> addToMealPlanToday(BuildContext context) async {
    if (selectedKeys.isEmpty) return;

    final day = context.read<DayProvider>().selectedDay;
    final dayStr = DateFormat('yyyy-MM-dd').format(day);

    for (final key in selectedKeys) {
      final meal = MealPlan(date: dayStr, mealType: selectedMealType, recipeId: key);
      await repo.addMeal(meal);
    }

    context.read<MealDayViewModel>().loadForDate(dayStr);

    showRightNotification( 
      context, 
      'Đã thêm ${selectedKeys.length} món vào thực đơn hôm nay!', 
      NotificationType.success, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gợi Ý Thực Đơn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedMealType,
              items: const [
                DropdownMenuItem(value: 'breakfast', child: Text('Bữa sáng')),
                DropdownMenuItem(value: 'lunch', child: Text('Bữa trưa')),
                DropdownMenuItem(value: 'dinner', child: Text('Bữa tối')),
                DropdownMenuItem(value: 'snack', child: Text('Ăn vặt')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => selectedMealType = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nhập số calo mong muốn',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) { 
                final cal = int.tryParse(value);
                if (cal != null && cal > 0) { 
                  suggestRecipes(cal); 
                } else { 
                  showRightNotification( 
                    context, 
                    'Vui lòng nhập số calo hợp lệ (>= 1)', 
                    NotificationType.error, 
                  ); 
                } 
              },
            ),
            const SizedBox(height: 16),
            if (suggestions.isNotEmpty)
              Text(
                'Gợi ý cho ${viCategory(selectedMealType)} khoảng $totalCalories kcal:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (_, i) {
                  final entry = suggestions[i];
                  final key = entry.key;
                  final r = entry.value;
                  final isSelected = selectedKeys.contains(key);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedKeys.add(key);
                        } else {
                          selectedKeys.remove(key);
                        }
                      });
                    },
                    secondary: buildRecipeImage(r.image, r.category),
                    title: Text(r.name),
                    subtitle: Text('${r.calories ?? 0} kcal'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addToMealPlanToday(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm vào thực đơn hôm nay'),
      ),
    );
  }
}
