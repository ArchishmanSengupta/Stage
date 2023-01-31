import 'package:flutter/material.dart';
import 'package:stage/screens/homePage.dart';
import 'package:stage/utils/player.dart';
import 'package:video_player/video_player.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoPlayer(videoUrl: 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  VideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  List<String> qualityOptions = [];
  List<String> qualityIncreament = [];
  int selectedQualityIndex = 0;

  @override
  void initState() {
    super.initState();
    _getVideoQuality();
  }

  void _getVideoQuality() async {
    var url = Uri.parse('https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8');
    final res = await http.get(url);

    print("RES----------------------------------------------------------------------------------------->: ${res.body}");
    print("RES--------Code----------------------------------------------------------------------------->: ${res.statusCode}");
    
    if (res.statusCode == 200) {
      final body = res.body;
      final lines = body.split("\n");
    
      print("BODY----------------------------------------------------------------------------------------->: ${body}");

      // SEQUENCE STREAM FOR M3U8 AT THE 5TH INDEX OF THE LIST
      print("LINES----------------------------------------------------------------------------------------->: ${lines}, xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx {$lines.runtimeType}"); 


    
      for (String line in lines) {
        if (line.startsWith("#EXT-X-STREAM-INF")) {
          final quality = line.split(",")[3];

          //TODO :
          /*
          "tears-of-steel-audio_eng=128002-video_eng=2200000.m3u8"
          hls m3u8 formated increament in lines,

          take the formats and switch accordingly to the video streams
           */
          final qualityIncreamentString = line.split(",")[4];
          qualityIncreament.add(qualityIncreamentString);
          qualityOptions.add(quality);
    
          print("QUALITY----------------------------------------------------------------------------------------->: ${quality}");
          print("QUALITY INCREAMENT----------------------------------------------------------------------------------------->: ${qualityIncreamentString}");
    
    
        }
      }
      setState(() {});
    }
  }

  void _selectQuality(int index) {
    
    setState(() {
      selectedQualityIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: VideoPlayerScreen(
              videoUrl: widget.videoUrl,
              selectedQualityIndex: selectedQualityIndex,
            ),
          ),
          Container(
            color: Colors.grey[300],
            child: QualitySelector(
              qualityOptions: qualityOptions,
              selectedQualityIndex: selectedQualityIndex,
              onSelect: (index) {
                print("INDEX----------------------------------------------------------------------------------------->: ${index}");
                _selectQuality(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  final int selectedQualityIndex;

  VideoPlayerScreen({required this.videoUrl, required this.selectedQualityIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(
            videoUrl.substring(0, videoUrl.lastIndexOf("/") + 1) +
              "index_${selectedQualityIndex + 1}.m3u8",
          ),
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: true,
        ),
      ),
    );
  }
}

class QualitySelector extends StatelessWidget {
  final List<String> qualityOptions;
  final int selectedQualityIndex;
  final Function onSelect;

  QualitySelector({required this.qualityOptions, required this.selectedQualityIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text("Quality:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8.0),
          DropdownButton(
            icon: Icon(Icons.arrow_drop_down_circle_sharp),
            items: qualityOptions
                .asMap()
                .map((index, quality) => MapEntry(
                      index,
                      DropdownMenuItem(
                        child: Text(quality),
                        value: index,
                      ),
                    ))
                .values
                .toList(),
            value: selectedQualityIndex,
            onChanged: (index) {
              onSelect(index);
            },
          ),
        ],
      ),
    );
  }
}


