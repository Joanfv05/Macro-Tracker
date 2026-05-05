import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'dart:async';

class NutritionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  UserGoals _goals = UserGoals();
  UserProfile _profile = const UserProfile();
  DayLog _dayLog = DayLog(date: '');
  List<FoodEntry> _foods = [];
  String _selectedDate = '';

  Timer? _refreshTimer;

  UserGoals get goals => _goals;
  UserProfile get profile => _profile;
  DayLog get dayLog => _dayLog;
  List<FoodEntry> get foods => _foods;
  String get selectedDate => _selectedDate;

  String get formattedDate {
    final parts = _selectedDate.split('-');
    if (parts.length != 3) return '';
    final month = _getMonthName(int.parse(parts[1]));
    return '${parts[2]} $month';
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  double get waterProgress => _goals.water > 0 ? (_dayLog.water / _goals.water).clamp(0.0, 1.0) : 0.0;
  double get stepsProgress => _goals.steps > 0 ? (_dayLog.steps / _goals.steps).clamp(0.0, 1.0) : 0.0;

  List<DayLog> _weekHistory = [];
  List<DayLog> get weekHistory => _weekHistory;

  Future<void> init() async {
    _selectedDate = _getToday();
    await Future.wait([
      _loadGoals(),
      _loadProfile(),
      _loadData(),
    ]);
    _startAutoRefresh();
  }

  String _getToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final today = _getToday();
      if (_selectedDate == today) {
        _loadData();
      }
    });
  }

  Future<void> _loadGoals() async {
    _goals = await _db.getGoals();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    _profile = await _db.getProfile();
    notifyListeners();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadDayLog(),
      _loadFoods(),
      _loadWeekHistory(),
    ]);
    notifyListeners();
  }

  Future<void> _loadDayLog() async {
    _dayLog = await _db.getDayLog(_selectedDate);
  }

  Future<void> _loadFoods() async {
    _foods = await _db.getFoodsForDay(_selectedDate);
  }

  Future<void> _loadWeekHistory() async {
    _weekHistory = await _db.getLastNDays(7);
  }

  Future<void> goToDate(DateTime date) async {
    _selectedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _loadData();
  }

  Future<void> addFood(FoodEntry entry) async {
    await _db.insertFood(entry);
    if (entry.date == _selectedDate) {
      await _loadData();
    } else if (entry.date == _getToday()) {
      await _loadData();
    }
    notifyListeners();
  }

  Future<void> deleteFood(FoodEntry food) async {
    if (food.id != null) {
      await _db.deleteFood(food.id!, food.date);
      if (food.date == _selectedDate) {
        await _loadData();
      }
      notifyListeners();
    }
  }

  Future<void> updateWater(double liters) async {
    await _db.updateWater(_selectedDate, liters);
    await _loadDayLog();
    notifyListeners();
  }

  Future<void> updateSteps(int steps) async {
    await _db.updateSteps(_selectedDate, steps);
    await _loadDayLog();
    notifyListeners();
  }

  Future<void> saveGoals(UserGoals goals) async {
    _goals = goals;
    await _db.saveGoals(goals);
    await _loadData();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _db.saveProfile(profile);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}