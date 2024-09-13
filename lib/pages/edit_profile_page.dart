import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/user_controller.dart';
import '../pages/home_page.dart'; // Import HomePage

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _ageController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  String? _diabetesType;
  String? _gender; // Thêm biến _gender để lưu giá trị giới tính

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserController.getUserData();

    if (userData != null) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _ageController.text = userData['age']?.toString() ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _diabetesType = userData['diabetes_type'];
        _gender = userData['gender']; // Lấy thông tin giới tính
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserController.user!.uid)
          .update({
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text,
        'email': _emailController.text,
        'diabetes_type': _diabetesType,
        'gender': _gender, // Lưu thông tin giới tính
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin cá nhân'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildProfileField(
                label: 'Họ Tên',
                controller: _nameController,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Điền Họ và Tên';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'Tuổi',
                controller: _ageController,
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Điền thông tin tuổi tác';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Điền thông tin tuổi tác';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'Số điện thoại',
                controller: _phoneController,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Điền thông tin số điện thoại';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'Gmail',
                controller: _emailController,
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Điền thông tin email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Hãy điền đúng thông tin email';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                label: 'Diabetes Type',
                value: _diabetesType,
                items: ['Type 1', 'Type 2', 'Đái tháo đường thai kỳ'],
                icon: Icons.local_hospital,
                onChanged: (value) {
                  setState(() {
                    _diabetesType = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Lựa chọn mức độ tiểu đường' : null,
              ),
              _buildDropdownField(
                label: 'Giới tính', // Thêm trường giới tính
                value: _gender,
                items: ['Nam', 'Nữ', 'Khác'],
                icon: Icons.wc,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Lựa chọn giới tính' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Thay thế 'primary' bằng 'backgroundColor'
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Thay đổi',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: InputBorder.none,
          ),
          items: items
              .map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
