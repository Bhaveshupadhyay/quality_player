import 'package:quality_player/quality_player/cubit/player_cubit.dart';
import 'package:video_player/video_player.dart';

abstract class PlayerState{}

 class VideoInitial extends PlayerState{}

 class VideoLoading extends PlayerState{}
 class VideoInitialized extends PlayerState{
  final VideoPlayerController videoPlayerController;
  final bool showControls;
  final List<VideoQuality>? videoQualities;
  final int? currentQuality;
  VideoInitialized({required this.videoPlayerController, required this.showControls,
   this.videoQualities,this.currentQuality, });
}

class VideoError extends PlayerState{
 final String videoLink;

 VideoError(this.videoLink);
}

 class VideoPaused extends PlayerState{}

class SubNotActive extends PlayerState{}


