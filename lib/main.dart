import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/grocery_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/qr_controller.dart';
import 'views/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => GroceryController()),
        ChangeNotifierProvider(create: (context) => CartController()),
        ChangeNotifierProvider(create: (context) => QRController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FreshMart',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const AuthPage(),
      ),
    );
  }
}
