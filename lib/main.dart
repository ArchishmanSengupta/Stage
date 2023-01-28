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
  
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late int _playBackTime;
  //The values that are passed when changing quality
  late Duration newCurrentPosition;
  
  @override
  void initState() {
    _controller = VideoPlayerController.network(stream8kp);
    _controller.addListener(() {
      setState(() {
        _playBackTime = _controller.value.position.inSeconds;
      });
    });
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _initializeVideoPlayerFuture;
    _controller.pause().then((_) {
      _controller.dispose();
    });
    super.dispose();
  }

  Future<bool> _clearPrevious() async {
    await _controller.pause();
    return true;
  }

  Future<void> _initializePlay(String videoPath) async {
    _controller = VideoPlayerController.network(videoPath);
    _controller.addListener(() {
      setState(() {
        _playBackTime = _controller.value.position.inSeconds;
      });
    });
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.seekTo(newCurrentPosition);
      _controller.play();
    });
  }

  void _getValuesAndPlay(String videoPath) {
    newCurrentPosition = _controller.value.position;
    _startPlay(videoPath);
    print(newCurrentPosition.toString());
  }
  

  Future<void> _startPlay(String videoPath) async {
    setState(() {
      _initializeVideoPlayerFuture ;
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      _clearPrevious().then((_) {
        _initializePlay(videoPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          onPressed: () {
                            // Wrap the play or pause in a call to `setState`. This ensures the
                            // correct icon is shown.
                            setState(() {
                              // If the video is playing, pause it.
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                // If the video is paused, play it.
                                _controller.play();
                              }
                            });
                          },
                          // Display the correct icon depending on the state of the player.
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    DefaultTextStyle(
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      child: Text(
                                          _controller.value.position
                                              .toString()
                                              .split('.')
                                              .first
                                              .padLeft(8, "0"),
                                          
                                      ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                      FloatingActionButton(
                        backgroundColor: Colors.transparent,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  title: Text("Video Quality"),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuality = "Super Ultra HD 8K";
                                        });
                                        _getValuesAndPlay(stream8kp);
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Super Ultra HD 8K"),
                                          Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              Icon(Icons.diamond, size: 12),
                                              SizedBox(width: 10,),
                                              Text("VIP Service"),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuality = "4K";
                                        });
                                        _getValuesAndPlay(stream4kp);
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Ultra HD 4K"),
                                          Row(
                                            // ignore: prefer_const_literals_to_create_immutables
                                            children: [
                                              Icon(Icons.diamond, size: 12),
                                              SizedBox(width: 10,),
                                              Text("VIP Service"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuality = "1080p";
                                        });
                                        _getValuesAndPlay(stream1080p);
                                        Navigator.pop(context);
                                      },
                                      child: Text("HD 1080P"),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuality = "Better 480P";
                                        });
                                        _getValuesAndPlay(stream480p);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Better 480P"),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () {
                                        setState(() {
                                          _selectedQuality = "Good 360P";
                                        });
                                        _getValuesAndPlay(stream360p);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Good 360P"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}