import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_planner/state/day_provider.dart';
import 'package:meal_planner/state/meal_day_viewmodel.dart';
import 'package:meal_planner/model/ingredient.dart';
import 'package:meal_planner/model/meal_plan.dart';
import 'package:meal_planner/model/recipe.dart';
import 'package:meal_planner/model/recipe_ingredient.dart';
import 'package:meal_planner/ui/home_screen.dart';
import 'package:provider/provider.dart';
import 'repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter binding được khởi tạo trước khi chạy bất kỳ async code nào await Hive.initFlutter();
  await Hive.initFlutter(); // khởi tạo Hive để dùng trong Flutter

  // cần một TypeAdapter để Hive biết cách đọc/ghi dữ liệu nhị phân.
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(MealPlanAdapter());
  Hive.registerAdapter(RecipeIngredientAdapter());

  await Hive.openBox<Recipe>('recipes');
  final recipeBox = Hive.box<Recipe>('recipes');
  if (recipeBox.isEmpty) {
    recipeBox.addAll([
      Recipe(
        name: 'Bún bò',
        description: 'Bún bò Huế thơm ngon',
        calories: 450,
        category: 'breakfast',
        image: 'assets/images/bunbo.jpg',
      ),
      Recipe(
        name: 'Cơm gà',
        description: 'Cơm gà xối mỡ giòn tan',
        calories: 520,
        category: 'lunch',
        image: 'assets/images/comga.jpg',
      ),
      Recipe(
        name: 'Sữa bò',
        description: 'Ly sữa bò tươi thơm ngon, giàu dinh dưỡng',
        calories: 150, 
        category: 'breakfast', 
        image: 'assets/images/suabo.jpg', 
      ),

      Recipe(
        name: 'Sữa đậu nành',
        description: 'Sữa đậu nành thanh mát, bổ dưỡng',
        calories: 120, 
        category: 'breakfast',
        image: 'assets/images/suadaunanh.jpg',
      ),
      Recipe(
        name: 'Canh chua cá lóc',
        description: 'Canh chua cá lóc miền Tây',
        calories: 300,
        category: 'dinner',
        image: 'assets/images/canhchua.jpg',
      ),
      Recipe(
        name: 'Cơm tấm sườn',
        description: 'Cơm tấm với sườn nướng và mỡ hành',
        calories: 550,
        category: 'lunch',
        image: 'assets/images/thitnuong.jpg',
      ),
      Recipe(
        name: 'Gỏi cuốn',
        description: 'Gỏi cuốn tôm thịt ăn kèm nước chấm chua ngọt',
        calories: 250,
        category: 'snack',
        image: 'assets/images/goicuon.jpg',
      ),
      Recipe(
        name: 'Bánh mì thịt',
        description: 'Bánh mì Việt Nam với pate, thịt nguội và rau thơm',
        calories: 380,
        category: 'breakfast',
        image: 'assets/images/banhmithit.jpg',
      ),
      Recipe(
        name: 'Cháo gà',
        description: 'Cháo gà thơm mềm, ăn kèm hành phi và tiêu',
        calories: 320,
        category: 'dinner',
        image: 'assets/images/chaoga.jpg',
      ),
      Recipe(
        name: 'Bánh tráng trộn',
        description: 'Bánh tráng trộn với xoài, bò khô, rau răm',
        calories: 280,
        category: 'snack',
        image: 'assets/images/banhtrangtron.jpg',
      ),
      Recipe(
        name: 'Xôi đậu phộng',
        description: 'Xôi nóng ăn kèm muối mè',
        calories: 320,
        category: 'snack',
        image: 'assets/images/xoidauphong.jpg',
      ),
      Recipe(
        name: 'Bánh flan',
        description: 'Bánh flan mềm mịn với caramel',
        calories: 200,
        category: 'snack',
        image: 'assets/images/banhflan.jpg',
      ),
      Recipe(
        name: 'Trái cây dĩa',
        description: 'Dĩa trái cây tươi mát gồm dưa hấu, xoài, nho',
        calories: 150,
        category: 'snack',
        image: 'assets/images/traicaydia.jpg',
      ),
      Recipe(
        name: 'Sữa chua nếp cẩm',
        description: 'Sữa chua ăn kèm nếp cẩm dẻo thơm',
        calories: 220,
        category: 'snack',
        image: 'assets/images/suachuanepcam.jpg',
      ),
    ]);
  }

  await Hive.openBox<Ingredient>('ingredients');
  final ingredientBox = Hive.box<Ingredient>('ingredients');
  if (ingredientBox.isEmpty) {
    ingredientBox.addAll([
      Ingredient(name: 'Thịt bò', unit: 'g'),
      Ingredient(name: 'Thịt heo', unit: 'g'),
      Ingredient(name: 'Thịt gà', unit: 'g'),
      Ingredient(name: 'Tôm', unit: 'g'),
      Ingredient(name: 'Mực', unit: 'g'),
      Ingredient(name: 'Cua', unit: 'g'),
      Ingredient(name: 'Cá lóc', unit: 'g'),
      Ingredient(name: 'Bún', unit: 'g'),
      Ingredient(name: 'Gạo', unit: 'g'),
      Ingredient(name: 'Nếp', unit: 'g'),
      Ingredient(name: 'Rau sống', unit: 'g'),
      Ingredient(name: 'Bánh tráng', unit: 'g'),
      Ingredient(name: 'Trứng gà', unit: 'quả'),
      Ingredient(name: 'Đậu phộng', unit: 'g'),
      Ingredient(name: 'Sữa chua', unit: 'hũ'),
      Ingredient(name: 'Trái cây', unit: 'phần'),
      Ingredient(name: 'Hành lá', unit: 'g'),
      Ingredient(name: 'Tỏi', unit: 'tép'),
      Ingredient(name: 'Nước mắm', unit: 'ml'),
      Ingredient(name: 'Muối', unit: 'g'),
      Ingredient(name: 'Đường', unit: 'g'),
      Ingredient(name: 'Cà chua', unit: 'quả'),
      Ingredient(name: 'Thơm', unit: 'g'),
    ]);
  }

  await Hive.openBox<RecipeIngredient>('recipe_ingredients'); 
  final recipeIngredientBox = Hive.box<RecipeIngredient>('recipe_ingredients');
  if (recipeIngredientBox.isEmpty) {
    // Lấy key của từng nguyên liệu
    final ingKeys = ingredientBox.keys.toList();

    recipeIngredientBox.addAll([
      RecipeIngredient(recipeId: 0, ingredientId: ingKeys[0], quantity: 100), // Thịt bò
      RecipeIngredient(recipeId: 0, ingredientId: ingKeys[7], quantity: 200), // Bún
      RecipeIngredient(recipeId: 0, ingredientId: ingKeys[10], quantity: 50), // Rau sống
      RecipeIngredient(recipeId: 0, ingredientId: ingKeys[16], quantity: 10), // Hành lá
      RecipeIngredient(recipeId: 0, ingredientId: ingKeys[18], quantity: 20), // Nước mắm        

      RecipeIngredient(recipeId: 1, ingredientId: ingKeys[2], quantity: 150), // Thịt gà
      RecipeIngredient(recipeId: 1, ingredientId: ingKeys[8], quantity: 200), // Gạo
      RecipeIngredient(recipeId: 1, ingredientId: ingKeys[16], quantity: 10), // Hành lá
      RecipeIngredient(recipeId: 1, ingredientId: ingKeys[17], quantity: 2),  // Tỏi

      RecipeIngredient(recipeId: 4, ingredientId: ingKeys[6], quantity: 200), // Cá lóc
      RecipeIngredient(recipeId: 4, ingredientId: ingKeys[21], quantity: 1),  // Cà chua
      RecipeIngredient(recipeId: 4, ingredientId: ingKeys[22], quantity: 50), // Thơm

      RecipeIngredient(recipeId: 6, ingredientId: ingKeys[3], quantity: 50),  // Tôm
      RecipeIngredient(recipeId: 6, ingredientId: ingKeys[11], quantity: 2),  // Bánh tráng
      RecipeIngredient(recipeId: 6, ingredientId: ingKeys[10], quantity: 30), // Rau sống

      RecipeIngredient(recipeId: 7, ingredientId: ingKeys[1], quantity: 100), // Thịt heo
      RecipeIngredient(recipeId: 7, ingredientId: ingKeys[10], quantity: 20), // Rau sống 

      RecipeIngredient(recipeId: 8, ingredientId: ingKeys[2], quantity: 100), // Thịt gà
      RecipeIngredient(recipeId: 8, ingredientId: ingKeys[8], quantity: 50),  // Gạo
      RecipeIngredient(recipeId: 8, ingredientId: ingKeys[16], quantity: 10), // Hành lá

      RecipeIngredient(recipeId: 9, ingredientId: ingKeys[11], quantity: 1),  // Bánh tráng
      RecipeIngredient(recipeId: 9, ingredientId: ingKeys[13], quantity: 30), // Đậu phộng

      RecipeIngredient(recipeId: 10, ingredientId: ingKeys[9], quantity: 200),   // Nếp
      RecipeIngredient(recipeId: 10, ingredientId: ingKeys[13], quantity: 50),  // Đậu phộng
      RecipeIngredient(recipeId: 10, ingredientId: ingKeys[19], quantity: 5),   // Muối
      RecipeIngredient(recipeId: 10, ingredientId: ingKeys[20], quantity: 10),  // Đường

      RecipeIngredient(recipeId: 11, ingredientId: ingKeys[12], quantity: 2),   // Trứng gà
      RecipeIngredient(recipeId: 11, ingredientId: ingKeys[20], quantity: 30),  // Đường

      RecipeIngredient(recipeId: 13, ingredientId: ingKeys[14], quantity: 1),   // Sữa chua
      RecipeIngredient(recipeId: 13, ingredientId: ingKeys[9], quantity: 50),   // Nếp
      RecipeIngredient(recipeId: 13, ingredientId: ingKeys[20], quantity: 10),  // Đường
    ]);
  }

  await Hive.openBox<MealPlan>('meal_plans');

  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DayProvider()),
        ChangeNotifierProvider(create: (_) => MealDayViewModel(repo)),
      ],
      child: MaterialApp(
        title: 'Thực đơn hằng ngày',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}

