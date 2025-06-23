import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quality_player/quality_player/src/potrait_video.dart';
import 'package:quality_player/quality_player/src/responsive.dart';
import 'package:quality_player/quality_player/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import 'landscape_video.dart';


class QualityPlayer extends StatefulWidget {
  ///Default video link
  final String link;
  final bool alwaysLandscape;
  final double? height;
  final VoidCallback? onExitIconTap;
  final List<VideoQuality>? videoQualities;
  const QualityPlayer({super.key, required this.link, this.height,
    this.onExitIconTap, this.videoQualities, this.alwaysLandscape=false,});

  @override
  State<QualityPlayer> createState() => _QualityPlayerState();
}

class _QualityPlayerState extends State<QualityPlayer> {

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (create)=>PlayerCubit()..initVideoPlayer(link: widget.link)),
        BlocProvider(create: (create)=>VideoOrientationCubit()..changeOrientation(toLandscape: widget.alwaysLandscape)),
      ],
      child: BlocBuilder<VideoOrientationCubit,Orientation>(
        builder: (context,orientation){
          return orientation == Orientation.landscape?
          LandscapeVideo(player: _vPlayer(iconSize: Responsive.isMobile(context)? 25 : 35,isLandscape: true),alwaysLandscape: widget.alwaysLandscape,):
          PortraitVideo(player: _vPlayer(iconSize: Responsive.isMobile(context)? 25 : 35));
        },
      ),
    );
  }

  Widget _vPlayer({required double iconSize,bool isLandscape=false})=>
      BlocBuilder<PlayerCubit,PlayerState>(
          builder: (context,PlayerState state){
            if(state is VideoInitialized){
              return GestureDetector(
                  onTap: (){
                    context.read<PlayerCubit>().toggleControls();
                  },
                  child: _player(context: context,
                      state: state,
                      iconSize: iconSize,
                      isLandscape: isLandscape,
                    fontSize: Responsive.isMobile(context)? 14 : 18
                  )
              );
            }
            else if(state is VideoLoading){
              return SizedBox(
                height: isLandscape? double.infinity :
                widget.height?? (MediaQuery.sizeOf(context).height * (Responsive.isMobile(context)? 0.25 : 0.55 )),
                child: SafeArea(
                  left: isLandscape,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          top: Responsive.isMobile(context)? 5: 10,
                          left: Responsive.isMobile(context)? 5: 10,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(
                              onTap: widget.onExitIconTap??()=>Navigator.pop(context),
                              child: Icon(
                                Icons.close_sharp,size: iconSize,color: Colors.white,),
                            ),
                          )
                      ),
                      const Center(child: CircularProgressIndicator(color:  Colors.white,),),
                    ],
                  ),
                ),
              );
            }
            else if(state is VideoError){
              return Stack(
                children: [
                  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Playback error",style: TextStyle(color: Colors.white,fontSize: 12),),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: (){
                              context.read<PlayerCubit>().initVideoPlayer(link: state.videoLink);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Text("Retry",
                                style: TextStyle(color: Colors.black,fontSize: 10),
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                  Positioned.fill(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: widget.onExitIconTap??()=>Navigator.pop(context),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.arrow_back_ios,size: 30,color: Colors.white,),
                          ),
                        ),
                      )
                  )
                ],
              );
            }
            return SizedBox.shrink();
          }
      );

  Widget _player({required BuildContext context, required VideoInitialized state,
    required double iconSize,required double fontSize, bool isLandscape=false}){
    return GestureDetector(
      onScaleStart: (scale){
        // print(scale.focalPoint);
      },

      child: Stack(
        children: [
          isLandscape?
          Center(
            child: AspectRatio(
                aspectRatio: state.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(state.videoPlayerController)
            ),
          )
          :
              SizedBox(
                child: VideoPlayer(state.videoPlayerController),
              ),

          ValueListenableBuilder(valueListenable: state.videoPlayerController,
            builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
              if(value.isBuffering) {
                // final range= value.buffered.isNotEmpty? value.buffered[value.buffered.length-1] :
                // DurationRange(Duration(),Duration());
                // print('${value.buffered} ${range.end.inSeconds-range.start.inSeconds<8}');
                // if(range.end.inSeconds-range.start.inSeconds<8) {
                //   return const Center(child: CircularProgressIndicator(color:  Colors.white,),);
                // }

                return const Center(child: CircularProgressIndicator(color:  Colors.white,),);
              }
              return SizedBox.shrink();
            },
          ),
          Container(color: state.showControls? Colors.black45 : Colors.transparent,),

          Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: state.showControls? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: ()=>state.showControls?context.read<PlayerCubit>().backwardVideo():
                        context.read<PlayerCubit>().toggleControls(),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle
                            ),
                            child: Icon(
                              Icons.replay_10,
                              size: iconSize,
                              color: Colors.white,
                            )
                        ),
                      ),
                      InkWell(
                        onTap: ()=>state.showControls?context.read<PlayerCubit>().toggleVideoPlay():
                        context.read<PlayerCubit>().toggleControls(),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                            state.videoPlayerController.value.isPlaying?
                            Icons.pause:Icons.play_arrow,
                            size: iconSize,
                            color: Colors.white,),
                        ),
                      ),
                      InkWell(
                        onTap: ()=>state.showControls?context.read<PlayerCubit>().forwardVideo():
                        context.read<PlayerCubit>().toggleControls(),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                            Icons.forward_10,
                            size: iconSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),

          Positioned.fill(
              // bottom: isLandscape??false? Responsive.isMobile(context)? 40: 60: 0,
              left: isLandscape? Responsive.isMobile(context)? 5: 10:0,
              right: isLandscape?Responsive.isMobile(context)? 5: 10:0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ValueListenableBuilder(
                  valueListenable: state.videoPlayerController,
                  builder: (BuildContext context, value, Widget? child) {
                    final currentPosition = Utils.formatDuration(value.position);
                    final totalDuration = Utils.formatDuration(value.duration);
                    return AnimatedOpacity(
                      opacity: state.showControls? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: SafeArea(
                        left: isLandscape,
                        right: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: Responsive.isMobile(context)? 5: 10,
                                  horizontal: isLandscape? 0: Responsive.isMobile(context)? 5: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$currentPosition : $totalDuration',
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: Colors.white,
                                        fontSize: fontSize
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      if(state.showControls){
                                        isLandscape?
                                        context.read<VideoOrientationCubit>().portrait():
                                        context.read<VideoOrientationCubit>().landscape();
                                      }
                                    },
                                    child: Icon(isLandscape? Icons.fullscreen_exit : Icons.fullscreen,
                                      color:Colors.white,
                                      size: iconSize,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            VideoProgressIndicator(
                                state.videoPlayerController,
                                allowScrubbing: true
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
          ),

          Positioned.fill(
              top: Responsive.isMobile(context)? 5: 10,
              right: Responsive.isMobile(context)? 5: 10,
              child: AnimatedOpacity(
                opacity: state.showControls? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.topRight,
                  child:  Visibility(
                    visible: state.showControls,
                    child: InkWell(
                        onTap: (){
                          _showBottomDialog(
                              context: context,
                              controller: state.videoPlayerController,
                              videoQualities: widget.videoQualities??[],
                              currentQuality: state.currentQuality,
                              isLandscape: isLandscape
                          );
                        },
                        child: Icon(Icons.settings,
                          size: iconSize,
                          color: Colors.white,
                        )),
                  ),
                ),
              )
          ),

          Positioned.fill(
              top: Responsive.isMobile(context)? 5: 10,
              left: Responsive.isMobile(context)? 5: 10,
              child: Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  left: isLandscape,
                  child: AnimatedOpacity(
                    opacity: state.showControls? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: InkWell(
                      onTap: widget.onExitIconTap??(){
                        if(isLandscape){
                          if(state.showControls) {
                            if(widget.alwaysLandscape){
                              Navigator.pop(context);
                            }
                            else{
                              context.read<VideoOrientationCubit>().portrait();
                            }
                          }
                          else{
                            context.read<PlayerCubit>().toggleControls();
                          }
                        }
                        else{
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.close_sharp,
                        size: iconSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  void _showBottomDialog({required BuildContext context,
    required VideoPlayerController controller,required List<VideoQuality> videoQualities,
    required int? currentQuality,bool? isLandscape}){

    int? currentQuality= context.read<PlayerCubit>().currentQuality;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (c){
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomSettingsIcon(
                      context: context,
                      settingsName: 'Quality',
                      settingsIcon: Icons.high_quality_outlined,
                      value: currentQuality==VideoQuality.auto || currentQuality==null ?'Auto': '${currentQuality}p',
                      onTap: () {
                        _videoQualityDialog(context: context, controller: controller,
                            videoQualities: videoQualities,currentQuality: currentQuality??VideoQuality.auto,
                            isLandscape: isLandscape);
                      },
                    isLandscape: isLandscape
                  ),
                  _bottomSettingsIcon(
                      context: context,
                      settingsName: 'Playback speed',
                      settingsIcon: Icons.speed,
                      value: '${controller.value.playbackSpeed}',
                      onTap: () {
                        _playBackDialog(context: context,controller: controller,isLandscape: isLandscape);
                      },
                      isLandscape: isLandscape
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _bottomSettingsIcon({required BuildContext context,
    required String settingsName,required IconData settingsIcon,
    required String value, required VoidCallback onTap,
    bool? isLandscape}){

    final double iconSize= Responsive.isMobile(context)? 25 : 35;
    final double fontSize= Responsive.isMobile(context)? 15 : 20;

    final theme= Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isLandscape== true? 12: 8,),
        child: Row(
          children: [
            Icon(settingsIcon,size: iconSize,),
            SizedBox(width: 20,),
            Text(settingsName,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold
                )
            ),
            Spacer(),
            Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Icon(Icons.arrow_forward_ios,size: iconSize/2,),
          ],
        ),
      ),
    );
  }

  void _videoQualityDialog({required BuildContext context,
    required VideoPlayerController controller, required List<VideoQuality> videoQualities,
    required int currentQuality,bool? isLandscape}){

    final double fontSize= Responsive.isMobile(context)? 15 : 20;
    final double iconSize=fontSize;

    final theme= Theme.of(context);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (c){
          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: videoQualities.map((videoQuality)=>
                      InkWell(
                        onTap: (){
                          context.read<PlayerCubit>().changeQuality(videoQuality);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Opacity(
                                  opacity: videoQuality.quality==currentQuality? 1 : 0,
                                  child: Icon(Icons.check,size: iconSize,)
                              ),
                              SizedBox(width: 10,),
                              Text(videoQuality.quality==0? 'Auto' : '${videoQuality.quality}p',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  )),
                            ],
                          ),
                        ),
                      )).toList(),
                ),
              ),
            ),
          );
        }
    );
  }

  void _playBackDialog({required BuildContext context, required VideoPlayerController controller,
    bool? isLandscape}){

    final double fontSize= Responsive.isMobile(context)? 15 : 20;
    final double iconSize=fontSize;

    final theme= Theme.of(context);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (c){
          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [0.25,0.5,1.0,1.25,1.5,2.0].map((e)=>
                      InkWell(
                        onTap: (){
                          context.read<PlayerCubit>().changeSpeed(e);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Opacity(
                                  opacity: e==controller.value.playbackSpeed? 1 : 0,
                                  child: Icon(Icons.check,size: iconSize,)
                              ),
                              SizedBox(width: 10,),
                              Text('$e',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  )),
                            ],
                          ),
                        ),
                      )).toList(),
                ),
              ),
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
