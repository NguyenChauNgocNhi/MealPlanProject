import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/state/day_provider.dart';
import 'package:meal_planner/state/meal_day_viewmodel.dart';
import 'package:meal_planner/ui/chatbot_screen.dart';
import 'package:meal_planner/ui/recipe_list_screen.dart';
import 'package:meal_planner/widget/ingredient_summary.dart';
import 'package:meal_planner/widget/meal_section.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.watch<DayProvider>().selectedDay;
    final vm = context.watch<MealDayViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.loading) vm.loadForDate(DateFormat('yyyy-MM-dd').format(selectedDay));
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', height: 32),
            const SizedBox(width: 8),
            Text('Thực đơn ${DateFormat('dd/MM/yyyy').format(selectedDay)}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                context.read<DayProvider>().setDay(picked);
              }
            },
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  title: const Text('Tổng calo'),
                  trailing: Text('${vm.totalCalories} kcal'),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const MealSection(title: 'Bữa sáng', mealType: 'breakfast'),
                      const MealSection(title: 'Bữa trưa', mealType: 'lunch'),
                      const MealSection(title: 'Bữa tối', mealType: 'dinner'),
                      const MealSection(title: 'Ăn vặt', mealType: 'snack'),
                      const Divider(), // widget đường kẻ ngang dùng để phân tách nội dung
                      IngredientSummary(ingredients: vm.aggregatedIngredients),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatBotScreen()),
            ),
            icon: const Icon(Icons.chat),
            label: const Text('Gợi ý thực đơn'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeListScreen()),
            ),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Quản lý món'),
          ),
        ],
      ),
    );
  }
}
