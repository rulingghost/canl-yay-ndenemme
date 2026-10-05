import 'dart:async';
import 'package:flutter/material.dart';

class GiftBannerItem {
  final String sender;
  final String giftName;
  final String giftIcon;
  final int cost;

  GiftBannerItem({
    required this.sender,
    required this.giftName,
    required this.giftIcon,
    required this.cost,
  });
}

class GiftAnimationOverlay extends StatefulWidget {
  final Stream<GiftBannerItem> giftStream;

  const GiftAnimationOverlay({
    Key? key,
    required this.giftStream,
  }) : super(key: key);

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {
  GiftBannerItem? currentGift;
  Timer? dismissTimer;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  StreamSubscription<GiftBannerItem>? _subscription;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _subscription = widget.giftStream.listen((gift) {
      _showGift(gift);
    });
  }

  void _showGift(GiftBannerItem gift) {
    dismissTimer?.cancel();
    setState(() {
      currentGift = gift;
    });
    _animController.forward(from: 0.0);

    dismissTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _animController.reverse().then((_) {
          if (mounted) {
            setState(() {
              currentGift = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentGift == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 220,
      left: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF6C5CE7)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentGift!.giftIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentGift!.sender,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${currentGift!.giftName} hediye etti! (+${currentGift!.cost})',
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
