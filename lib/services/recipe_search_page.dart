import 'package:flutter/material.dart';
import '../services/recipe_api_service.dart';
import 'nutrition_info_page.dart';

class RecipeSearchPage extends StatefulWidget {
  const RecipeSearchPage({Key? key}) : super(key: key);

  @override
  RecipeSearchPageState createState() => RecipeSearchPageState();
}

class RecipeSearchPageState extends State<RecipeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final RecipeApiService _apiService = RecipeApiService();
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  // Biến để lưu trữ giá trị của các bộ lọc
  String selectedMealType = ''; // Món mặn, món chay, etc.
  String selectedDishType = ''; // Xào, nướng, canh, soup, etc.
  int selectedServingSize = 1; // Số người ăn

  // Các lựa chọn cho bộ lọc
  final List<String> mealTypes = ['Tất cả', 'Mặn', 'Chay', 'Ăn kiêng'];
  final List<String> dishTypes = ['Tất cả', 'Xào', 'Nướng', 'Canh', 'Soup'];

  void _searchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API với từ khóa và các bộ lọc
      final recipes = await _apiService.searchRecipes(
        query: _searchController.text,
        mealType: selectedMealType != 'Tất cả' ? selectedMealType : null,
        dishType: selectedDishType != 'Tất cả' ? selectedDishType : null,
        servings: selectedServingSize,
      );
      if (!mounted) return; // Kiểm tra context
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Kiểm tra context
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Hàm để mở BottomSheet hiển thị bộ lọc
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Sử dụng StatefulBuilder để cập nhật giá trị bên trong BottomSheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // DropdownButton cho loại món ăn (Mặn, Chay, Ăn kiêng)
                  DropdownButton<String>(
                    value: selectedMealType.isNotEmpty ? selectedMealType : null,
                    hint: const Text('Chọn loại món ăn'),
                    items: mealTypes.map((String mealType) {
                      return DropdownMenuItem<String>(
                        value: mealType,
                        child: Text(mealType),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedMealType = newValue ?? '';
                      });
                    },
                    isExpanded: true,
                    underline: Container(height: 1, color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 10),
                  // DropdownButton cho loại hình món (Xào, Nướng, Canh, Soup)
                  DropdownButton<String>(
                    value: selectedDishType.isNotEmpty ? selectedDishType : null,
                    hint: const Text('Chọn loại hình món'),
                    items: dishTypes.map((String dishType) {
                      return DropdownMenuItem<String>(
                        value: dishType,
                        child: Text(dishType),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedDishType = newValue ?? '';
                      });
                    },
                    isExpanded: true,
                    underline: Container(height: 1, color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 10),
                  // Slider để chọn số người dùng (số lượng phục vụ)
                  Row(
                    children: [
                      const Text('Số người ăn:'),
                      Expanded(
                        child: Slider(
                          value: selectedServingSize.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$selectedServingSize',
                          onChanged: (double value) {
                            setModalState(() {
                              selectedServingSize = value.toInt();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng BottomSheet sau khi chọn bộ lọc
                      setState(() {}); // Cập nhật bộ lọc trên trang chính
                      _searchRecipes(); // Tìm kiếm lại với bộ lọc
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thực đơn'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField để tìm kiếm món ăn
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Nhập tên món ăn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_alt),
                        onPressed: _showFilterSheet, // Mở bộ lọc khi nhấn vào icon
                      ),
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tìm kiếm'),
            ),
            const SizedBox(height: 16),

            // Hiển thị danh sách các món ăn tìm kiếm được
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionInfoPage(
                            recipeId: recipe['id'],
                            imageUrl: recipe['image'], // Truyền hình ảnh vào trang NutritionInfoPage
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              recipe['image'],
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
