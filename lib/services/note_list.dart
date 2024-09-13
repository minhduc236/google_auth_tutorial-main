import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Import thư viện intl
import '../controllers/user_controller.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  String? _selectedFilter = 'Ngày'; // Bộ lọc mặc định
  DateTime _selectedDate = DateTime.now(); // Ngày được chọn (mặc định là hôm nay)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đo lường'),
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            items: <String>['Ngày', 'Tuần', 'Tháng', 'Năm'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedFilter = newValue;
                if (_selectedFilter != 'Ngày') {
                  _showDatePicker();  // Chọn thời gian khi thay đổi bộ lọc
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('glucose_readings')
            .doc(UserController.user!.uid)
            .collection('readings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final data = snapshot.data!.docs;

          // Lọc dữ liệu dựa trên bộ lọc
          final filteredData = _filterData(data);

          return ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final doc = filteredData[index];
              final glucoseLevel = doc['glucose_level'];
              final time = doc['time_of_day'];
              final timestamp = doc['timestamp'].toDate();

              // Định dạng ngày tháng năm và giờ phút
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Bo góc của thẻ
                ),
                elevation: 4, // Đổ bóng cho thẻ
                shadowColor: Colors.grey.withOpacity(0.5), // Màu của bóng đổ
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Khoảng cách giữa các thẻ
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50, // Màu nền nhẹ nhàng cho thẻ
                    borderRadius: BorderRadius.circular(12.0), // Bo góc cho viền của container
                    border: Border.all(color: Colors.blue.shade200, width: 2), // Viền cho container
                  ),
                  child: ListTile(
                    title: Text(
                      'Chỉ số: $glucoseLevel mg/dL',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Thời gian: $time\nNgày: $formattedDate',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editReading(doc.id, glucoseLevel, time);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hàm lọc dữ liệu
  List<DocumentSnapshot> _filterData(List<DocumentSnapshot> data) {
    final now = DateTime.now();

    if (_selectedFilter == 'Ngày') {
      return data.where((doc) {
        final timestamp = doc['timestamp'].toDate();
        return timestamp.year == now.year &&
            timestamp.month == now.month &&
            timestamp.day == now.day;
      }).toList();
    } else if (_selectedFilter == 'Tuần') {
      final firstDayOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
      return data.where((doc) {
        final timestamp = doc['timestamp'].toDate();
        return timestamp.isAfter(firstDayOfWeek) && timestamp.isBefore(lastDayOfWeek);
      }).toList();
    } else if (_selectedFilter == 'Tháng') {
      return data.where((doc) {
        final timestamp = doc['timestamp'].toDate();
        return timestamp.year == _selectedDate.year &&
            timestamp.month == _selectedDate.month;
      }).toList();
    } else if (_selectedFilter == 'Năm') {
      return data.where((doc) {
        final timestamp = doc['timestamp'].toDate();
        return timestamp.year == _selectedDate.year;
      }).toList();
    }

    return data; // Trả về toàn bộ dữ liệu nếu không lọc
  }

  // Hiển thị DatePicker để người dùng chọn thời gian
  void _showDatePicker() async {
    if (_selectedFilter == 'Ngày' || _selectedFilter == 'Tuần' || _selectedFilter == 'Tháng') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } else if (_selectedFilter == 'Năm') {
      final pickedYear = await _showYearPicker();
      if (pickedYear != null && pickedYear != _selectedDate.year) {
        setState(() {
          _selectedDate = DateTime(pickedYear);
        });
      }
    }
  }

  // Hàm hiển thị Year Picker
  Future<int?> _showYearPicker() async {
    int? selectedYear;
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn năm'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              selectedDate: DateTime.now(), // Không sử dụng `initialDate` nữa
              onChanged: (DateTime dateTime) {
                selectedYear = dateTime.year;
                Navigator.pop(context, selectedYear);
              },
            ),
          ),
        );
      },
    );
  }

  void _editReading(String id, int glucoseLevel, String time) {
    // Hàm này sẽ mở một trang hoặc dialog để chỉnh sửa thông tin đo lường
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController glucoseController = TextEditingController(text: glucoseLevel.toString());
        final TextEditingController timeController = TextEditingController(text: time);

        return AlertDialog(
          title: const Text('Chỉnh sửa thông tin đo lường'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: glucoseController,
                decoration: const InputDecoration(labelText: 'Chỉ số đường (mg/dL)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Thời điểm đo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('glucose_readings')
                    .doc(UserController.user!.uid)
                    .collection('readings')
                    .doc(id)
                    .update({
                  'glucose_level': int.parse(glucoseController.text),
                  'time_of_day': timeController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}
