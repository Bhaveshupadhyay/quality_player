import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quality_player/player/responsive.dart';

class PortraitVideo extends StatelessWidget {
  final double? height;
  final Widget player;
  const PortraitVideo({super.key, required this.player, this.height});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return SafeArea(
      child: Container(
        height: height?? (MediaQuery.sizeOf(context).height * (Responsive.isMobile(context)? 0.25 : 0.35)),
        width: double.infinity,
        color: Colors.black,
        child: player,
      ),
    );
  }
}