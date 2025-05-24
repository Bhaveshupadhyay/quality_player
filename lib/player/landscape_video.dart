import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/video_cubit.dart';

class LandscapeVideo extends StatelessWidget {
  final bool? isTrailer;
  final Widget player;
  const LandscapeVideo({super.key, this.isTrailer, required this.player});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // _hideStatusBar();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_,x){
        context.read<VideoOrientationCubit>().portrait();
        if(isTrailer??false){
          context.read<VideoCubit>().disposePlayer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: player
        ),
      ),
    );
  }

  void _hideStatusBar(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
  }
}
