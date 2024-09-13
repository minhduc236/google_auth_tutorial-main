import 'package:flutter/material.dart';
import 'package:google_auth/controllers/user_controller.dart';
import 'note_list.dart';  // Import file note_list.dart
import 'report_filter_page.dart';  // Import trang ReportFilterPage

class GlucoseEntryPage extends StatefulWidget {
  const GlucoseEntryPage({Key? key}) : super(key: key);

  @override
  _GlucoseEntryPageState createState() => _GlucoseEntryPageState();
}

class _GlucoseEntryPageState extends State<GlucoseEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _glucoseController = TextEditingController();
  String? _selectedTime;

  Future<void> _submitGlucoseData() async {
    if (_formKey.currentState!.validate()) {
      final glucoseLevel = int.parse(_glucoseController.text);

      await UserController.saveGlucoseData(glucoseLevel, _selectedTime!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dữ liệu đã được lưu thành công!')),
      );

      _glucoseController.clear();
      setState(() {
        _selectedTime = null;
      });
    }
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            children: [
              _buildTimePickerItem('Trước khi ăn sáng'),
              _buildTimePickerItem('Sau khi ăn sáng'),
              _buildTimePickerItem('Trước khi ăn trưa'),
              _buildTimePickerItem('Sau khi ăn trưa'),
              _buildTimePickerItem('Trước khi ăn tối'),
              _buildTimePickerItem('Sau khi ăn tối'),
              _buildTimePickerItem('Trước khi ngủ'),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildTimePickerItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          _selectedTime = title;
        });
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      tileColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteList()),
    );
  }

  void _viewStatistics() {
    // Chuyển hướng tới trang ReportFilterPage khi người dùng nhấn nút
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportFilterPage()), // Điều hướng đến trang ReportFilterPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập Chỉ Số Đường'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _glucoseController,
                    decoration: const InputDecoration(
                      labelText: 'Chỉ số đường (mg/dL)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập chỉ số đường';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Vui lòng nhập số hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(_selectedTime ?? 'Chọn thời điểm đo'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => _showTimePicker(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    tileColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitGlucoseData,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 6.0,
                  ),
                  child: const Text('Lưu chỉ số đường'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _viewHistory,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 6.0,
                      ),
                      child: const Text('Xem lịch sử đo'),
                    ),
                    ElevatedButton(
                      onPressed: _viewStatistics,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 6.0,
                      ),
                      child: const Text('Xem thống kê chi tiết'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
