import 'package:flutter/material.dart';
import 'package:google_auth/pages/login_page.dart';
import '../controllers/user_controller.dart';
import '../pages/edit_profile_page.dart'; // Import EditProfilePage
import '../pages/contact_info_page.dart'; // Import ContactInfoPage

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserController.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Guest'),
            accountEmail: Text(user?.email ?? 'Email not available'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user?.photoURL == null || user!.photoURL!.isEmpty
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Trang Chủ'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Thông tin cá nhân'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Thông tin liên hệ'),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactInfoPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Đăng Xuất'),
            onTap: () async {
              await UserController.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
