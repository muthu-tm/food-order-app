import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';

class GradientText extends StatelessWidget {
  GradientText(
    this.text, {
    @required this.gradient,
    @required this.size,
  });

  final String text;
  final Gradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: CustomColors.white,
          fontSize: size,
        ),
      ),
    );
  }
}
