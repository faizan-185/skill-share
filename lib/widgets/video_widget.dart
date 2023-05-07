import 'package:flutter/material.dart';
import 'package:skill_share/widgets/video_popup.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class VideoWidget extends StatefulWidget {
  final String url;

  const VideoWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {

  late String imageUrl = "";
  bool loading = false;

  Future<void> getThumbnail() async {
    setState(() {
      loading = true;
    });
    final fileName = await VideoThumbnail.thumbnailFile(
      video: widget.url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      quality: 90,
    );
    setState(() {
      imageUrl = fileName!;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          loading ? const SizedBox() : FadeInImage(
            height: 200,
          width: MediaQuery.of(context).size.width,
          placeholder: MemoryImage(kTransparentImage),
          image: FileImage(File(imageUrl)),
          fit: BoxFit.cover,
          ),
          Center(
            child: IconButton(
                icon: Icon(Icons.play_circle_filled, size: 48.0, color: Colors.white),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return VideoAlertDialog(videoUrl: widget.url);
                  },
                );
              },
            )
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getThumbnail();
  }
}
