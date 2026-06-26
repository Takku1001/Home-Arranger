import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/new_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ar_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/orders_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable reCAPTCHA for development (fixes CONFIGURATION_NOT_FOUND error)
  if (kDebugMode) {
    await FirebaseAuth.instance
        .setSettings(appVerificationDisabledForTesting: true);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const IkeaARApp());
}

class IkeaARApp extends StatefulWidget {
  const IkeaARApp({super.key});

  @override
  State<IkeaARApp> createState() => _IkeaARAppState();
}

class _IkeaARAppState extends State<IkeaARApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final CartNotifier _cartNotifier = CartNotifier();

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: CartProvider(
        cartNotifier: _cartNotifier,
        child: MaterialApp(
          title: 'Home Arranger',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: ThemeData(
            primaryColor: const Color(0xFF0058A3),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0058A3),
              primary: const Color(0xFF0058A3),
              secondary: const Color(0xFFFBD914),
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0058A3),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0058A3),
              primary: const Color(0xFF0058A3),
              secondary: const Color(0xFFFBD914),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
          ),
          initialRoute: '/auth',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const NewHomeScreen(),
            '/store': (context) => const HomeScreen(),
            '/ar': (context) => const ARScreen(),
            '/product': (context) => const ProductDetailScreen(),
            '/cart': (context) => const CartScreen(),
            '/orders': (context) => const OrdersScreen(),
            '/admin': (context) => const AdminLoginScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
          },
        ),
      ),
    );
  }
}

class ThemeController extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const ThemeController({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required Widget child,
  }) : super(child: child);

  static ThemeController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeController>();
  }

  @override
  bool updateShouldNotify(covariant ThemeController oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}
