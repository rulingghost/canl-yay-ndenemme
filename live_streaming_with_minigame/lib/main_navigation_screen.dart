import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'live_audio_room_page.dart';
import 'live_streaming_page.dart';
import 'login_page.dart';
import 'user_manager.dart';

class MainNavigationScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String avatarUrl;

  const MainNavigationScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildExploreTab(),
          _buildAudioRoomsTab(),
          _buildMinigamesTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 62,
        width: 62,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF2E93), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2E93).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: _showCreateLiveModal,
          child: const Icon(
            Icons.add_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16112C),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(icon: Icons.explore_rounded, label: 'Keşfet', index: 0),
                _buildNavItem(icon: Icons.mic_rounded, label: 'Sesli Odalar', index: 1),
                const SizedBox(width: 48), // FAB gap
                _buildNavItem(icon: Icons.sports_esports_rounded, label: 'Oyunlar', index: 2),
                _buildNavItem(icon: Icons.person_rounded, label: 'Profilim', index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF2E93) : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: KEŞFET (CANLI YAYINLAR)
  // -------------------------------------------------------------
  Widget _buildExploreTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2E93), Color(0xFFFF8E53)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Zego Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Coin Balance Chip
              ValueListenableBuilder<int>(
                valueListenable: UserManager.instance.coins,
                builder: (context, coins, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 14)),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Join by Room ID Search Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tag_rounded, color: Color(0xFFFF2E93), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Özel bir oda numarasına katıl',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showDirectJoinDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E93),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: const Text('Odaya Gir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Section Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔥 Popüler Canlı Yayınlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tümü',
                style: TextStyle(color: Color(0xFFFF2E93), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Live Stream Grid Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
            children: [
              _buildStreamCard(
                title: 'Büyük PK Kapışması ⚔️',
                hostName: 'Selin_Live',
                roomId: 'oda_pk_101',
                viewers: '2.4K',
                gradient: [const Color(0xFF8A2387), const Color(0xFFE94057)],
                isPk: true,
              ),
              _buildStreamCard(
                title: 'Canlı Müzik & Sohbet 🎸',
                hostName: 'Murat_Acoustic',
                roomId: 'oda_muzik_202',
                viewers: '1.1K',
                gradient: [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
                isPk: false,
              ),
              _buildStreamCard(
                title: 'Mini Oyun Turnuvası 🎮',
                hostName: 'GamerEce',
                roomId: 'oda_oyun_303',
                viewers: '850',
                gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                isPk: false,
              ),
              _buildStreamCard(
                title: 'Gece Kuşları Canlı 🌙',
                hostName: 'Barış_Official',
                roomId: 'oda_gece_404',
                viewers: '3.9K',
                gradient: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                isPk: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreamCard({
    required String title,
    required String hostName,
    required String roomId,
    required String viewers,
    required List<Color> gradient,
    required bool isPk,
  }) {
    return GestureDetector(
      onTap: () => _joinLiveAsAudience(roomId),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dark gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2E93),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('🔴 ', style: TextStyle(fontSize: 8)),
                            Text(
                              isPk ? 'PK CANLI' : 'CANLI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '👥 $viewers',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  // Bottom Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage(
                              'https://robohash.org/$hostName.png?set=set4',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hostName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: SESLİ ODALAR (AUDIO ROOMS)
  // -------------------------------------------------------------
  Widget _buildAudioRoomsTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          const Text(
            '🎙️ Çok Koltuklu Sesli Odalar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sesli sohbet odalarına katılın veya kendi odanızı açın',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 18),

          _buildAudioRoomTile(
            title: 'Muhabbet & Müzik Bahçesi ☕',
            hostName: 'Cemre_DJ',
            roomId: 'sesli_oda_101',
            participants: '6/8 Koltuk',
            color: const Color(0xFF6C5CE7),
          ),
          _buildAudioRoomTile(
            title: 'Oyun Severler Sesli Lobi 🎮',
            hostName: 'Eren_Pro',
            roomId: 'sesli_oda_202',
            participants: '4/8 Koltuk',
            color: const Color(0xFF00B894),
          ),
          _buildAudioRoomTile(
            title: 'Dertleşme & Gece Sohbetleri 💬',
            hostName: 'Zeynep_K',
            roomId: 'sesli_oda_303',
            participants: '8/8 Dolu',
            color: const Color(0xFFE17055),
          ),
          _buildAudioRoomTile(
            title: 'Girişimcilik & Teknoloji Odası 💡',
            hostName: 'Hakan_Dev',
            roomId: 'sesli_oda_404',
            participants: '3/8 Koltuk',
            color: const Color(0xFF0984E3),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioRoomTile({
    required String title,
    required String hostName,
    required String roomId,
    required String participants,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Yönetici: $hostName',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        participants,
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _joinAudioRoomAsAudience(roomId),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Katıl', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: MINIGAMES
  // -------------------------------------------------------------
  Widget _buildMinigamesTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          const Text(
            '🎮 İnteraktif Mini Oyunlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Canlı yayınlarda veya tek başınıza mini oyunları deneyin',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D1456), Color(0xFF140D2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF2E93).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2E93).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.videogame_asset_rounded,
                        color: Color(0xFFFF2E93),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HTML5 Zego MiniGame Lobi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Yayıncı ve izleyicilerle eş zamanlı oyun',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '💡 İpucu: Herhangi bir canlı yayına veya sesli odaya katıldığınızda, ekranın altındaki 🎮 butonuna basarak oyunu odadaki herkesle birlikte oynayabilirsiniz!',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _startLiveWithCustomName(
                        roomName: 'Oyun_Odası_${Random().nextInt(999)}',
                        isVideo: true,
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Oyunlu Canlı Yayın Başlat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2E93),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: PROFİLİM
  // -------------------------------------------------------------
  Widget _buildProfileTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        children: [
          const Text(
            '👤 Profilim & Cüzdan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFFF2E93),
                  child: ClipOval(
                    child: Image.network(
                      widget.avatarUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.userId}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Level Badge
                      ValueListenableBuilder<int>(
                        valueListenable: UserManager.instance.level,
                        builder: (context, lvl, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: UserManager.getLevelColor(lvl),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Seviye $lvl ★ VIP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Coin Wallet Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF382306), Color(0xFF1F1403)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coin Cüzdanım',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showTopUpDialog,
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text('Coin Al', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<int>(
                  valueListenable: UserManager.instance.coins,
                  builder: (context, coins, _) {
                    return Row(
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 26)),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Coin',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Hediyeler göndermek ve seviye atlamak için coin kullanın.',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          ListTile(
            onTap: _handleLogout,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.red.withOpacity(0.1),
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Hesaptan Çıkış Yap', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            subtitle: const Text('Farklı bir isim veya ID ile giriş yapın', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ACTIONS & MODALS
  // -------------------------------------------------------------
  void _showCreateLiveModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Canlı Yayın veya Oda Başlat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bir format seçip hemen takipçilerinizle buluşun',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Video Live Button
              ListTile(
                onTap: () {
                  Navigator.pop(ctx);
                  _startLiveWithCustomName(isVideo: true);
                },
                tileColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2E93).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Color(0xFFFF2E93)),
                ),
                title: const Text('Kamera ile Canlı Yayın (Video + PK)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('PK Savaşları, Mini Oyunlar ve Canlı Hediyeler', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(height: 12),

              // Audio Room Button
              ListTile(
                onTap: () {
                  Navigator.pop(ctx);
                  _startLiveWithCustomName(isVideo: false);
                },
                tileColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded, color: Color(0xFF6C5CE7)),
                ),
                title: const Text('Sesli Sohbet Odası (Audio Room)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('8 Koltuklu sesli muhabbet ve mini oyunlar', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _startLiveWithCustomName({String? roomName, required bool isVideo}) {
    final titleCtrl = TextEditingController(text: roomName ?? '${widget.userName} Canlıda 🔥');
    final roomCode = roomName ?? 'oda_${Random().nextInt(89999) + 10000}';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E173D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isVideo ? '🎥 Canlı Yayını Başlat' : '🎙️ Sesli Odayı Başlat',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Yayın Başlığı',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Oda Kodu: $roomCode',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (isVideo) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveStreamingPage(
                        liveID: roomCode,
                        isHost: true,
                        userID: widget.userId,
                        userName: widget.userName,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveAudioRoomPage(
                        roomID: roomCode,
                        isHost: true,
                        userID: widget.userId,
                        userName: widget.userName,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E93),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Yayına Başla'),
            ),
          ],
        );
      },
    );
  }

  void _joinLiveAsAudience(String roomId) {
    if (UserManager.instance.isBanned.value) {
      _showBannedSnackbar();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveStreamingPage(
          liveID: roomId,
          isHost: false,
          userID: widget.userId,
          userName: widget.userName,
        ),
      ),
    );
  }

  void _joinAudioRoomAsAudience(String roomId) {
    if (UserManager.instance.isBanned.value) {
      _showBannedSnackbar();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveAudioRoomPage(
          roomID: roomId,
          isHost: false,
          userID: widget.userId,
          userName: widget.userName,
        ),
      ),
    );
  }

  void _showDirectJoinDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E173D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Oda Numarasıyla Katıl', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: codeCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Örn: oda_pk_101 veya 12345',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeCtrl.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(ctx);
                  _joinLiveAsAudience(code);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2E93), foregroundColor: Colors.white),
              child: const Text('Katıl'),
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E173D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🪙 Coin Yükle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCoinBuyOption(100, '₺19.99'),
              const SizedBox(height: 8),
              _buildCoinBuyOption(500, '₺79.99'),
              const SizedBox(height: 8),
              _buildCoinBuyOption(1000, '₺149.99'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoinBuyOption(int amount, String price) {
    return ListTile(
      onTap: () {
        UserManager.instance.addCoins(amount);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Tebrikler! Hesabınıza $amount Coin eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white.withOpacity(0.06),
      leading: const Text('🪙', style: TextStyle(fontSize: 22)),
      title: Text('$amount Coin', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFFFB300), borderRadius: BorderRadius.circular(8)),
        child: Text(price, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  void _showBannedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚫 Hesabınız yönetici tarafından askıya alınmıştır!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_user_id');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
