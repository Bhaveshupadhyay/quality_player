import 'package:video_player/video_player.dart';

abstract class VideoState{}

 class VideoInitial extends VideoState{}

 class VideoLoading extends VideoState{}
 class VideoInitialized extends VideoState{
  final VideoPlayerController videoPlayerController;
  final bool showControls;
  final List<String>? videoQualities;
  final String? currentQuality;
  VideoInitialized({required this.videoPlayerController, required this.showControls,
   this.videoQualities,this.currentQuality, });
}

class VideoError extends VideoState{
 final String videoLink;

 VideoError(this.videoLink);
}

 class VideoPaused extends VideoState{}

class SubNotActive extends VideoState{}


