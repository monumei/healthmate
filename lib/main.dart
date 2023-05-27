// Firebase credential and packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// User Screens
import 'screens/user/UserDashboard.dart';
import 'screens/user/Profile.dart';
import 'screens/user/AddEntry.dart';
import 'screens/user/EditEntry.dart';
import 'screens/user/UserEntries.dart';

// Auth Screens
import 'screens/auth/SwitchUserType.dart';
import 'screens/auth/LoginPage.dart';
import 'screens/auth/SignupPage.dart';

// Admin Screens
import 'screens/admin/Admin.dart';
import 'screens/admin/AdminSignInPage.dart';
import 'screens/admin/AdminSignUpPage.dart';

// Monitor Screens
import 'screens/monitor/Monitor.dart';
import 'screens/monitor/MonitorSignInPage.dart';
import 'screens/monitor/MonitorSignUpPage.dart';

// Proviers
import 'provider/auth_provider.dart';
import 'provider/entry_provider.dart';
import 'provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => EntryProvider())),
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
        ChangeNotifierProvider(create: ((context) => UserProvider())),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routing',
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/': (context) => const UserDashboard(),
        '/add-entry': (context) => const AddEntry(),
        '/edit-entry': (context) => const EditEntry(),
        '/user-entries': (context) => const UserEntries(),
        '/profile': (context) => const Profile(),
        '/switch-user-type': (context) => const SwitchUserType(),
        '/admin-signin': (context) => const AdminSignInPage(),
        '/admin-signup': (context) => const AdminSignUpPage(),
        '/admin': (context) => const Admin(),
        '/monitor-signin': (context) => const MonitorSignInPage(),
        '/monitor-signup': (context) => const MonitorSignUpPage(),
        '/monitor': (context) => const Monitor()
      },
    );
  }
}
