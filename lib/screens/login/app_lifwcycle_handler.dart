// app_lifecycle_observer.dart
import 'package:flutter/material.dart';
import 'session_manager.dart';

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    SessionManager.handleAppLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}