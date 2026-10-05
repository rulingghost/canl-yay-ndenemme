import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';

import 'gift_model.dart';
import 'user_manager.dart';

class GiftBottomSheet extends StatefulWidget {
  final Function(GiftItem gift, String senderName) onGiftSent;

  const GiftBottomSheet({
    Key? key,
    required this.onGiftSent,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required Function(GiftItem gift, String senderName) onGiftSent,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GiftBottomSheet(onGiftSent: onGiftSent),
    );
  }

  @override
  State<GiftBottomSheet> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet> {
  GiftItem? selectedGift;

  @override
  void initState() {
    super.initState();
    selectedGift = GiftList.items.first;
  }

  void _sendGift() {
    if (selectedGift == null) return;

    final gift = selectedGift!;
    final success = UserManager.instance.spendCoins(gift.cost);

    if (success) {
      final sender = UserManager.instance.userName;
      ZegoUIKit().sendInRoomMessage(
        '🎁 [GIFT] $sender ${gift.icon} ${gift.name} gönderdi! (+${gift.cost})',
      );

      widget.onGiftSent(gift, sender);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Yetersiz Bakiye! Bu hediye ${gift.cost} Coin gerektirir.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: '+1000 Coin Yükle',
            textColor: Colors.yellow,
            onPressed: () {
              UserManager.instance.addCoins(1000);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hediye Gönder 🎁',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: UserManager.instance.coins,
                builder: (context, coins, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 14)),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            UserManager.instance.addCoins(1000);
                          },
                          child: const Icon(
                            Icons.add_circle,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: GiftList.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final gift = GiftList.items[index];
                final isSelected = selectedGift?.id == gift.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGift = gift;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C5CE7).withOpacity(0.3)
                          : const Color(0xFF2A2A3D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gift.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gift.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 2),
                            Text(
                              '${gift.cost}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              onPressed: selectedGift != null ? _sendGift : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
              child: Text(
                selectedGift != null
                    ? '${selectedGift!.name} Gönder (${selectedGift!.cost} Coin)'
                    : 'Hediye Seçin',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
