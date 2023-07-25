import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CachedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const CachedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<CachedVideoPlayer> createState() => _CachedVideoPlayerState();
}

class _CachedVideoPlayerState extends State<CachedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      aspectRatio:
          _videoPlayerController.value.aspectRatio, // Adjust the aspect ratio based on your video's dimensions
      autoPlay:
          false, // Set to true if you want the video to start playing automatically
      looping: false, // Set to true if you want the video to loop
      // Add any other customization options as needed
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}
