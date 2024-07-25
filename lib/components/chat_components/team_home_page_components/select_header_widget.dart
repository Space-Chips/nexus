import 'dart:ui';

import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget>
    with SingleTickerProviderStateMixin {
  bool isTeamsActive = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildColumn('YOUR', 'TEAMS', isTeamsActive, () {
            if (!isTeamsActive) {
              setState(() {
                isTeamsActive = true;
                _controller.forward(from: 0);
              });
            }
          }),
          _buildColumn('PRIVATE', 'CHAT', !isTeamsActive, () {
            if (isTeamsActive) {
              setState(() {
                isTeamsActive = false;
                _controller.forward(from: 0);
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _buildColumn(
      String topText, String bottomText, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double t = isActive ? _animation.value : 1 - _animation.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topText,
                style: TextStyle(
                  color: Color.lerp(const Color.fromARGB(150, 158, 158, 158),
                      const Color(0xFF9E9E9E), t),
                  fontSize: lerpDouble(28, 40, t),
                ),
              ),
              Text(
                bottomText,
                style: TextStyle(
                  color: Color.lerp(const Color.fromARGB(150, 255, 255, 255),
                      Colors.white, t),
                  fontSize: lerpDouble(33.6, 48, t),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildHeader();
  }
}
