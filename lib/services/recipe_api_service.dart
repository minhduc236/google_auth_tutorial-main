import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeApiService {
  static const String apiKey = '30b24248752944ad99b223126da312d8'; // Đặt API key của bạn ở đây
  static const String baseUrl = 'https://api.spoonacular.com';

  // Hàm tìm kiếm thực đơn theo từ khóa và các bộ lọc
  Future<List<dynamic>> searchRecipes({
    required String query,
    String? mealType, // Loại món ăn (Mặn, Chay,...)
    String? dishType, // Loại hình món (Xào, Nướng, Canh, Soup,...)
    int? servings, // Số lượng người ăn
  }) async {
    // Xây dựng URL với các tham số bộ lọc nếu có
    String filterQuery = '$baseUrl/recipes/complexSearch?query=$query&apiKey=$apiKey';

    if (mealType != null && mealType.isNotEmpty) {
      filterQuery += '&mealType=$mealType';
    }
    if (dishType != null && dishType.isNotEmpty) {
      filterQuery += '&type=$dishType';
    }
    if (servings != null && servings > 0) {
      filterQuery += '&number=$servings';
    }

    final url = Uri.parse(filterQuery);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results']; // Trả về danh sách kết quả thực đơn
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Hàm lấy thông tin dinh dưỡng của thực phẩm theo ID
  Future<Map<String, dynamic>> getNutritionalInfo(int id) async {
    final url = Uri.parse('$baseUrl/recipes/$id/nutritionWidget.json?apiKey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // Trả về dữ liệu dinh dưỡng
    } else {
      throw Exception('Failed to load nutrition info');
    }
  }

  // Hàm lấy công thức nấu ăn và định lượng người dùng theo ID
  Future<Map<String, dynamic>> getRecipeInstructions(int id) async {
    final url = Uri.parse('$baseUrl/recipes/$id/information?apiKey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'servings': data['servings'], // Số lượng người dùng (định lượng)
        'instructions': data['instructions'], // Công thức nấu ăn dạng text
      };
    } else {
      throw Exception('Failed to load recipe instructions');
    }
  }
}
