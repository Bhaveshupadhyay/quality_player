import 'package:flutter/material.dart';

extension Responsive on BuildContext{
  bool isMobile() =>
      MediaQuery.sizeOf(this).width < 850;

  bool isTablet() =>
      MediaQuery.sizeOf(this).width < 1100 &&
          MediaQuery.sizeOf(this).width >= 850;

  bool isDesktop() =>
      MediaQuery.sizeOf(this).width >= 1100;

  double screenHeight()=>
      MediaQuery.sizeOf(this).height;
}