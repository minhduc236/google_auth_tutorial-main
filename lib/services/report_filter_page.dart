// pages/report_filter_page.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Import thư viện Timer
import '../controllers/user_controller.dart';
import 'report_page.dart';

class ReportFilterPage extends StatefulWidget {
  const ReportFilterPage({Key? key}) : super(key: key);

  @override
  ReportFilterPageState createState() => ReportFilterPageState();
}

class ReportFilterPageState extends State<ReportFilterPage> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/5.png',
    'assets/6.jpg',
    'assets/3.png',
    'assets/4.jpg',
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
      appBar: AppBar(title: const Text('Chọn loại báo cáo')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildReportTile('Báo cáo Ngày', () => _generateReport(context, 'Ngày')),
                  _buildReportTile('Báo cáo Tuần', () => _generateReport(context, 'Tuần')),
                  _buildReportTile('Báo cáo Tháng', () => _generateReport(context, 'Tháng')),
                  _buildReportTile('Báo cáo Năm', () => _generateReport(context, 'Năm')),
                ],
              ),
            ),
          ),
          // Khung ảnh với viền và đổ bóng, chạy liên tục
          Container(
            height: 250,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Vị trí của bóng đổ
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _images[index],
                    fit: BoxFit.cover, // Chỉnh fit cho hình ảnh
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo từng mục danh sách với viền bo góc và màu sắc
  Widget _buildReportTile(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Màu nền nhạt
        borderRadius: BorderRadius.circular(16.0), // Bo góc cho container
        border: Border.all(color: Colors.blue.shade200, width: 2), // Viền màu xanh
      ),
      child: ListTile(
        title: Text(title),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }

  // Không sử dụng BuildContext sau async gap
  void _generateReport(BuildContext context, String filterType) async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (filterType == 'Ngày') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (filterType == 'Tuần') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (filterType == 'Tháng') {
      startDate = DateTime(now.year, now.month - 1, now.day);
    } else {
      startDate = DateTime(now.year - 1, now.month, now.day);
    }

    DateTime endDate = DateTime.now();

    // Lấy dữ liệu trước khi điều hướng, không dùng context trong async gap
    List<Map<String, dynamic>> readings = await UserController.getGlucoseReadings(
      startDate: startDate,
      endDate: endDate,
    );

    // Điều hướng sau khi hoàn tất thao tác bất đồng bộ
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPage(filterType: filterType, data: readings),
        ),
      );
    }
  }
}
