import 'package:flutter/material.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/repository.dart';
import 'package:meal_planner/widget/category_helper.dart';
import 'package:meal_planner/widget/recipe_helper.dart';
import 'package:meal_planner/widget/slide_in_notification.dart';

class PickRecipeScreen extends StatefulWidget {
  final Set<dynamic> initiallySelected; // tập hợp các món đã được chọn trước đó
  const PickRecipeScreen({super.key, required this.initiallySelected});

  @override
  State<PickRecipeScreen> createState() => _PickRecipeScreenState();
}

class _PickRecipeScreenState extends State<PickRecipeScreen> {
  final repo = Repository();
  List<MapEntry<dynamic, Recipe>> items = [];
  String query = '';
  final Set<dynamic> selectedKeys = {};

  @override
  void initState() {
    super.initState();
    selectedKeys.addAll(widget.initiallySelected);
    _filter('');
  }
  // Lọc danh sách món ăn theo tên
  void _filter(String q) {
    query = q;
    final entries = repo.recipeBox.toMap().entries.toList();
    items = q.isEmpty
        ? entries
        : entries.where((e) => e.value.name.toLowerCase().contains(q.toLowerCase())).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn món'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm món...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Không tìm thấy món'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final entry = items[i];
                final key = entry.key;
                final r = entry.value;
                final isSelected = selectedKeys.contains(key);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) { 
                      setState(() { 
                        if (checked == true) { 
                          selectedKeys.add(key); 
                          showRightNotification( 
                            context, 
                            'Đã chọn món: ${r.name}', 
                            NotificationType.success, 
                          ); 
                        } 
                        else { 
                          selectedKeys.remove(key); 
                          showRightNotification( 
                            context, 
                            'Bỏ chọn món: ${r.name}', 
                            NotificationType.warning, 
                          ); 
                        } 
                      }); 
                    },
                    secondary: buildRecipeImage(r.image, r.category),
                    title: Text(r.name),
                    subtitle: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [ 
                        Text('${viCategory(r.category)} • ${r.calories ?? 0} kcal'), 
                        if (r.description != null && r.description!.isNotEmpty) 
                          Text( 
                            r.description!, 
                            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13), 
                          ), 
                      ], 
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Xác nhận'),
          onPressed: () { 
            final selectedList = selectedKeys.cast<int>().toList(); 
            showRightNotification( 
              context, 
              'Đã chọn ${selectedList.length} món', 
              NotificationType.info, 
            );
            Navigator.pop(context, selectedList);
          },
        ),
      ),
    );
  }
}
