import 'package:flutter/material.dart';

class UserManager {
  static final UserManager instance = UserManager._internal();
  UserManager._internal();

  String userID = '';
  String userName = '';

  final ValueNotifier<int> coins = ValueNotifier<int>(2500);
  final ValueNotifier<int> level = ValueNotifier<int>(1);
  final ValueNotifier<int> xp = ValueNotifier<int>(0);

  void initUser({required String id, String? name}) {
    userID = id;
    userName = name ?? 'user_$id';
  }

  void addCoins(int amount) {
    coins.value += amount;
  }

  bool spendCoins(int amount) {
    if (coins.value >= amount) {
      coins.value -= amount;
      addXP(amount);
      return true;
    }
    return false;
  }

  void addXP(int amount) {
    xp.value += amount;
    final newLevel = 1 + (xp.value ~/ 100);
    if (newLevel != level.value) {
      level.value = newLevel;
    }
  }

  static Color getLevelColor(int lvl) {
    if (lvl >= 20) return const Color(0xFFFF4500); // Efsane (Kırmızı)
    if (lvl >= 10) return const Color(0xFFFFD700); // Altın
    if (lvl >= 5) return const Color(0xFF9C27B0);  // Mor
    return const Color(0xFF2196F3);                 // Mavi
  }
}
