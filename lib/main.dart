import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/player_service.dart';
import 'services/session_manager.dart';
import 'services/notification_service.dart';
import 'models/track.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SessionManager().isLoggedIn();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerService(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      builder: (context, child) => NowPlayingNotificationListener(child: child!),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

class NowPlayingNotificationListener extends StatefulWidget {
  const NowPlayingNotificationListener({super.key, required this.child});
  final Widget child;

  @override
  State<NowPlayingNotificationListener> createState() =>
      _NowPlayingNotificationListenerState();
}

class _NowPlayingNotificationListenerState
    extends State<NowPlayingNotificationListener> {
  PlayerService? _player;
  Track? _lastTrack;
  bool? _lastIsPlaying;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final player = context.read<PlayerService>();
    if (_player != player) {
      _player?.removeListener(_onPlayerChanged);
      _player = player;
      _player!.addListener(_onPlayerChanged);
      NotificationService().init();
    }
  }

  void _onPlayerChanged() {
    final track = _player?.currentTrack;
    final isPlaying = _player?.isPlaying ?? false;
    if (track == null) return;

    if (track.id != _lastTrack?.id || isPlaying != _lastIsPlaying) {
      _lastTrack = track;
      _lastIsPlaying = isPlaying;
      NotificationService().showNowPlaying(track, isPlaying: isPlaying);
    }
  }

  @override
  void dispose() {
    _player?.removeListener(_onPlayerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}