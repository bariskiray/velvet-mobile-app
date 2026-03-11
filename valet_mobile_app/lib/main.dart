import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/view/business_home_view.dart';
import 'package:valet_mobile_app/views/business/business_home/view/valet_list_view.dart';
import 'package:valet_mobile_app/views/business/business_login/view/business_login_view.dart';
import 'package:valet_mobile_app/views/mainPage.dart';
import 'package:valet_mobile_app/views/valet/valet_home/valet_home_screen_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_login_view.dart';
import 'package:valet_mobile_app/views/business/parking_spots/view/business_parking_spots_view.dart';
import 'package:valet_mobile_app/views/business/parking_spots/controller/business_parking_spots_controller.dart';

// Bildirim kanalları için Android ayarları
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'Yüksek Öncelikli Bildirimler', // title
  description: 'Bu kanal checkout bildirimleri için kullanılır.', // description
  importance: Importance.high,
);

// Flutter Local Notifications eklentisi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Arka planda gelen mesajları işlemek için
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Arka planda mesaj alındı: ${message.messageId}");
  print("Mesaj içeriği: ${message.notification?.title} - ${message.notification?.body}");
  print("Ek veriler: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('====== FIREBASE BAŞLATILIYOR ======');
    // Firebase'i default options ile başlat
    await Firebase.initializeApp();
    print('Firebase başlatıldı!');

    // Arka plan mesaj işleyiciyi ayarla
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications ayarları
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Local notifications initialization
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        print('Bildirime tıklandı! Payload: ${notificationResponse.payload}');
        // Bildirime tıklandı. Payload'dan veri alınabilir ve işlenebilir
        if (notificationResponse.payload != null) {
          try {
            final payloadData = json.decode(notificationResponse.payload!);
            if (payloadData.containsKey('ticket_id')) {
              // Bilet detay sayfasına git
              print('Bildirim tıklamasıyla Ticket ID: ${payloadData['ticket_id']} işlenebilir');
            }
          } catch (e) {
            print('Payload parse hatası: $e');
          }
        }
      },
    );

    // iOS için bildirim ayarları
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM bildirim izinlerini iste
    print('Bildirim izinleri isteniyor...');
    var settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Bildirim izin durumu: ${settings.authorizationStatus}');

    // FCM token kontrolü
    print('FCM token alınıyor...');
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('FCM Token başarıyla alındı: $token');
      print('Token uzunluğu: ${token.length} karakter');
    } else {
      print('!!UYARI!! FCM Token alınamadı, token değeri: NULL');
    }

    // Bildirim dinleyicilerini ayarla
    _setupFirebaseMessagingListeners();
  } catch (e) {
    print('!!HATA!! Firebase başlatma hatası: $e');
    print('Hata detayı: ${e.toString()}');
  }

  // Initialize controllers
  Get.put(AuthController()); // AuthController'ı initialize et

  // Initialize API Service
  ApiService.initializeInterceptors();

  runApp(const MyApp());
}

// Bildirim dinleyicilerini kurma
void _setupFirebaseMessagingListeners() {
  // Ön planda (uygulama açıkken) gelen bildirimleri dinle
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("=== ÖN PLANDA BİLDİRİM ALINDI ===");
    print("Bildirim ID: ${message.messageId}");
    print("Başlık: ${message.notification?.title}, İçerik: ${message.notification?.body}");
    print("Veri: ${message.data}");

    RemoteNotification? notification = message.notification;

    // Ön planda bildirimi göstermek için iki yaklaşım kullanıyoruz
    // 1. Local notifications ile standart bildirim
    // 2. Get.snackbar ile uygulama içi bildirim
    if (notification != null) {
      // 1. Local notifications
      try {
        print('Lokal bildirim göstermeye çalışılıyor...');
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? "Yeni Bildirim",
          notification.body ?? "Bildirim detayları",
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
        print('Lokal bildirim gösterildi!');
      } catch (e) {
        print('!!HATA!! Lokal bildirim gösterirken hata: $e');
      }

      // 2. Snackbar ile uygulama içi bildirim (her durumda göster)
      Get.snackbar(
        notification.title ?? 'Yeni Bildirim',
        notification.body ?? 'Bildirim detayları için tıklayın',
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: EdgeInsets.all(8),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );

      print('✅ Snackbar bildirimi gösterildi!');
    } else {
      print('⚠️ Bildirim içeriği (notification) boş!');
    }
  });

  // App açıkken ve minimize durumdayken bildirimleri dinle
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Bildirim tıklandı! ${message.data}');

    // Bildirime tıklanınca yönlendirme yapılabilir
    if (message.data.containsKey('ticket_id')) {
      // Örneğin ticket detay sayfasına yönlendirme yapılabilir
      print('Ticket ID: ${message.data['ticket_id']} için işlem yapılabilir');
      // Get.toNamed('/ticket-detail', arguments: {'ticket_id': message.data['ticket_id']});
    }
  });

  // App kapalıyken gelen bildirimle açılma durumunu kontrol et
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print('App bildirimle açıldı! ${message.data}');

      // Bildirimle açılınca yönlendirme yapılabilir
      if (message.data.containsKey('ticket_id')) {
        print('App başlatıldı ve ticket_id: ${message.data['ticket_id']} ile yönlendirme yapılabilir');
        // Get.toNamed('/ticket-detail', arguments: {'ticket_id': message.data['ticket_id']});
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Valet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/mainPage',
      getPages: [
        GetPage(
          name: '/business-login',
          page: () => const BusinessLoginView(),
        ),
        GetPage(
          name: '/valet-login',
          page: () => const ValetLoginView(),
        ),
        GetPage(
          name: '/valet-home',
          page: () => const ValetHomeView(),
        ),
        GetPage(name: '/businessHome', page: () => BusinessHomeView()),
        GetPage(name: '/mainPage', page: () => const MainPage()),
        GetPage(name: '/valetList', page: () => const ValetListView()),
        GetPage(
          name: '/parking-spots',
          page: () => const BusinessParkingSpotsView(),
          binding: BindingsBuilder(() {
            Get.put(BusinessParkingSpotsController());
          }),
        ),
      ],
      defaultTransition: Transition.fade,
    );
  }
}
