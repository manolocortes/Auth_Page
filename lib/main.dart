import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth_page.dart';
import 'services/cart_service.dart';
import 'scripts/import_sample_data.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // DEVELOPMENT ONLY - Remove this in production
  // Uncomment the line below to import sample data on app start
  //await FirebaseDataImporter.importSampleData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartService(),
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
