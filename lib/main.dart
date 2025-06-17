import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:kinclongin/providers/add_picture_provider.dart';
import 'package:kinclongin/Views/LoginRegister/login_page.dart';
import 'package:provider/provider.dart';
import 'package:kinclongin/providers/booking_create_provider.dart';
import 'package:kinclongin/providers/location_provider.dart';
import 'package:kinclongin/providers/checkout_provider.dart';
import 'package:kinclongin/providers/order_provider.dart';
import 'package:kinclongin/providers/user_provider.dart';
import 'package:kinclongin/providers/admin_provider.dart';
import 'package:kinclongin/providers/laundry_services_provider.dart';
import 'package:kinclongin/providers/dynamic_booking_provider.dart';
import 'package:kinclongin/providers/service_provider.dart';
import 'package:kinclongin/providers/rating_provider.dart';
import 'package:kinclongin/providers/chat_provider.dart';
import 'package:kinclongin/Views/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingCreateProvider()),
        ChangeNotifierProvider(create: (_) => AddPictureProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..listenToAuthChanges()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => LaundryServicesProvider()),
        ChangeNotifierProvider(create: (_) => DynamicBookingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const KinclongInApp(),
    ),
  );
}

// void main() => runApp(
//   DevicePreview(
//     enabled: !kReleaseMode,
//     builder: (context) => MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => BookingCreateProvider()),
//         ChangeNotifierProvider(create: (_) => AddPictureProvider()),
//         // kamu bisa tambahkan provider lain juga nanti di sini
//       ],
//       child: const KinclongInApp(),
//     ), // Wrap your app
//   ),
// );

class KinclongInApp extends StatelessWidget {
  const KinclongInApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kinclong.In',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FB), // 🎨 Background warna halaman
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
      // home: HomeCustomerPage(),
    );
  }
}
