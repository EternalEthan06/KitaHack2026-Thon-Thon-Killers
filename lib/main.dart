import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  // 1. PRINT LINKS IMMEDIATELY
  const fallbackIp = '192.168.68.109';
  print('\n\n================================================');
  print('🚀 SDG CONNECT IS STARTING!');
  print('================================================');
  print('📱 MOBILE ACCESS: http://$fallbackIp:8080');
  print('🏠 WEB DASHBOARD: http://localhost:8080');
  print('================================================\n\n');

  try {
    WidgetsFlutterBinding.ensureInitialized();

    print('🔧 Loading environment...');
    await dotenv.load(fileName: '.env');

    print('📦 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Initialization complete!');
    runApp(const SdgApp());
  } catch (e) {
    print('❌ CRITICAL ERROR DURING STARTUP: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App failed to start: $e\nCheck console for details.'),
        ),
      ),
    ));
  }
}
