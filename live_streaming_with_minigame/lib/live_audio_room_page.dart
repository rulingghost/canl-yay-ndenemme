import 'dart:async';
import 'dart:math';

import 'package:faker/faker.dart' hide Image, Color;
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

import 'common.dart';
import 'constants.dart';
import 'gift_animation_overlay.dart';
import 'gift_dialog.dart';
import 'gift_model.dart';
import 'minigame/service/mini_game_api.dart';
import 'minigame/ui/show_game_list_view.dart';
import 'minigame/ui/start_game_dialog.dart';
import 'minigame/your_game_server.dart';
import 'user_manager.dart';

part 'live_audio_room_game.dart';

class LiveAudioRoomPage extends StatefulWidget {
  final String roomID;
  final bool isHost;
  final String userID;
  final String userName;

  const LiveAudioRoomPage({
    Key? key,
    required this.roomID,
    required this.userID,
    required this.userName,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LiveAudioRoomPageState();
}

class LiveAudioRoomPageState extends State<LiveAudioRoomPage> {
  late final InRoomGameController _gameCtrl = InRoomGameController(
    userID: widget.userID,
    userName: widget.userName,
    roomID: widget.roomID,
    isHost: widget.isHost,
  );

  final StreamController<GiftBannerItem> _giftStreamController =
      StreamController<GiftBannerItem>.broadcast();
  StreamSubscription? _msgSubscription;

  @override
  void initState() {
    super.initState();
    UserManager.instance.initUser(id: widget.userID, name: widget.userName);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _gameCtrl.init();
    });

    _msgSubscription =
        ZegoUIKit().getInRoomMessageListStream().listen((messages) {
      for (final message in messages) {
        if (message.message.startsWith('🎁 [GIFT]')) {
          final parts = message.message.split(' ');
          if (parts.length >= 5) {
            final sender = parts[2];
            final icon = parts[3];
            final name = parts[4];
            int cost = 10;
            if (message.message.contains('(+')) {
              final costPart = message.message.split('(+')[1];
              cost = int.tryParse(costPart.replaceAll(')', '')) ?? 10;
            }
            _giftStreamController.add(
              GiftBannerItem(
                sender: sender,
                giftName: name,
                giftIcon: icon,
                cost: cost,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    _giftStreamController.close();
    super.dispose();
  }

  Widget _buildLevelBadge(
    BuildContext context,
    ZegoInRoomMessage message,
    Map<String, dynamic> extraInfo,
  ) {
    final lv = message.attributes['lv'] ?? '1';
    final levelNum = int.tryParse(lv) ?? 1;

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UserManager.getLevelColor(levelNum),
            const Color(0xFF6C5CE7),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: UserManager.getLevelColor(levelNum).withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        'Lv.$lv',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostConfig = ZegoUIKitPrebuiltLiveAudioRoomConfig.host();
    final audienceConfig = ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    return PopScope(
      onPopInvoked: (bool didPop) async {
        if (didPop) await _gameCtrl.uninit();
      },
      child: SafeArea(
        child: Stack(
          children: [
            ZegoUIKitPrebuiltLiveAudioRoom(
              appID: yourAppID,
              appSign: yourAppSign,
              userID: widget.userID,
              userName: widget.userName,
              roomID: widget.roomID,
              config: (widget.isHost ? hostConfig : audienceConfig)
                ..userAvatarUrl =
                    'https://robohash.org/$localUserID.png?set=set4'
                ..seat.closeWhenJoining = false
                ..bottomMenuBar.hostExtendButtons = [_gameCtrl.gameButton()]
                ..bottomMenuBar.hostButtons = [
                  ZegoLiveAudioRoomMenuBarButtonName.toggleMicrophoneButton,
                  ZegoLiveAudioRoomMenuBarButtonName.showMemberListButton,
                ]
                ..emptyAreaBuilder = ((_) => _gameCtrl.gameView())
                ..background = background(),
            ),
            Positioned(
              bottom: 120,
              right: 12,
              child: FloatingActionButton(
                heroTag: 'gift_btn_audio',
                onPressed: () {
                  GiftBottomSheet.show(
                    context,
                    onGiftSent: (gift, sender) {
                      _giftStreamController.add(
                        GiftBannerItem(
                          sender: sender,
                          giftName: gift.name,
                          giftIcon: gift.icon,
                          cost: gift.cost,
                        ),
                      );
                    },
                  );
                },
                backgroundColor: const Color(0xFFE91E63),
                child: const Text('🎁', style: TextStyle(fontSize: 26)),
              ),
            ),
            GiftAnimationOverlay(giftStream: _giftStreamController.stream),
          ],
        ),
      ),
    );
  }

  Widget background() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.asset('assets/images/background.png').image,
            ),
          ),
        ),
        const Positioned(
          top: 10,
          left: 10,
          child: Text(
            'Live Audio Room (Sohbet Odası)',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          top: 34,
          left: 10,
          child: Text(
            'Oda ID: ${widget.roomID}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
