import 'package:flutter/material.dart';
import 'package:meal_planner/model/ingredient.dart';
import 'package:meal_planner/repository.dart';
import 'package:meal_planner/widget/slide_in_notification.dart'; 

class AddIngredientsScreen extends StatefulWidget {
  const AddIngredientsScreen({super.key});

  @override
  State<AddIngredientsScreen> createState() => _AddIngredientsScreenState();
}

class _AddIngredientsScreenState extends State<AddIngredientsScreen> {
  final repo = Repository();

  @override
  Widget build(BuildContext context) {
    final ingredients = repo.ingredientBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn nguyên liệu')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (_, i) {
                final ing = ingredients[i];
                final qtyCtl = TextEditingController();

                return ListTile(
                  title: Text(ing.name),
                  subtitle: Text('Đơn vị: ${ing.unit ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final ok = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Nhập số lượng cho ${ing.name}'),
                          content: TextField(
                            controller: qtyCtl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Số lượng'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
                          ],
                        ),
                      );

                      if (ok == true) {
                        final qty = int.tryParse(qtyCtl.text.trim()); 
                        
                        if (qty == null || qty <= 0) { 
                          showRightNotification( 
                            context, 
                            'Số lượng phải là số nguyên dương (>= 1)', 
                            NotificationType.error, 
                          ); 
                          return; 
                        } 
                        
                        Navigator.pop(context, { 
                          'ingredientId': repo.ingredientBox.keyAt(i), 
                          'quantity': qty, 
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.create),
              label: const Text('Thêm nguyên liệu mới'),
              onPressed: () async {
                final nameCtl = TextEditingController();
                final unitCtl = TextEditingController();

                final ok = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Thêm nguyên liệu mới'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Tên nguyên liệu')),
                        TextField(controller: unitCtl, decoration: const InputDecoration(labelText: 'Đơn vị')),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thêm')),
                    ],
                  ),
                );

                if (ok == true && nameCtl.text.trim().isNotEmpty) {
                  await repo.ingredientBox.add(
                    Ingredient(name: nameCtl.text.trim(), unit: unitCtl.text.trim()),
                  );
                  setState(() {});

                  showRightNotification(
                    context,
                    'Đã thêm nguyên liệu "${nameCtl.text.trim()}"',
                    NotificationType.success,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
