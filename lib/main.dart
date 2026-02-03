import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/booking_storage.dart';
import 'services/supabase_booking_repository.dart';
import 'state/booking_store.dart';
import 'ui/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(const SalonBookingApp());
}

class SalonBookingApp extends StatefulWidget {
  const SalonBookingApp({super.key});

  @override
  State<SalonBookingApp> createState() => _SalonBookingAppState();
}

class _SalonBookingAppState extends State<SalonBookingApp> {
  late final BookingStore _store;

  @override
  void initState() {
    super.initState();
    _store = BookingStore(
      repository: SupabaseBookingRepository(),
      settingsStorage: BookingStorage(),
    );
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E2A39);
    const accent = Color(0xFFE7A76C);
    const background = Color(0xFFF8F1E7);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'Maison Bloom 예약 관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,
        fontFamily: 'Georgia',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: HomePage(store: _store),
    );
  }
}
