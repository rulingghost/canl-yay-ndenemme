import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'common.dart';
import 'constants.dart';
import 'gift_animation_overlay.dart';
import 'gift_dialog.dart';
import 'gift_model.dart';
import 'minigame/service/mini_game_api.dart';
import 'minigame/ui/show_game_list_view.dart';
import 'minigame/your_game_server.dart';
import 'user_manager.dart';

class LiveStreamingPage extends StatefulWidget {
  final String liveID;
  final bool isHost;
  final String userID;
  final String userName;

  const LiveStreamingPage({
    Key? key,
    required this.liveID,
    required this.userID,
    required this.userName,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LiveStreamingPageState();
}

class LiveStreamingPageState extends State<LiveStreamingPage> {
  final liveStreamingStateNotifier = ValueNotifier(ZegoLiveStreamingState.idle);
  bool playing = false;

  final StreamController<GiftBannerItem> _giftStreamController =
      StreamController<GiftBannerItem>.broadcast();
  StreamSubscription? _msgSubscription;

  @override
  void initState() {
    super.initState();
    UserManager.instance.initUser(id: widget.userID, name: widget.userName);

    // Gelen canlı mesajları dinle, hediye mesajı varsa animasyonu tetikle
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
    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    return WillPopScope(
      onWillPop: () async {
        await ZegoMiniGame().unloadGame();
        await ZegoMiniGame().uninitGameSDK();
        await ZegoMiniGame().uninitWebViewController();
        return true;
      },
      child: SafeArea(
        child: Stack(
          children: [
            ZegoUIKitPrebuiltLiveStreaming(
              appID: yourAppID,
              appSign: yourAppSign,
              userID: widget.userID,
              userName: widget.userName,
              liveID: widget.liveID,
              events: ZegoUIKitPrebuiltLiveStreamingEvents(
                onStateUpdated: (state) =>
                    liveStreamingStateNotifier.value = state,
              ),
              config: (widget.isHost ? hostConfig : audienceConfig)
                ..avatarBuilder = customAvatarBuilder
                ..audioVideoView.useVideoViewAspectFill = false
                ..inRoomMessage.attributes = () => {
                      'lv': UserManager.instance.level.value.toString(),
                    }
                ..inRoomMessage.avatarLeadingBuilder = _buildLevelBadge,
            ),
            Offstage(
              offstage: !playing,
              child: InAppWebView(
                initialFile: 'assets/minigame/index.html',
                onWebViewCreated: (InAppWebViewController controller) async {
                  ZegoMiniGame().initWebViewController(controller);
                },
                onLoadStop: (controller, url) async {
                  final token = await YourGameServer().getToken(
                    appID: yourAppID,
                    userID: widget.userID,
                    serverSecret: yourServerSecret,
                  );

                  await ZegoMiniGame().initGameSDK(
                    appID: yourAppID,
                    token: token,
                    userID: widget.userID,
                    userName: widget.userName,
                    avatarUrl: Uri.encodeComponent(
                        'https://robohash.org/${widget.userID}.png?set=set4'),
                    language: GameLanguage.english,
                  );
                },
                onConsoleMessage: (controller, ConsoleMessage msg) async {
                  debugPrint(
                      '[InAppWebView][${msg.messageLevel}]${msg.message}');
                },
              ),
            ),
            gameButton(),
            giftButton(),
            GiftAnimationOverlay(giftStream: _giftStreamController.stream),
          ],
        ),
      ),
    );
  }

  Widget giftButton() {
    return Positioned(
      bottom: 140,
      right: 12,
      child: FloatingActionButton(
        heroTag: 'gift_btn_live',
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
    );
  }

  Widget gameButton() {
    return ValueListenableBuilder(
      valueListenable: liveStreamingStateNotifier,
      builder: (context, liveStreamingState, _) {
        if (liveStreamingState != ZegoLiveStreamingState.living) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: playing ? 10 : null,
          top: playing ? 10 : null,
          bottom: playing ? null : 80,
          right: playing ? null : 10,
          child: FloatingActionButton.extended(
            heroTag: 'game_btn_live',
            onPressed: () async {
              if (!playing) {
                showGameListView(context).then((ZegoGameInfo? gameInfo) async {
                  if (gameInfo != null) {
                    final gameID = gameInfo.miniGameId!;
                    final gameMode = gameInfo.gameMode!;
                    debugPrint('[APP]load game: $gameID');
                    try {
                      final loadGameResult = await ZegoMiniGame().loadGame(
                        gameID: gameID,
                        gameMode: ZegoGameMode.values
                            .where((element) => element.value == gameMode[0])
                            .first,
                        loadGameConfig: ZegoLoadGameConfig(
                            minGameCoin: 0,
                            roomID: widget.liveID,
                            useRobot: true),
                      );
                      debugPrint('[APP]loadGame: $loadGameResult');
                      setState(() => playing = true);
                    } catch (e) {
                      showSnackBar('getUserCurrency:$e');
                    }
                    try {
                      final exchangeUserCurrencyResult =
                          await YourGameServer().exchangeUserCurrency(
                        appID: yourAppID,
                        gameID: gameID,
                        userID: widget.userID,
                        exchangeValue: 10000,
                        outOrderId:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                      );
                      debugPrint(
                          '[APP]exchangeUserCurrencyResult: $exchangeUserCurrencyResult');
                    } catch (e) {
                      showSnackBar('exchangeUserCurrency:$e');
                    }
                    try {
                      final getUserCurrencyResult =
                          await YourGameServer().getUserCurrency(
                        appID: yourAppID,
                        userID: widget.userID,
                        gameID: gameID,
                      );
                      debugPrint(
                          '[APP]getUserCurrencyResult: $getUserCurrencyResult');
                    } catch (e) {
                      showSnackBar('getUserCurrency:$e');
                    }
                  }
                });
              } else {
                await ZegoMiniGame().unloadGame();
                setState(() => playing = false);
              }
            },
            label: playing ? const Text('Quit Game') : const Text('Game List'),
            icon: playing
                ? const Icon(Icons.arrow_back)
                : const Icon(Icons.games),
          ),
        );
      },
    );
  }
}
