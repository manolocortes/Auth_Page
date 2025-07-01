import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'import_sample_data.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  print('🔥 Firebase initialized');
  print('📦 Starting data import...');
  
  // Import sample data
  await FirebaseDataImporter.importSampleData();
  
  print('✅ Database setup complete!');
  print('🚀 You can now run your app');
}
