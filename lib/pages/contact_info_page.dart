import 'dart:async';
import 'package:flutter/material.dart';

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({Key? key}) : super(key: key);

  @override
  _ContactInfoPageState createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/1.jpg',
    'assets/2.jpg',
    'assets/1.jpg',
    'assets/2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Thiết lập Timer để tự động chuyển đổi trang sau mỗi 3 giây
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'THÔNG TIN LIÊN HỆ',
          style: TextStyle(
            color: Colors.black, // Màu chữ đen
            fontWeight: FontWeight.bold, // Chữ in đậm
          ),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.white, // Đặt màu nền AppBar thành màu trắng
        elevation: 0, // Bỏ đổ bóng (nếu muốn giao diện phẳng hơn)
        iconTheme: const IconThemeData(color: Colors.black), // Đổi màu các biểu tượng AppBar (nếu có)
      ),
      body: Column(
        children: [
          // Khung ảnh chạy liên tục với viền và bóng đổ
          Container(
            height: 200,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Thay đổi vị trí của bóng đổ
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _images[index],
                    fit: BoxFit.cover, // Chỉnh fit để làm khớp hình ảnh vào khung
                  );
                },
              ),
            ),
          ),

          // Phần dưới màn hình với các mục thông tin liên hệ được bo góc và viền màu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Gmail',
                    subtitle: '0950080093@sv.hcmunre.edu.vn',
                    color: Colors.blue.shade50,
                    borderColor: Colors.blue,
                  ),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Điện thoại liên lạc',
                    subtitle: '+84 376024561',
                    color: Colors.green.shade50,
                    borderColor: Colors.green,
                  ),
                  _buildContactItem(
                    icon: Icons.location_on,
                    title: 'Địa chỉ',
                    subtitle: '236 Đ. Lê Văn Sỹ, Phường 1, Tân Bình, Hồ Chí Minh',
                    color: Colors.orange.shade50,
                    borderColor: Colors.orange,
                  ),
                  _buildContactItem(
                    icon: Icons.web,
                    title: 'Website',
                    subtitle: 'www.www.com',
                    color: Colors.purple.shade50,
                    borderColor: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng từng mục thông tin liên hệ với viền và bo góc
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: borderColor),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
