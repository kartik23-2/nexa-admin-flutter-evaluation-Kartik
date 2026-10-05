import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/firestore_collections.dart';
import '../core/routes/app_routes.dart';
import '../models/expense_model.dart';
import 'expense_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'nexa_admin_alerts',
    'NEXA Admin Alerts',
    description: 'Real-time alerts for approvals, attendance, and administrative tasks.',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initialize() async {
    try {
      // 1. Request Notification Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[NotificationService] User granted permission: ${settings.authorizationStatus}');

      // 2. Setup Local Notifications (Android & iOS)
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            _handlePayloadString(payload);
          }
        },
      );

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 3. Retrieve and Store Device FCM Token
      if (!kIsWeb) {
        _fcmToken = await _fcm.getToken();
        debugPrint('[NotificationService] FCM Device Token: $_fcmToken');
        await _saveTokenToFirestore(_fcmToken);

        _fcm.onTokenRefresh.listen((newToken) async {
          _fcmToken = newToken;
          await _saveTokenToFirestore(newToken);
        });
      }

      // 4. Foreground Notification Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NotificationService] Received foreground message: ${message.notification?.title}');
        _showLocalFromRemote(message);
      });

      // 5. Background / Terminated Interaction Listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[NotificationService] App opened from background message');
        _handleMessagePayload(message.data);
      });

      // Check if opened from a terminated state
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessagePayload(initialMessage.data);
      }
    } catch (e) {
      debugPrint('[NotificationService] Initialization notice: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(user.uid)
            .set({
          'fcmToken': token,
          'tokenUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[NotificationService] Could not persist FCM token: $e');
    }
  }

  void _showLocalFromRemote(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Show test or application-generated notification with deep link payload
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  void _handlePayloadString(String payloadString) {
    try {
      final data = jsonDecode(payloadString) as Map<String, dynamic>;
      _handleMessagePayload(data);
    } catch (e) {
      debugPrint('[NotificationService] Payload decode error: $e');
    }
  }

  /// Deep-link navigation logic: inspects payload and routes to destination
  Future<void> _handleMessagePayload(Map<String, dynamic> data) async {
    final type = data['type']?.toString();
    final expenseId = data['expenseId']?.toString();

    debugPrint('[NotificationService] Deep linking with payload type: $type, expenseId: $expenseId');

    if (type == 'expense_approval' || expenseId != null) {
      if (expenseId != null && expenseId.isNotEmpty) {
        try {
          final expenseService = ExpenseService();
          final expense = await expenseService.getExpenseById(expenseId);
          if (expense != null) {
            AppRoutes.navigatorKey.currentState?.pushNamed(
              AppRoutes.approvalDetail,
              arguments: expense,
            );
            return;
          }
        } catch (_) {}
      }
      // Fallback: navigate to approvals queue list
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.approvals);
    }
  }
}
