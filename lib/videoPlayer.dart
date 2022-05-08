 
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_aws/colorPick.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({ Key? key }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with
 TickerProviderStateMixin{

List<String> videos =[
 "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
];
//the index of the video playing
int currentIndex=0;

late AnimationController animCont;

    late VideoPlayerController _controller;

// is the device in landscape or portrait
bool landScape=false;


Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/cc.srt');
    return SubRipCaptionFile(
        fileContents);  
  }

// init the video player controller 
  initController(String video){
        _controller = VideoPlayerController.network(
     video,
        closedCaptionFile:_loadCaptions() )..addListener(() {
          setState(() {
            
          });
        })
      ..initialize().then((_) {
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

//change playback speed
  changeSpeed(String speed)
  {
    double dSpeed= 1;
   
   switch (speed) {
     case "0.25x":
       dSpeed=0.25;
       break;
         case "0.5x":
       dSpeed=0.5;
       break;
         case "0.75x":
       dSpeed=0.75;
       break;
         case "Normal":
       dSpeed=1;
       break;
         case "1.25x":
       dSpeed=1.25;
       break;
         case "1.5x":
       dSpeed=1.5;
       break;
         case "1.75x":
       dSpeed=1.75;
       break;
         case "2x":
       dSpeed=2;
       break;
     default:
     dSpeed=1;
   }
   print(dSpeed);
_controller.setPlaybackSpeed(dSpeed);

  }
  
  @override
  void initState() {
    super.initState();

       animCont = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration:Duration(milliseconds: 200),
    );

  initController(videos[currentIndex]);
  }

  //when the user click it shows controls like pause/play , forward / backword and settings
bool showControls=false;

// for douple tap and single tap calculations 
 var lastTapDown = 0;
 bool doubleTap=false;

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
       body: Align(
         alignment: Alignment.topCenter,
         child: AspectRatio(
          
           aspectRatio:_controller.value.isInitialized?
           _controller.value.aspectRatio:1.77 ,
           child: Stack(
              alignment: Alignment.bottomCenter,
             children: [
            
               GestureDetector(
          

onTapDown: (details) {
  // return;
  var now = DateTime.now().millisecondsSinceEpoch;
 
 // if single tap then show controler else if double tap jump 15 seconds
  if (now - lastTapDown < 200) {
    print("Double Tap!");
    doubleTap=true;
    
    // if the double tab is on the right side of the screen jumb forward, else jump forwrd
    double halfScreenWidth= MediaQuery.of(context).size.width/2;
    if(details.globalPosition.dx<=halfScreenWidth)
    {
          _controller.seekTo(
          _controller.value.position - Duration(seconds: 15)
          );
    }
    else{
_controller.seekTo(
          _controller.value.position + Duration(seconds: 15)
          );
    }
  }
  else{
  Timer(
    Duration(milliseconds: 195),(){
      if(!doubleTap)
setState(() {
      showControls=true;
    });
    else
    doubleTap=false;
    }
  );  
  }
 
  lastTapDown = now;
},
             // when the user slide his finger on the screen 
                onHorizontalDragUpdate: (details) {
                  print(details.delta);
                  _controller.seekTo(_controller.value.position+Duration(seconds:  details.delta.dx.toInt()));
                },
               
                 child: VideoPlayer(_controller)),

                 // closed captions
              if(showCaptions) Positioned(
                 bottom:0
                 ,
                 left: 20,
                 right: 20,
         //  height: ,
                 child: ClosedCaption(
                   text: _controller.value.caption.text,
                   textStyle: TextStyle(
                     
                     fontSize: subTitleSize=="Small"?
                     13:subTitleSize=="Medium"?16:19,
                   color: SubtitleColor),
                   )),


// progress indicator
                                 VideoProgressIndicator(
                                   _controller, allowScrubbing: true,
                                   colors: VideoProgressColors(playedColor: Colors.purple),),


// controls for pause play and othe rsettings
         controlsWidget(),
            
            
           
             ],
           ),
         ),
       ),
    );
  }


Widget controlsWidget (){
  return             Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child:showControls? InkWell(

                        // when the user tab : hide controls and show video
            onTap: (){
                     setState(() {
                         showControls=false;
                    
                     });
                     
                   },
           child: Container(
             height: double.infinity,
             color: Colors.black.withOpacity(0.5),
             child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
   IconButton(
                        color: Colors.white,
                        onPressed: (){
                        // FontSettings();
                        setState(() {
                          showCaptions=!showCaptions;
                        });
                      }, icon:showCaptions?
                      Icon(Icons.closed_caption_disabled_rounded):
                       Icon(Icons.closed_caption_rounded)),


                       IconButton(
                        color: Colors.white,
                        onPressed: (){
                        settingsDialog().then((value) {
                          setState(() {
                            
                          });
                        });
                     
                      }, icon: Icon(Icons.settings)),
                    ],
                  ),
                ),
                Row(
                  
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [

                    // jump to previud video
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      onPressed: (){
                        setState(() {
                          currentIndex>0?
                          currentIndex--:
                          currentIndex=videos.length-1;
                      initController(videos[currentIndex]);
                          print(currentIndex);
                        });
                      }, 
                    icon: Icon(Icons.skip_previous_outlined)),
                    SizedBox(
                      width: 25,
                    ),
                 
                 // play pause button
                       IconButton(
                          iconSize: 40,
                      color: Colors.white,
                      onPressed: (){
                        if(_controller.value.isPlaying)
                        {
                          animCont.forward();
                          _controller.pause();
                        }
                        else{
           animCont.reverse();
           _controller.play();
                        }
                      }, 
                    icon: AnimatedIcon(icon: AnimatedIcons.pause_play,
                    progress:animCont ,)),


         
           SizedBox(
                      width: 25,
                    ),
                 
                 // jump to next video
                    IconButton(
                       iconSize: 40,
                      color: Colors.white,
                      onPressed: (){
                        setState(() {
                          currentIndex<videos.length-1?
                          currentIndex++:
                          currentIndex=0;
                      initController(videos[currentIndex]);
                          print(currentIndex);
                        });
                      }, 
                    icon: Icon(Icons.skip_next_outlined)),
                  ],
                ),

                
                Row(

                  children: [
                 // switch between landscape and portrait
                    IconButton(
                      color: Colors.white,
                      onPressed: (){
                      if(MediaQuery.of(context).orientation==Orientation.portrait)
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  else
     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


                    }, icon: Icon(
                      MediaQuery.of(context).orientation==Orientation.portrait?
                      Icons.fullscreen_rounded:
                      Icons.fullscreen_exit_rounded))
                  ],
                )
              ],
            ),
             ),
           ),
                      )
                      :Container(),
                    ),
            );
}

  String subTitleSize="Small";
  Color SubtitleColor=Colors.white;
  bool showCaptions=true;

  List<String> speeds=["0.25x","0.5x",
  "0.75x","Normal",
  "1.25x",
  "1.5x",
  "1.75x",
  "2x"];
  String selectedSpeed="Normal";
bool isLooping=false;
  Future<void> settingsDialog() async {



await showDialog (
    context: context,
    builder: (BuildContext context) {
    return StatefulBuilder(
      builder:(c,s)=> Dialog(
      shape: RoundedRectangleBorder(borderRadius: 
      BorderRadius.circular(22)),
        child: 
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              // vertical: 25
            ),
            height: 329,
            // width: 399,
            child: Material(
              color: Colors.white,
              child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
             Text("Subtitles",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                  
                ),),
            Row(
              children: [
                Text("size",
                style: TextStyle(
                  // fontSize: 15,
                  // fontWeight: FontWeight.bold
                  color: Colors.grey
                ),),
                SizedBox(
                  width: 15,
                ),
                DropdownButton<String>(
                     value: subTitleSize,
                    // icon: const Icon(Icons.format_size_rounded,
                    // color: Colors.grey,),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      s(() {
                        subTitleSize = newValue!;
                      });
                    },
                    items: <String>['Small', 'Medium', 'Big']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                 
                
              ],
            ),
            SizedBox(
              height: 8,
            ),
  Row(children: [
  Text("Color ",
                style: TextStyle(
                  // fontSize: 15,
                  color: Colors.grey
                  // fontWeight: FontWeight.
                ),),
                    SizedBox(
                  width: 15,
                ),
  Container(
    child: InkWell(onTap: () async {
      Color selected =await ColorPick.cp.showPick(context);
      s(() {
        SubtitleColor=selected;
      });
    }),
    width: 25,
    height: 25,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      color: SubtitleColor,
    ),
  )
],),
SizedBox(
  height: 25,
),
 Text("Video",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                  
                ),),
 Row(
              children: [
                Text(" Speed ",
                style: TextStyle(
                   color: Colors.grey
                  
                ),),
                SizedBox(
                  width: 15,
                ),
                DropdownButton<String>(
                     value: selectedSpeed,
                    // icon: const Icon(Icons.format_size_rounded,
                    // color: Colors.grey,),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      s(() {
                        selectedSpeed = newValue!;
                      });
                      changeSpeed(selectedSpeed);
                    },
                    items: speeds
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
              ],
            ),
SizedBox(height: 8,),
InkWell(
  onTap: (){
    s(() {
      isLooping=!isLooping;
    });
    _controller.setLooping(isLooping);
  },
  child:   Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
    
      children: [
    
             Text("Looping",
    
                    style: TextStyle(
    
                      // fontSize: 15,
    
                      // fontWeight: FontWeight.bold
    
                      color: Colors.grey
    
                    ),),
    
                    SizedBox(
    
                      width: 15,
    
                    ),
    
                    Text(isLooping?"On":"Off")
    
      ],
    
    ),
  ),
),
SizedBox(height: 15,),
MaterialButton(onPressed: (){
  Navigator.of(context).pop();
},
child: Text("DONE"),
textColor: Colors.white,
color: Theme.of(context).primaryColor,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)

            

          ],
              ),
            ),
          ),
        
      ),
    );
    
    }
);
    }
  

}

  