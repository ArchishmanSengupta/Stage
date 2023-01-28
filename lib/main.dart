import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stage Video Quality Selector',
      home: Container(
          padding: EdgeInsets.all(50),
          color: Colors.black,
          child: StageVideoSelector()),
    );
  }
}

class StageVideoSelector extends StatefulWidget {
  StageVideoSelector({Key? key}) : super(key: key);

  @override
  _StageVideoSelectorState createState() => _StageVideoSelectorState();
}

class _StageVideoSelectorState extends State<StageVideoSelector> {

  String _selectedQuality = '720p';
  String stream360p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902569/360_ydin5t.mp4';
  String stream480p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902570/480_inbgl6.mp4';
  String stream1080p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902581/1080_qb5n5g.mp4';
  String stream4kp = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902572/4k_kqhzha.webm';
  String stream8kp='https://res.cloudinary.com/dri88yrck/video/upload/v1674902572/8k_zkstrt.webm';

  late List<Map<String, dynamic>> _qualities;

  late VideoPlayerController videoPlayerController;
  late Future<void> initializeVideoPlayerFuture;
  late int playBackTime;
  late Duration currentPosition;
  
  @override
  void initState() {
    _qualities = [
      {"name": "Super Ultra HD 8K", "value": stream8kp, "icon": Icons.diamond, "text": "VIP Service"},
      {"name": "Ultra HD 4K", "value": stream4kp, "icon": Icons.diamond, "text": "VIP Service"},
      {"name": "HD 1080P", "value": stream1080p},      {"name": "Better 480P", "value": stream480p},
      {"name": "Good 360P", "value": stream360p},
    ];
    videoPlayerController = VideoPlayerController.network(stream8kp);
    videoPlayerController.addListener(() {
      setState(() {
        playBackTime = videoPlayerController.value.position.inSeconds;
      });
    });
    initializeVideoPlayerFuture = videoPlayerController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    initializeVideoPlayerFuture;
    videoPlayerController.pause().then((_) {
      videoPlayerController.dispose();
    });
    super.dispose();
  }

  Future<bool> clearPrevious() async {
    await videoPlayerController.pause();
    return true;
  }
  
  Future<void> initializePlay(String videoPath) async {
    videoPlayerController = VideoPlayerController.network(videoPath);
    videoPlayerController.addListener(() {
      setState(() {
        playBackTime = videoPlayerController.value.position.inSeconds;
      });
    });
    initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      videoPlayerController.seekTo(currentPosition);
      videoPlayerController.play();
    });
  }

  void getValuesAndPlay(String videoPath) {
    currentPosition = videoPlayerController.value.position;
    startPlay(videoPath);
    print(currentPosition.toString());
  }
  

 Future<void> startPlay(String videoPath) async {
    setState(() {
      initializeVideoPlayerFuture ;
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      clearPrevious().then((_) {
        initializePlay(videoPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController),
                ),
              ),
              _buildControls()
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildPlayPauseButton(),
            _buildCurrentTime(),
            _buildQualityButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return FloatingActionButton(
      backgroundColor: Colors.transparent,
      onPressed: () {
        setState(() {
          if (videoPlayerController.value.isPlaying) {
            videoPlayerController.pause();
          } else {
            videoPlayerController.play();
          }
        });
      },
      child: Icon(
        videoPlayerController.value.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
      ),
    );
  }
  Widget _buildCurrentTime() {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DefaultTextStyle(
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              child: Text(
                videoPlayerController.value.position.toString().split('.').first.padLeft(8, "0"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQualityButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Choose Streaming Quality"),
              children: _qualities.map((quality) {
                return SimpleDialogOption(
                  onPressed: () {
                    setState(() {
                      _selectedQuality = quality['name'];
                    });
                    getValuesAndPlay(quality['value']);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(quality['name']),
                      quality.containsKey("icon")
                      ? Row(
                            children: [
                              Icon(quality['icon'], size: 12),
                              const SizedBox(width: 10,),
                              Text(quality['text']),
                            ],
                        )
                      : Container(),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
      child: const Icon(
        Icons.settings,
        color: Colors.white,
      ),
    );
  }
}
