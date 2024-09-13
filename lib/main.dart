import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/controllers/user_controller.dart'; // Import UserController từ thư mục controllers
import 'package:google_auth/firebase_options.dart';
import 'package:google_auth/pages/home_page.dart';
import 'package:google_auth/pages/login_page.dart';
import 'package:google_auth/pages/infor_user.dart'; // Import trang infor_user từ thư mục pages
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đặt tên cố định cho ứng dụng Firebase
  const String firebaseAppName = "Yaew";
  late FirebaseApp firebaseApp;

  // Kiểm tra nếu Firebase chưa được khởi tạo, thì khởi tạo nó với tên cố định.
  if (Firebase.apps.any((app) => app.name == firebaseAppName)) {
    firebaseApp = Firebase.app(firebaseAppName);
    print('Firebase app already initialized with name: $firebaseAppName');
  } else {
    try {
      firebaseApp = await Firebase.initializeApp(
        name: firebaseAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully with name: $firebaseAppName');
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }

  // Bạn có thể sử dụng firebaseApp nếu cần thiết
  print('Firebase app name: ${firebaseApp.name}');

  // Đảm bảo kiểm tra tình trạng thông tin cá nhân sau khi Firebase đã được khởi tạo
  bool hasCompletedPersonalInfo = await UserController.hasCompletedPersonalInfo();
  print('Has completed personal info: $hasCompletedPersonalInfo'); // Debug

  runApp(MainApp(hasCompletedPersonalInfo: hasCompletedPersonalInfo));
}

class MainApp extends StatelessWidget {
  final bool hasCompletedPersonalInfo;

  const MainApp({super.key, required this.hasCompletedPersonalInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: UserController.user == null
          ? const LoginPage()
          : hasCompletedPersonalInfo
          ? const HomePage()
          : const InforUserPage(), // Điều hướng đến trang infor_user nếu thông tin chưa được điền
    );
  }
}
