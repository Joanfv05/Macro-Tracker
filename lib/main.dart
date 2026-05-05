import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/nutrition_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // Sin overlays (sin barra de navegación ni de estado)
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final nutritionProvider = NutritionProvider();
  await nutritionProvider.init();

  runApp(MacroTrackerApp(nutritionProvider: nutritionProvider));
}

class MacroTrackerApp extends StatelessWidget {
  final NutritionProvider nutritionProvider;

  const MacroTrackerApp({super.key, required this.nutritionProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: nutritionProvider,
      child: MaterialApp(
        title: 'Macro Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D4AA),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}