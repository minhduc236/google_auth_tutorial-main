import 'package:flutter/material.dart';
import '../services/recipe_api_service.dart';

class NutritionInfoPage extends StatefulWidget {
  final int recipeId;
  final String imageUrl; // Nhận hình ảnh từ trang tìm kiếm

  const NutritionInfoPage({Key? key, required this.recipeId, required this.imageUrl}) : super(key: key);

  @override
  NutritionInfoPageState createState() => NutritionInfoPageState(); // Bỏ dấu gạch dưới
}

class NutritionInfoPageState extends State<NutritionInfoPage> {
  final RecipeApiService _apiService = RecipeApiService();
  Map<String, dynamic>? _nutritionInfo;
  Map<String, dynamic>? _recipeInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final nutritionInfo = await _apiService.getNutritionalInfo(widget.recipeId);
      final recipeInfo = await _apiService.getRecipeInstructions(widget.recipeId); // Lấy công thức và định lượng
      if (!mounted) return;
      setState(() {
        _nutritionInfo = nutritionInfo;
        _recipeInfo = recipeInfo;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin dinh dưỡng & Công thức nấu ăn'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nutritionInfo != null && _recipeInfo != null
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị hình ảnh món ăn
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị thông tin dinh dưỡng với thẻ (Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin dinh dưỡng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildNutritionRow('Calories', _nutritionInfo!['calories']),
                      _buildNutritionRow('Carbs', _nutritionInfo!['carbs']),
                      _buildNutritionRow('Fat', _nutritionInfo!['fat']),
                      _buildNutritionRow('Protein', _nutritionInfo!['protein']),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị định lượng người dùng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số người sử dụng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_recipeInfo!['servings']} người',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị công thức nấu ăn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Công thức nấu ăn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _recipeInfo!['instructions'] ?? 'Không có công thức nấu ăn',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )
          : const Center(child: Text('Không có dữ liệu')),
    );
  }

  // Hàm phụ để xây dựng dòng thông tin dinh dưỡng
  Widget _buildNutritionRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
