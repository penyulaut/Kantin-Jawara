import 'package:get/get.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CategoryController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    Map<String, dynamic>? response;
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      response = await _apiService.get('/categories', token: token);

      if (response['success'] == true) {
        final dynamic data = response['data'];

        if (data is List) {
          _categories.value = data
              .map((json) => Category.fromJson(json))
              .toList();
        } else if (data is Map && data.containsKey('categories')) {
          final List<dynamic> categoryData = data['categories'];
          _categories.value = categoryData
              .map((json) => Category.fromJson(json))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          final List<dynamic> categoryData = data['data'];
          _categories.value = categoryData
              .map((json) => Category.fromJson(json))
              .toList();
        } else {
          _categories.value = [];
        }
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch categories';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      print('Debug - fetchCategories error: $e');
      if (response != null) {
        print('Debug - categories response: $response');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createCategory(String name) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'Authentication required';
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      final response = await _apiService.post(
        '/categories',
        data: {'name': name},
        token: token,
      );
      if (response['success']) {
        await fetchCategories(); 
        Get.snackbar('Success', 'Category created successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to create category';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'Authentication required';
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      final response = await _apiService.put(
        '/categories/$id',
        data: {'name': name},
        token: token,
      );
      if (response['success']) {
        await fetchCategories(); 
        Get.snackbar('Success', 'Category updated successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to update category';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'Authentication required';
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      final response = await _apiService.delete(
        '/categories/$id',
        token: token,
      );
      if (response['success']) {
        await fetchCategories(); 
        Get.snackbar('Success', 'Category deleted successfully');
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to delete category';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
