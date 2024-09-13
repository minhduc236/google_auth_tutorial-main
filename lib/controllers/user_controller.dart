import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart'; // Sử dụng logger thay cho print

class UserController {
  static User? user = FirebaseAuth.instance.currentUser;
  static final Logger logger = Logger();

  // Đăng nhập với Google
  static Future<User?> loginWithGoogle() async {
    try {
      // Bắt đầu quá trình đăng nhập với Google
      final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();

      if (googleAccount == null) {
        return null; // Người dùng hủy đăng nhập
      }

      // Lấy thông tin xác thực từ tài khoản Google
      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

      // Tạo thông tin xác thực (credential) cho Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase với thông tin xác thực
      dynamic userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Kiểm tra kiểu dữ liệu của userCredential và tránh lỗi ép kiểu
      if (userCredential is UserCredential && userCredential.user != null) {
        user = userCredential.user;

        // Nếu người dùng đăng nhập thành công, lưu hoặc cập nhật thông tin trong Firestore
        await updateUserData(); // Gọi hàm cập nhật thông tin người dùng
        return user;
      } else {
        logger.w('Error: Không tìm thấy thông tin người dùng từ Google.');
        return null;
      }
    } catch (e) {
      logger.e('Google login failed: $e'); // Ghi log lỗi chi tiết
      return null;
    }
  }

  // Đăng xuất người dùng
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      user = null; // Đặt user về null khi đăng xuất
    } catch (e) {
      logger.e('Sign out failed: $e'); // Sử dụng logger thay cho print
    }
  }

  // Kiểm tra nếu thông tin cá nhân đã hoàn thành
  static Future<bool> hasCompletedPersonalInfo() async {
    if (user == null) return false;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data is Map<String, dynamic>) {
          return data['name'] != null &&
              data['age'] != null &&
              data['phone'] != null &&
              data['email'] != null &&
              data['diabetes_type'] != null;
        } else {
          logger.w('Error: Dữ liệu trả về không đúng định dạng.');
          return false;
        }
      } else {
        logger.w('Error: Tài liệu người dùng không tồn tại.');
      }
    } catch (e) {
      logger.e('Error checking personal info: $e');
    }
    return false;
  }

  // Lấy thông tin người dùng từ Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    if (user == null) return null;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          logger.w('Error: Dữ liệu trả về không phải là Map<String, dynamic>.');
          return null;
        }
      } else {
        logger.w('Error: Tài liệu người dùng không tồn tại.');
      }
    } catch (e) {
      logger.e('Error getting user data: $e');
    }
    return null;
  }

  // Cập nhật hoặc tạo mới thông tin người dùng trong Firestore
  static Future<void> updateUserData() async {
    if (user == null) return;

    try {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Người dùng chưa tồn tại, thêm mới dữ liệu
        await userDocRef.set({
          'name': user!.displayName,
          'email': user!.email,
          'photoURL': user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Cập nhật dữ liệu nếu người dùng đã tồn tại
        await userDocRef.update({
          'name': user!.displayName,
          'email': user!.email,
          'photoURL': user!.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      logger.e('Error updating user data: $e');
    }
  }

  // Lưu dữ liệu glucose vào Firestore
  static Future<void> saveGlucoseData(int glucoseLevel, String timeOfDay) async {
    if (user == null) {
      logger.w('No user is logged in.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('glucose_readings')
          .doc(user!.uid)
          .collection('readings')
          .add({
        'glucose_level': glucoseLevel,
        'time_of_day': timeOfDay,
        'timestamp': Timestamp.now(),
      });
      logger.i('Glucose data saved successfully.');
    } catch (e) {
      logger.e('Error saving glucose data: $e');
    }
  }

  // Lấy dữ liệu glucose từ Firestore với khoảng thời gian
  static Future<List<Map<String, dynamic>>> getGlucoseReadings({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (user == null) return [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('glucose_readings')
          .doc(user!.uid)
          .collection('readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'glucose_level': doc['glucose_level'],
          'timestamp': doc['timestamp'].toDate(),
        };
      }).toList();
    } catch (e) {
      logger.e('Error fetching glucose readings: $e');
      return [];
    }
  }

  // Đăng nhập bằng email và mật khẩu
  static Future<User?> loginWithEmail(String email, String password) async {
    try {
      // Đăng nhập với email và mật khẩu
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        user = userCredential.user;
        await updateUserData(); // Gọi hàm cập nhật thông tin người dùng
        return user;
      } else {
        logger.w('Error: Không tìm thấy thông tin người dùng từ email và mật khẩu.');
        return null;
      }
    } catch (e) {
      logger.e('Email login failed: $e'); // Ghi log lỗi chi tiết
      return null;
    }
  }

  // Hàm tính toán thống kê theo Ngày
  static Map<String, dynamic> calculateDailyStats(List<Map<String, dynamic>> data) {
    int totalMeasurements = data.length;
    double averageGlucose = data.isEmpty
        ? 0
        : data.fold(0, (total, e) => total + (e['glucose_level'] as int)) / totalMeasurements;

    return {
      'totalMeasurements': totalMeasurements,
      'averageGlucose': averageGlucose,
    };
  }

  // Hàm tính toán thống kê theo Tuần, Tháng, Năm
  static Map<String, dynamic> calculatePeriodStats(List<Map<String, dynamic>> data, int daysInPeriod) {
    int totalMeasurements = data.length;
    double averageMeasurementsPerDay = totalMeasurements / daysInPeriod;
    double averageGlucose = data.isEmpty
        ? 0
        : data.fold(0, (total, e) => total + (e['glucose_level'] as int)) / totalMeasurements;

    return {
      'totalMeasurements': totalMeasurements,
      'averageMeasurementsPerDay': averageMeasurementsPerDay,
      'averageGlucose': averageGlucose,
    };
  }
}
