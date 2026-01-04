import 'package:flutter/material.dart';

class IngredientSummary extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  const IngredientSummary({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Không có nguyên liệu nào cho hôm nay',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Nguyên liệu cần cho hôm nay',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...ingredients.map((row) => ListTile(
              title: Text(row['name'] as String),
              subtitle: Text('${row['total_qty']} ${row['unit'] ?? ''}'),
            )),
      ],
    );
  }
}
