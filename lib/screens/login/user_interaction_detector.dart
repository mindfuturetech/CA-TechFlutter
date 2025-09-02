// user_interaction_detector.dart
import 'package:flutter/material.dart';
import 'session_manager.dart';

class UserInteractionDetector extends StatelessWidget {
  final Widget child;

  const UserInteractionDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager.resetTimer(),
      onPointerMove: (_) => SessionManager.resetTimer(),
      onPointerUp: (_) => SessionManager.resetTimer(),
      child: child,
    );
  }
}