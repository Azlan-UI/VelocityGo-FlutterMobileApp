import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'config/mapbox_config.dart';
import 'firebase_options.dart';
import 'services/map_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  IslamabadMapService().initializeMap();
  MapboxConfig.validate();
  if (MapboxConfig.hasAccessToken) {
    MapboxOptions.setAccessToken(MapboxConfig.accessToken);
  }
  runApp(const VelocityGoApp());
}

class VelocityGoApp extends StatelessWidget {
  const VelocityGoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VelocityGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
