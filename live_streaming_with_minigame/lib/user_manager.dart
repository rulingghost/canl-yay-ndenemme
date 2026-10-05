import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserManager {
  static final UserManager instance = UserManager._internal();
  UserManager._internal();

  String userID = '';
  String userName = '';

  final ValueNotifier<int> coins = ValueNotifier<int>(2500);
  final ValueNotifier<int> level = ValueNotifier<int>(1);
  final ValueNotifier<int> xp = ValueNotifier<int>(0);
  final ValueNotifier<bool> isBanned = ValueNotifier<bool>(false);

  final String firestoreProjectId = 'canliyayindeneme-8f384';
  final Dio _dio = Dio();
  Timer? _syncTimer;

  String get _firestoreUserUrl =>
      'https://firestore.googleapis.com/v1/projects/$firestoreProjectId/databases/(default)/documents/users/$userID';

  void initUser({required String id, String? name}) {
    userID = id;
    userName = name ?? 'user_$id';

    // Firebase Firestore'dan kullanıcının güncel bakiyesini ve ban durumunu çek
    fetchFromFirestore();

    // Her 10 saniyede bir admin panelinden coin veya ban değişikliği yapılmış mı kontrol et
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchFromFirestore();
    });
  }

  Future<void> fetchFromFirestore() async {
    if (userID.isEmpty) return;

    try {
      final response = await _dio.get(_firestoreUserUrl);
      if (response.statusCode == 200 && response.data != null) {
        final fields = response.data['fields'];
        if (fields != null) {
          if (fields['coins'] != null) {
            final c = int.tryParse(fields['coins']['integerValue']?.toString() ?? '');
            if (c != null && c != coins.value) {
              coins.value = c;
            }
          }
          if (fields['level'] != null) {
            final l = int.tryParse(fields['level']['integerValue']?.toString() ?? '');
            if (l != null && l != level.value) {
              level.value = l;
            }
          }
          if (fields['isBanned'] != null) {
            isBanned.value = fields['isBanned']['booleanValue'] == true;
          }
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Kullanıcı henüz Firestore'da yoksa ilk kaydını oluştur
        _saveToFirestore();
      }
    } catch (_) {}
  }

  Future<void> _saveToFirestore() async {
    if (userID.isEmpty) return;

    try {
      final data = {
        'fields': {
          'id': {'stringValue': userID},
          'name': {'stringValue': userName},
          'coins': {'integerValue': coins.value.toString()},
          'level': {'integerValue': level.value.toString()},
          'isBanned': {'booleanValue': isBanned.value},
          'avatar': {'stringValue': 'https://robohash.org/$userID.png?set=set4'},
        }
      };
      await _dio.patch(
        '$_firestoreUserUrl?updateMask.fieldPaths=id&updateMask.fieldPaths=name&updateMask.fieldPaths=coins&updateMask.fieldPaths=level&updateMask.fieldPaths=isBanned&updateMask.fieldPaths=avatar',
        data: data,
      );
    } catch (e) {
      debugPrint('[UserManager] Firestore kaydetme hatası: $e');
    }
  }

  void addCoins(int amount) {
    coins.value += amount;
    _saveToFirestore();
  }

  bool spendCoins(int amount) {
    if (coins.value >= amount) {
      coins.value -= amount;
      addXP(amount);
      _saveToFirestore();
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
