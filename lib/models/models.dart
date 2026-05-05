class FoodEntry {
  final int? id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double grams;
  final String date;
  final String meal;

  FoodEntry({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.grams,
    required this.date,
    required this.meal,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'grams': grams,
    'date': date,
    'meal': meal,
  };

  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry(
    id: map['id'],
    name: map['name'],
    calories: map['calories'].toDouble(),
    protein: map['protein'].toDouble(),
    carbs: map['carbs'].toDouble(),
    fat: map['fat'].toDouble(),
    grams: map['grams'].toDouble(),
    date: map['date'],
    meal: map['meal'],
  );
}

class DayLog {
  final String date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double water;
  final int steps;

  DayLog({
    required this.date,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.water = 0,
    this.steps = 0,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'water': water,
    'steps': steps,
  };

  factory DayLog.fromMap(Map<String, dynamic> map) => DayLog(
    date: map['date'],
    calories: (map['calories'] ?? 0).toDouble(),
    protein: (map['protein'] ?? 0).toDouble(),
    carbs: (map['carbs'] ?? 0).toDouble(),
    fat: (map['fat'] ?? 0).toDouble(),
    water: (map['water'] ?? 0).toDouble(),
    steps: (map['steps'] ?? 0).toInt(),
  );
}

class UserGoals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double water;
  final int steps;

  UserGoals({
    this.calories = 2000,
    this.protein = 150,
    this.carbs = 200,
    this.fat = 60,
    this.water = 2.5,
    this.steps = 8000,
  });

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'water': water,
    'steps': steps,
  };

  factory UserGoals.fromMap(Map<String, dynamic> map) => UserGoals(
    calories: (map['calories'] ?? 2000).toDouble(),
    protein: (map['protein'] ?? 150).toDouble(),
    carbs: (map['carbs'] ?? 200).toDouble(),
    fat: (map['fat'] ?? 60).toDouble(),
    water: (map['water'] ?? 2.5).toDouble(),
    steps: (map['steps'] ?? 8000).toInt(),
  );
}

class UserProfile {
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final String activity;

  const UserProfile({
    this.name = '',
    this.age = 25,
    this.weight = 70,
    this.height = 170,
    this.gender = 'Hombre',
    this.goal = 'Definición',
    this.activity = 'moderate',
  });

  // Solo para SharedPreferences
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'goal': goal,
    'activity': activity,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    age: json['age'] ?? 25,
    weight: (json['weight'] ?? 70).toDouble(),
    height: (json['height'] ?? 170).toDouble(),
    gender: json['gender'] ?? 'Hombre',
    goal: json['goal'] ?? 'Definición',
    activity: json['activity'] ?? 'moderate',
  );
}