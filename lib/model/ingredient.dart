import 'package:hive/hive.dart';

part 'ingredient.g.dart'; 

@HiveType(typeId: 1) 
class Ingredient {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? unit;

  Ingredient({this.id, required this.name, this.unit});
}
