import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

List<String> qualityOptions = [];

int selectedQualityIndex = 0;
Map<String, String> resolutionToUrl = {};
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
      home: VideoPlayer(
        videoUrl:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
      ),
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
  final String videoUrl = 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8';
  final String baseUrl = 'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/';
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _getVideoQuality();
  }

  void _getVideoQuality() async {
    var url = Uri.parse(videoUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = response.body;
      final lines = body.split("#");

      for (String line in lines) {
        if (line.startsWith("EXT-X-STREAM-INF")) {
          // ignore: non_constant_identifier_names
          List<String> DynamicFormattedSubstring = line.split(",");
          if (DynamicFormattedSubstring.length < 4) {
            continue;
          }
          
          final quality = DynamicFormattedSubstring[3];
          String mergedUrl = baseUrl + line.split("\n")[1];

          resolutionToUrl[quality] = "$mergedUrl";
          qualityOptions.add(quality);
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

  VideoPlayerScreen(
      {required this.videoUrl, required this.selectedQualityIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(
              resolutionToUrl[qualityOptions[selectedQualityIndex]]!),
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

  QualitySelector(
      {required this.qualityOptions,
      required this.selectedQualityIndex,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/10,
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text("Choose Video Quality:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8.0),
          InkWell(
          onTap: (){
            showModalBottomSheet(context: context, builder: (context){
              return Container(
                height: MediaQuery.of(context).size.height/3,
                child: ListView.builder(
                  itemCount: qualityOptions.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      title: Text(qualityOptions[index]),
                      leading: selectedQualityIndex == index
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : SizedBox(),
                      onTap: (){
                        onSelect(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            });
            },
            child: Container(
              width: 220,
              height: 30,
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    qualityOptions[selectedQualityIndex],
                    style: TextStyle(color: Colors.black45),
                  ),
                  SizedBox(width: 10,),
                  Icon(Icons.arrow_downward_rounded)
                ],
              ),
            ),
          ),
          ],
          ),
          );
          }
}
