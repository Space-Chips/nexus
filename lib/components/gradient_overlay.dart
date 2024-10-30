import 'dart:ui';
import 'package:flutter/material.dart';

class GradientOverlay extends StatelessWidget {
  final double height;
  final double blurIntensity;
  final double gradientOpacity;

  const GradientOverlay({
    super.key,
    this.height = 154,
    this.blurIntensity = 8.0,
    this.gradientOpacity = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: height + 20, // Add extra height for blur overflow
        child: ClipRect(
          child: Container(
            width: double.infinity,
            // Move the container up to hide the extra blur area
            margin: EdgeInsets.only(top: 20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurIntensity,
                    sigmaY: blurIntensity,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.3, 1.0],
                      colors: [
                        Colors.black.withOpacity(gradientOpacity),
                        Colors.black.withOpacity(gradientOpacity * 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
