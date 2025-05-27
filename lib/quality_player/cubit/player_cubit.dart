import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quality_player/quality_player/cubit/player_state.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerCubit extends Cubit<PlayerState>{
  PlayerCubit():super(VideoInitial());
  VideoPlayerController? _controller;
  bool _showControls=false;
  bool _isControlChecking=false;
  int? _currentQuality;


  Future<void> loadVideo({String? link,String? trailerId, required bool? isTrailer,}) async {
    WakelockPlus.enable();
    emit(VideoLoading());

    initVideoPlayer(link: link!);
  }

  Future<void> initVideoPlayer({required String link,int? quality,
    List<VideoQuality>? videoQualities, Duration? seekPosition}) async {

    enableWakeLock();
    emit(VideoLoading());
    try {
      _controller?.dispose();
    } catch (e) {

    }
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        link))
      ..initialize().then((_) {
        if(!isClosed) {
          _controller!.play();
          if(seekPosition!=null){
            _controller!.seekTo(seekPosition);
          }
          _showControls=false;
          emit(VideoInitialized(videoPlayerController: _controller!,
              showControls: _showControls,videoQualities: videoQualities,currentQuality: quality));
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
        showControls: _showControls,currentQuality: _currentQuality));
  }

  void toggleVideoPlay(){
    if(_controller!.value.isPlaying){
      _controller!.pause();
      disableWakeLock();
    }
    else{
      _controller!.play();
      enableWakeLock();
    }

    emit(VideoInitialized(videoPlayerController: _controller!,
        showControls: _showControls,currentQuality: _currentQuality));
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
        showControls: _showControls,currentQuality: _currentQuality));
  }

  Future<void> changeQuality(VideoQuality videoQuality) async {
    if(videoQuality.quality==_currentQuality) return;
    // emit(VideoLoading());
    _currentQuality=videoQuality.quality;
    final currentPosition = _controller!.value.position;
    initVideoPlayer(link: videoQuality.link,quality: videoQuality.quality,seekPosition: currentPosition);

  }

  get currentQuality=>_currentQuality;

  Future<void> enableWakeLock() async {
    if(!await WakelockPlus.enabled){
      await WakelockPlus.enable();
    }
  }

  Future<void> disableWakeLock() async {
    if(await WakelockPlus.enabled){
      await WakelockPlus.disable();
    }
  }

  @override
  Future<void> close() {
    print('dispose');
    disableWakeLock();
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


class VideoQuality {
  final int quality;
  final String link;
  static const int auto=0;

  VideoQuality({
    required this.quality,
    required this.link,
  });
}

