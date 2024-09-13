import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_auth/pages/home_page.dart'; // Import trang home_page

class InforUserPage extends StatefulWidget {
  const InforUserPage({Key? key}) : super(key: key);

  @override
  _InforUserPageState createState() => _InforUserPageState();
}

class _InforUserPageState extends State<InforUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _diabetesType;
  String? _gender;
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Hiển thị loading
      });

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
            'name': _nameController.text,
            'age': int.tryParse(_ageController.text) ?? 0, // Đảm bảo giá trị số nguyên
            'phone': _phoneController.text,
            'email': _emailController.text,
            'diabetes_type': _diabetesType,
            'gender': _gender, // Thêm giới tính vào Firestore
          });

          // Lưu context trước khi gọi async để tránh lỗi sử dụng BuildContext sau async gap
          final currentContext = context;

          // Chuyển hướng đến HomePage sau khi lưu thông tin thành công
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(currentContext).pushReplacement(
              MaterialPageRoute(builder: (currentContext) => const HomePage()),
            );
          });

          // Hiển thị thông báo khi lưu thành công
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text('Thông tin đã được lưu thành công!')),
          );
        }
      } catch (e) {
        // Sử dụng context an toàn để hiển thị lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Tắt loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điền thông tin cá nhân'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildFormFieldContainer(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        border: InputBorder.none,
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Họ và tên không được để trống'
                          : null,
                    ),
                  ),
                  _buildFormFieldContainer(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Tuổi',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final age = int.tryParse(value ?? '');
                        return (age == null || age <= 0)
                            ? 'Tuổi không hợp lệ'
                            : null;
                      },
                    ),
                  ),
                  _buildFormFieldContainer(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        border: InputBorder.none,
                      ),
                      items: ['Nam', 'Nữ', 'Khác']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      validator: (value) =>
                      value == null ? 'Vui lòng chọn giới tính' : null,
                    ),
                  ),
                  _buildFormFieldContainer(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        counterText: '', // Ẩn đếm số ký tự
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10, // Giới hạn tối đa 10 chữ số
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Số điện thoại không được để trống';
                        }
                        if (value.length != 10) {
                          return 'Số điện thoại phải có đúng 10 chữ số';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Số điện thoại chỉ được chứa số';
                        }
                        return null;
                      },
                    ),
                  ),
                  _buildFormFieldContainer(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final emailRegex =
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                        return !emailRegex.hasMatch(value ?? '')
                            ? 'Email không hợp lệ'
                            : null;
                      },
                    ),
                  ),
                  _buildFormFieldContainer(
                    child: DropdownButtonFormField<String>(
                      value: _diabetesType,
                      decoration: const InputDecoration(
                        labelText: 'Loại bệnh tiểu đường',
                        border: InputBorder.none,
                      ),
                      items: ['Type 1', 'Type 2', 'Đái tháo đường thai kỳ']
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _diabetesType = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Vui lòng chọn loại bệnh tiểu đường'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Lưu thông tin'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildFormFieldContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.pink.shade50, // Màu pastel
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: child,
    );
  }
}
