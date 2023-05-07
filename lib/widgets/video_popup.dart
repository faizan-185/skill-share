import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:skill_share/theme.dart';
import 'package:video_player/video_player.dart';

class VideoAlertDialog extends StatefulWidget {
  final String videoUrl;

  VideoAlertDialog({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoAlertDialogState createState() => _VideoAlertDialogState();
}

class _VideoAlertDialogState extends State<VideoAlertDialog> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          loading = false;
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        )
            : const Center(child: CircularProgressIndicator(color: kPrimaryColor,)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              if (_isPlaying) {
                _videoPlayerController.pause();
              } else {
                _videoPlayerController.play();
              }
              _isPlaying = !_isPlaying;
            });
          },
          child: _isPlaying
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        ),
      ],
    );
  }
}
