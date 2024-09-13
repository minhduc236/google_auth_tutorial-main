import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_auth/controllers/user_controller.dart';
import 'package:iconly/iconly.dart';
import 'package:google_auth/pages/home_page.dart';
import 'package:google_auth/pages/infor_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Khai báo TextEditingController cho email và password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView( // Đảm bảo cuộn được khi bàn phím bật lên
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Image.asset('assets/food.png'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chào mừng bạn!',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    "Hỗ trợ nâng cao sức khỏe của bạn là vinh hạnh và ưu tiên hàng đầu của chúng tôi!",
                    textAlign: TextAlign.center,
                  ),
                ),
                // Trường nhập liệu email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Trường nhập liệu password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      final user = await UserController.loginWithEmail(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (user != null) {
                        bool hasCompletedPersonalInfo = await UserController.hasCompletedPersonalInfo();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => hasCompletedPersonalInfo
                                ? const HomePage()
                                : const InforUserPage(),
                          ));
                        }
                      }
                    } on FirebaseAuthException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.message ?? "Đã xảy ra lỗi khi đăng nhập."),
                      ));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Đã xảy ra lỗi khi đăng nhập."),
                      ));
                    }
                  },
                  icon: const Icon(IconlyLight.login),
                  label: const Text('Đăng nhập bằng Email'),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      final user = await UserController.loginWithGoogle();
                      if (user != null) {
                        bool hasCompletedPersonalInfo = await UserController.hasCompletedPersonalInfo();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => hasCompletedPersonalInfo
                                ? const HomePage()
                                : const InforUserPage(),
                          ));
                        }
                      }
                    } on FirebaseAuthException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.message ?? "Đã xảy ra lỗi khi đăng nhập."),
                      ));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Đã xảy ra lỗi khi đăng nhập."),
                      ));
                    }
                  },
                  icon: const Icon(IconlyLight.login),
                  label: const Text('Đăng nhập bằng Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
