import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/apps_screen.dart';
import 'screens/app_detail_screen.dart';
import 'services/auth_service.dart';
import 'services/mongodb_service.dart';
import 'services/payment_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize MongoDB
    await MongoDBService.instance.connect();
    
    // Initialize Stripe
    await PaymentService.instance.initializeStripe();
    
    print('✅ All services initialized');
  } catch (e) {
    print('⚠️  Service initialization error: $e');
    print('App will continue with limited functionality');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AB Tree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Route guard for protected routes
        if (settings.name == '/payment' || 
            settings.name == '/apps' || 
            settings.name == '/app-detail') {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<bool>(
              future: AuthService.instance.isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.data == true) {
                  // User is logged in, allow access
                  switch (settings.name) {
                    case '/payment':
                      return const PaymentScreen();
                    case '/apps':
                      return const AppsScreen();
                    case '/app-detail':
                      return const AppDetailScreen();
                    default:
                      return const LoginScreen();
                  }
                } else {
                  // User is not logged in, redirect to login
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/');
                  });
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          );
        }

        // Public routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
