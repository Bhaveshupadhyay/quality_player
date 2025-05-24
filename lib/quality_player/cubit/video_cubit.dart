import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quality_player/quality_player/cubit/video_state.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoCubit extends Cubit<VideoState>{
  VideoCubit():super(VideoInitial());
  VideoPlayerController? _controller;
  bool _showControls=false;
  bool _isControlChecking=false;
  String? currentQuality;


  Future<void> loadVideo({String? link,String? trailerId, required bool? isTrailer,}) async {
    WakelockPlus.enable();
    emit(VideoLoading());

    initVideoPlayer(link: link!);
  }

  Future<void> initVideoPlayer({required String link,String? quality,}) async {
    // print(link);
    emit(VideoLoading());
    // print(quality);
    try {
      _controller?.dispose();
    } catch (e) {
      // print('null');
    }
    // link="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";

    _controller = VideoPlayerController.networkUrl(Uri.parse(
        link))
      ..initialize().then((_) {

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if(!isClosed) {
          // if(lastWatchedPosition!=null){
          //   _controller!.seekTo(Duration(seconds: lastWatchedPosition??0));
          // }
          _controller!.play();
          _showControls=false;
          emit(VideoInitialized(videoPlayerController: _controller!,
              showControls: _showControls,videoQualities: [],currentQuality: quality));
        }
      },onError: (_){
        if(!isClosed){
          emit(VideoError(link));
        }
      });
    _controller!.addListener(() async {
      if(_controller!.value.isPlaying && _showControls && !_isControlChecking){
        _isControlChecking=true;
        await Future.delayed(const Duration(seconds: 3));
        _isControlChecking=false;
        if(_controller!.value.isPlaying && _showControls && !isClosed){
          // print("showC $_showControls");
          _showControls=!_showControls;
          emit(VideoInitialized(videoPlayerController: _controller!,
              showControls: _showControls,videoQualities: [],currentQuality: quality));
        }
      }
    });
    }



  void toggleControls(){
    _showControls=!_showControls;
    emit(VideoInitialized(videoPlayerController: _controller!,
        showControls: _showControls,videoQualities: []));
  }

  void toggleVideoPlay(){
    _controller!.value.isPlaying?
        _controller!.pause(): _controller!.play();

    emit(VideoInitialized(videoPlayerController: _controller!,
        showControls: _showControls,videoQualities: []));
  }

  void forwardVideo(){
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
  }

  void disposePlayer(){
    if(_controller!=null) {
      _controller!.dispose();
    }
  }

  void backwardVideo(){
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
  }

  void changeSpeed(double speed){
    if(speed==_controller!.value.playbackSpeed) return;
    _controller!.setPlaybackSpeed(speed);
    emit(VideoInitialized(videoPlayerController: _controller!,
        showControls: _showControls,videoQualities: []));
  }

  Future<void> changeQuality(String quality) async {
    // if(quality==currentQuality) return;
    // // emit(VideoLoading());
    // String? link;
    // List<VideoVersion>? list;
    // if(quality.toLowerCase()=='adaptive'){
    //   list=videoData?.hlsVersions;
    // }
    // else if(int.parse(quality)>=720){ //hd versions
    //   list=videoData?.hdVersions;
    // }
    // else{
    //   list=videoData?.sdVersions;
    // }
    // for(VideoVersion videoVersion in list??[]){
    //   if(videoVersion.rendition.contains(quality)){
    //     link=videoVersion.link;
    //     break;
    //   }
    // }
    // // print(link);
    // if(link!=null){
    //   currentQuality=quality;
    //   lastWatchedPosition=(await _controller?.position)?.inSeconds;
    //   initVideoPlayer(link: link,quality: quality,);
    // }
  }


  @override
  Future<void> close() {
    // print('dispose');
    WakelockPlus.disable();
    if(_controller!=null) {
      _controller!.dispose();
    }
    return super.close();
  }

}

class VideoOrientationCubit extends Cubit<Orientation>{
  VideoOrientationCubit():super(Orientation.portrait);

  void landscape(){
    emit(Orientation.landscape);
  }

  void portrait(){
    emit(Orientation.portrait);
  }
}


class VideoVersion {
  final String rendition;
  final String link;
  final String size;

  VideoVersion({
    required this.rendition,
    required this.link,
    required this.size,
  });

  factory VideoVersion.fromJson(Map<String, dynamic> json) {
    return VideoVersion(
      rendition: json['rendition'],
      link: json['link'],
      size: json['size'],
    );
  }
}

