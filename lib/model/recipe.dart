import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  int? calories;

  @HiveField(3)
  String? category;

  @HiveField(4)
  String? image;

  Recipe({
    required this.name,
    this.description,
    this.calories,
    this.category,
    this.image,
  });
}


// flutter pub run build_runner build