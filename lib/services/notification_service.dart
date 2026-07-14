import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/track.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'now_playing_channel';
  static const _notificationId = 1;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings: settings);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> showNowPlaying(Track track, {required bool isPlaying}) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Now Playing',
      channelDescription: 'Menampilkan lagu yang sedang diputar',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      playSound: false,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: false);
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: _notificationId,
      title: track.title,
      body: '${track.artist} • ${isPlaying ? "Sedang diputar" : "Dijeda"}',
      notificationDetails: details,
    );
  }

  Future<void> cancel() => _plugin.cancel(id: _notificationId);
}