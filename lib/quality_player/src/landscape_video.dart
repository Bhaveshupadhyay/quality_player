import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/player_cubit.dart';

class LandscapeVideo extends StatelessWidget {
  final bool alwaysLandscape;
  final Widget player;
  const LandscapeVideo({super.key, this.alwaysLandscape=false, required this.player});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_,x){
        if(alwaysLandscape){
          context.read<PlayerCubit>().disposePlayer();
        }
        else {
          context.read<VideoOrientationCubit>().portrait();
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
}
