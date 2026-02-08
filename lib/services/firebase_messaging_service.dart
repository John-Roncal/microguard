import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Inicializar Firebase Messaging
  Future<void> initialize() async {
    // Solicitar permisos
    await _requestPermissions();

    // Configurar notificaciones locales
    await _initializeLocalNotifications();

    // Configurar handlers para notificaciones
    _configureFirebaseListeners();
  }

  // Solicitar permisos para notificaciones
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Usuario autorizó notificaciones');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Usuario autorizó notificaciones provisionales');
    } else {
      print('Usuario denegó notificaciones');
    }
  }

  // Obtener el token FCM
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveFcmToken(token);
        return token;
      }
      return null;
    } catch (e) {
      print('Error al obtener FCM token: $e');
      return null;
    }
  }

  // Guardar token en SharedPreferences
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  // Obtener token guardado
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  // Configurar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Configurar listeners para mensajes de Firebase
  void _configureFirebaseListeners() {
    // Cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Cuando la app está en background y se toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.notification?.title}');
      // Aquí puedes navegar a una pantalla específica
    });

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('Token actualizado: $newToken');
      _saveFcmToken(newToken);
    });
  }

  // Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'default_channel',
      'Notificaciones',
      channelDescription: 'Canal para notificaciones generales',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,  // id (parámetro posicional 1)
      message.notification?.title ?? 'Nueva notificación',  // title (posicional 2)
      message.notification?.body ?? '',  // body (posicional 3)
      platformChannelSpecifics,  // notificationDetails (posicional 4)
      payload: message.data.toString(),  // payload (NOMBRADO)
    );
  }

  // Eliminar token al cerrar sesión
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('Token FCM eliminado');
    } catch (e) {
      print('Error al eliminar token: $e');
    }
  }
}

// Handler para notificaciones en background (debe estar en nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en background: ${message.notification?.title}');
}