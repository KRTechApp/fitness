import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeFullScreen extends StatefulWidget {
  final String? videoId;

  const YoutubeFullScreen({super.key, this.videoId});

  @override
  State<YoutubeFullScreen> createState() => _YoutubeFullScreenState();
}

class _YoutubeFullScreenState extends State<YoutubeFullScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId.toString(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    _controller.updateValue(_controller.value.copyWith(isFullScreen: true));
  }

  void onFullScreen(bool isFullScreen) {
    if (!isFullScreen) {
      debugPrint('isFullScreen Navigator pop: $isFullScreen');
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
        ),
        child: YoutubePlayer(
          controller: _controller,
          bottomActions: [
            const CurrentPosition(),
            const ProgressBar(isExpanded: true),
            // PlayPauseButton(),
            const RemainingDuration(),
            FullScreenButton(controller: _controller, onFullScreen: onFullScreen),
            const PlaybackSpeedButton(),
          ],
        ));
  }
}
