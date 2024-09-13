// pages/report_page.dart
import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class ReportPage extends StatelessWidget {
  final String filterType;
  final List<Map<String, dynamic>> data;

  // Thêm 'key' vào constructor và sử dụng 'const'
  const ReportPage({
    Key? key, // Thêm key vào constructor
    required this.filterType,
    required this.data,
  }) : super(key: key); // Gọi super với key

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> stats;

    if (filterType == 'Ngày') {
      stats = UserController.calculateDailyStats(data);
    } else {
      int daysInPeriod = filterType == 'Tuần' ? 7 : (filterType == 'Tháng' ? 30 : 365);
      stats = UserController.calculatePeriodStats(data, daysInPeriod);
    }

    // Lấy giá trị đường huyết trung bình và chỉ lấy 3 số sau dấu phẩy
    String averageGlucose = stats['averageGlucose'].toStringAsFixed(3);

    return Scaffold(
      appBar: AppBar(title: Text('Báo cáo $filterType')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng số lần đo: ${stats['totalMeasurements']}'),
            if (filterType != 'Ngày')
              Text('Số lần đo trung bình mỗi ngày: ${stats['averageMeasurementsPerDay']}'),
            Text('Đường huyết trung bình: $averageGlucose mg/dL'), // Hiển thị 3 số sau dấu phẩy
          ],
        ),
      ),
    );
  }
}
