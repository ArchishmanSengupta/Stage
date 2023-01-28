import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stage Video Quality Selector',
      home: Container(
          padding: const EdgeInsets.all(50),
          color: Colors.black,
          child: StageVideoSelector()),
    );
  }
}

class StageVideoSelector extends StatefulWidget {
  const StageVideoSelector({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StageVideoSelectorState createState() => _StageVideoSelectorState();
}

class _StageVideoSelectorState extends State<StageVideoSelector> {


  // Initializes the video streams for different qualities
  String stream360p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902569/360_ydin5t.mp4';
  String stream480p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902570/480_inbgl6.mp4';
  String stream1080p = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902581/1080_qb5n5g.mp4';
  String stream4kp = 'https://res.cloudinary.com/dri88yrck/video/upload/v1674902572/4k_kqhzha.webm';
  String stream8kp='https://res.cloudinary.com/dri88yrck/video/upload/v1674902572/8k_zkstrt.webm';

  // Initializes a list of maps for the different video qualities
  late List<Map<String, dynamic>> _qualities;

  // Initializes the video player controller and future
  late VideoPlayerController videoPlayerController;
  late Future<void> initializeVideoPlayerFuture;

  // Initializes the playback time and current position
  late int playBackTime;
  late Duration currentPosition;
  
  @override
  void initState() {
    // Populates the list of video qualities with their names, URLs and icons
    _qualities = [
      {"name": "Super Ultra HD 8K", "value": stream8kp, "icon": Icons.diamond, "text": "VIP Service"},
      {"name": "Ultra HD 4K", "value": stream4kp, "icon": Icons.diamond, "text": "VIP Service"},
      {"name": "HD 1080P", "value": stream1080p},      {"name": "Better 480P", "value": stream480p},
      {"name": "Good 360P", "value": stream360p},
    ];

    // Initialize the video player controller with the initial video URL
    videoPlayerController = VideoPlayerController.network(stream8kp);

    // Add a listener to the video player controller to track the current position in the video
    videoPlayerController.addListener(() {
      setState(() {
        playBackTime = videoPlayerController.value.position.inSeconds;
      });
    });
    // Initialize the video player
    initializeVideoPlayerFuture = videoPlayerController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the video player controller when the widget is disposed
    initializeVideoPlayerFuture;
    videoPlayerController.pause().then((_) {
      videoPlayerController.dispose();
    });
    super.dispose();
  }

  Future<bool> clearPrevious() async {
    // Pause the current video before switching to a new one
    await videoPlayerController.pause();
    return true;
  }
  
  Future<void> initializePlay(String videoPath) async {
    // Initialize the video player controller with the new video URL
    videoPlayerController = VideoPlayerController.network(videoPath);
    videoPlayerController.addListener(() {
      setState(() {
        playBackTime = videoPlayerController.value.position.inSeconds;
      });
    });

    // Initialize the video player and seek to the last position before switching videos
    initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      videoPlayerController.seekTo(currentPosition);
      videoPlayerController.play();
    });
  }

  void getValuesAndPlay(String videoPath) {
    // Save the current position before switching videos
    currentPosition = videoPlayerController.value.position;
    startPlay(videoPath);
  }
  

 Future<void> startPlay(String videoPath) async {
    setState(() {
      initializeVideoPlayerFuture;
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      clearPrevious().then((_) {
        initializePlay(videoPath);
      });
    });
  }

  /* 
  * This function is the main build function for the video player
  * It uses a FutureBuilder to handle the initialization of the video player and displays a loading spinner while it is initializing
  * Once the video player is initialized, it will display the video with controls at the bottom of the screen
 */

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

  /* 
  *This function creates the control bar at the bottom of the screen
  * It includes the play/pause button, the current time display, and the quality button
  */

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
  /* 
  *This function creates the play/pause button for the video
  *It uses an icon that changes based on the current play state of the video
  */
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
  /*
  * This function creates the current time display for the video
  * It displays the current time in a container with a black background and white text
  */
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
  /// This method creates a button for selecting streaming quality. 
  /// It uses a GestureDetector widget to handle the tap event and opens a SimpleDialog when tapped. 
  /// The SimpleDialog displays a list of options, each represented by a SimpleDialogOption.
  /// When an option is selected, the _selectedQuality variable is updated with the selected 
  /// quality name and the getValuesAndPlay() method is called with the selected quality value. 
  /// The Navigator.pop() method closes the SimpleDialog. 
  /// The child of the GestureDetector is an Icon widget that represents the settings icon.

  Widget _buildQualityButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text("Choose Streaming Quality"),
              children: _qualities.map((quality) {
                return SimpleDialogOption(
                  onPressed: () {
                    setState(() {
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
