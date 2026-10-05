import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'main_navigation_screen.dart';
import 'user_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _isLoading = false;

  final List<String> _avatarUrls = [
    'https://robohash.org/avatar1.png?set=set4',
    'https://robohash.org/avatar2.png?set=set4',
    'https://robohash.org/avatar3.png?set=set4',
    'https://robohash.org/avatar4.png?set=set4',
    'https://robohash.org/avatar5.png?set=set4',
    'https://robohash.org/avatar6.png?set=set4',
  ];

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('saved_username');
    final savedAvatar = prefs.getInt('saved_avatar_idx') ?? 0;
    final savedId = prefs.getString('saved_user_id');

    if (savedName != null && savedName.isNotEmpty && savedId != null) {
      _usernameController.text = savedName;
      _selectedAvatarIndex = savedAvatar;
      // Auto login
      _proceedToApp(userId: savedId, userName: savedName);
    } else {
      // Default random name
      final randId = (Random().nextInt(9000) + 1000).toString();
      _usernameController.text = 'Yayıncı_$randId';
    }
  }

  void _proceedToApp({required String userId, required String userName}) {
    UserManager.instance.initUser(id: userId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          userId: userId,
          userName: userName,
          avatarUrl: _avatarUrls[_selectedAvatarIndex],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir kullanıcı adı girin!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('saved_user_id');
    if (userId == null || userId.isEmpty) {
      userId = 'u_${Random().nextInt(899999) + 100000}';
      await prefs.setString('saved_user_id', userId);
    }
    await prefs.setString('saved_username', name);
    await prefs.setInt('saved_avatar_idx', _selectedAvatarIndex);

    setState(() => _isLoading = false);
    _proceedToApp(userId: userId, userName: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C20),
              Color(0xFF1A103C),
              Color(0xFF28114B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // App Logo and Glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2E93).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF2E93), Color(0xFFFF8E53)],
                    ),
                  ),
                  child: const Icon(
                    Icons.live_tv_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ZEGO LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Canlı Yayın, PK Savaşı, Sesli Odalar & Mini Oyunlar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 36),

                // Avatar Selection Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Profil Karakterinizi Seçin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: List.generate(_avatarUrls.length, (index) {
                          final isSelected = _selectedAvatarIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAvatarIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF2E93)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFF2E93)
                                              .withOpacity(0.6),
                                          blurRadius: 10,
                                        )
                                      ]
                                    : [],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF2B2050),
                                child: ClipOval(
                                  child: Image.network(
                                    _avatarUrls[index],
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Username Input Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kullanıcı Adınız',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.alternate_email_rounded,
                            color: Color(0xFFFF2E93),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF130E26),
                          hintText: 'Örn: KralYayıncı, Aslı, Can...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF2E93),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF2E93).withOpacity(0.5),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2E93), Color(0xFFFF8E53)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Giriş Yap ve Keşfet',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '⚡ ZEGOCLOUD Canlı İletişim Altyapısı',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
