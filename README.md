# Macro Tracker 💪

App de seguimiento de macros para definición. Simple, local, **gratis para siempre**.

## Funcionalidades

- **Dashboard diario**: anillo de calorías + barras de proteína/carbs/grasas
- **Agua y pasos**: registro rápido con tap
- **Añadir comida**: búsqueda en Open Food Facts (base de datos mundial, gratis) o entrada manual
- **Historial**: gráficas de barras de los últimos 14 días con línea de objetivo
- **Objetivos**: fija tus macros manualmente o usa la calculadora integrada (Harris-Benedict)
- Navegar entre días con flechas
- Swipe para borrar alimentos

## Setup en Android Studio

### 1. Requisitos
- Flutter SDK 3.x instalado
- Android Studio con plugin Flutter
- Android SDK (API 21+)

### 2. Abrir el proyecto
```bash
# Abre Android Studio → Open → selecciona esta carpeta
# o desde terminal:
cd macro_tracker
flutter pub get
flutter run
```

### 3. Dependencias clave
- `sqflite` — base de datos local SQLite (sin servidor, sin cuenta)
- `provider` — gestión de estado
- `fl_chart` — gráficas de barras
- `http` — llamadas a Open Food Facts API

## Estructura
```
lib/
  main.dart               ← Entrada
  models/models.dart      ← FoodEntry, DayLog, UserGoals
  services/
    database_service.dart ← SQLite
    food_api_service.dart ← Open Food Facts
  providers/
    nutrition_provider.dart ← Estado global
  screens/
    home_screen.dart      ← Navegación
    dashboard_screen.dart ← Pantalla principal
    add_food_screen.dart  ← Búsqueda + manual
    history_screen.dart   ← Gráficas
    settings_screen.dart  ← Objetivos
  widgets/
    macro_ring.dart       ← Anillo de calorías
    stat_card.dart        ← Tarjeta agua/pasos
```

## Personalización rápida
- Cambia los colores en `main.dart` (seedColor) y en cada pantalla
- El cálculo de macros usa Harris-Benedict para hombre. Ajusta `settings_screen.dart` si quieres
- La edad está fijada a 21 en la calculadora — cámbiala en `_CalcCardState._calculate()`

## Privacidad
Todo se guarda **localmente** en tu teléfono. Cero servidores, cero cuenta, cero datos enviados a nadie.
La búsqueda de alimentos consulta open food facts (openfoodfacts.org) que es open source y sin tracking.
