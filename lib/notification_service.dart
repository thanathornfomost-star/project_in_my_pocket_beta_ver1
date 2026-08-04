import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// ตัวจัดการเมื่อมีข้อความเข้าขณะปิดแอปอยู่ (Background / Terminated)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. ตั้งค่าการจัดการข้อความใน Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. ขออนุญาตผู้ใช้รับการแจ้งเตือน (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    // 3. ตั้งค่า Flutter Local Notifications สำหรับโชว์ Banner ตอนเปิดแอปอยู่ (Foreground)
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // แก้ไข: เปลี่ยนการส่งแบบ Named Argument ให้เป็น Positional Parameter
    await _localNotifications.initialize(initSettings);

    // สร้าง Notification Channel สำหรับ Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'ช่องทางการแจ้งเตือนสำคัญ',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 4. ดักจับข้อความตอนที่แอปเปิดใช้งานอยู่ (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // แก้ไข: เปลี่ยนจากการระบุชื่อพารามิเตอร์ให้ส่งตามลำดับ Positional Arguments
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 5. บันทึก/อัปเดต FCM Token ของผู้ใช้ลง Firestore
    await saveFcmToken();

    // ฟังค่ากรณีมีการอัปเดต Token ใหม่
    _fcm.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });
  }

  // ดึง Token ของเครื่องนี้แล้วเซฟลง User Document
  static Future<void> saveFcmToken() async {
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint("FCM Token saved successfully: $token");
    }
  }
}
