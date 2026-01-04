import 'package:flutter/material.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/model/recipe_ingredient.dart';
import 'package:meal_planner/repository.dart';
import 'package:meal_planner/ui/add_ingredients_screen.dart';
import 'package:meal_planner/widget/slide_in_notification.dart';
import 'package:meal_planner/widget/recipe_image_picker.dart'; 

class RecipeEditScreen extends StatefulWidget {
  final Recipe? recipe;
  final dynamic hiveKey;
  const RecipeEditScreen({super.key, this.recipe, this.hiveKey});

  @override
  State<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  final repo = Repository();
  // Các TextEditingController quản lý nội dung nhập trong TextField
  final nameCtl = TextEditingController();
  final descCtl = TextEditingController();
  final calCtl = TextEditingController();
  final imageCtl = TextEditingController();
  String category = 'lunch';

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    if (r != null) {
      nameCtl.text = r.name;
      descCtl.text = r.description ?? '';
      calCtl.text = r.calories?.toString() ?? '';
      category = r.category ?? 'lunch';
      imageCtl.text = r.image ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeKey = widget.hiveKey;
    // Nếu có recipeKey, lọc nguyên liệu thuộc món ăn đó
    final recipeIngredients = recipeKey == null
        ? []
        : repo.recipeIngredientBox.values
            .where((ri) => ri.recipeId == recipeKey)
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe == null ? 'Thêm món' : 'Sửa món')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Tên món')),
            TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Mô tả')),
            TextField(controller: calCtl, decoration: const InputDecoration(labelText: 'Calo'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: 'breakfast', child: Text('Bữa sáng')),
                DropdownMenuItem(value: 'lunch', child: Text('Bữa trưa')),
                DropdownMenuItem(value: 'dinner', child: Text('Bữa tối')),
                DropdownMenuItem(value: 'snack', child: Text('Ăn vặt')),
              ],
              onChanged: (v) => setState(() => category = v ?? 'lunch'),
              decoration: const InputDecoration(labelText: 'Loại bữa'),
            ),

            const SizedBox(height: 16),
            RecipeImagePicker(
              initialPath: imageCtl.text,
              onImageSelected: (path, bytes) {
                setState(() {
                  imageCtl.text = path;
                });
              },
            ),

            const SizedBox(height: 16),
            if (recipeIngredients.isNotEmpty) ...[
              const Text('Nguyên liệu:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recipeIngredients.map((ri) {
                final ing = repo.ingredientBox.get(ri.ingredientId);
                return ListTile(
                  title: Text('${ing?.name ?? ''}'),
                  subtitle: Text('${ri.quantity} ${ing?.unit ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xóa nguyên liệu'),
                          content: const Text('Bạn có chắc muốn xóa nguyên liệu này?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final entries = repo.recipeIngredientBox.toMap();
                        final key = entries.entries.firstWhere((e) => e.value == ri).key;
                        await repo.recipeIngredientBox.delete(key);
                        setState(() {});
                        showRightNotification(context, 'Đã xóa nguyên liệu', NotificationType.info);
                      }
                    },
                  ),
                );
              }),
            ],

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm nguyên liệu'),
              onPressed: () async {
                if (recipeKey == null) {
                  showRightNotification(context, 'Vui lòng lưu món ăn trước khi thêm nguyên liệu', NotificationType.warning);
                  return;
                }
                final ing = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddIngredientsScreen()),
                );
                if (ing != null) {
                  await repo.recipeIngredientBox.add(
                    RecipeIngredient(
                      recipeId: recipeKey,
                      ingredientId: ing['ingredientId'],
                      quantity: ing['quantity'],
                    ),
                  );
                  showRightNotification(context, 'Đã thêm nguyên liệu thành công', NotificationType.success);
                  setState(() {});
                }
              },
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameCtl.text.trim().isEmpty) {
                  showRightNotification(context, 'Tên món không được để trống', NotificationType.error);
                  return;
                }

                final calText = calCtl.text.trim();
                final cal = int.tryParse(calText);
                if (calText.isEmpty || cal == null) {
                  showRightNotification(context, 'Calo phải là số hợp lệ', NotificationType.error);
                  return;
                }

                final imagePath = imageCtl.text.trim().isNotEmpty
                    ? imageCtl.text.trim()
                    : 'assets/images/no_image.jpg';

                final recipe = Recipe(
                  name: nameCtl.text.trim(),
                  description: descCtl.text.trim().isEmpty ? null : descCtl.text.trim(),
                  calories: cal,
                  category: category,
                  image: imagePath,
                );

                dynamic key = widget.hiveKey;
                if (key == null) {
                  key = await repo.recipeBox.add(recipe);
                } else {
                  await repo.recipeBox.put(key, recipe);
                }

                if (mounted) Navigator.pop(context, key);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
