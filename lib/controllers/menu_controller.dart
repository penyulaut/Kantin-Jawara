import 'package:get/get.dart';
import 'dart:io';
import '../models/menu.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MenuController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Observable states
  final RxList<Menu> _menus = <Menu>[].obs;
  final RxList<Menu> _myMenus = <Menu>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _selectedCategoryId = 0.obs;

  // Getters
  List<Menu> get menus => _menus;
  List<Menu> get myMenus => _myMenus;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  int get selectedCategoryId => _selectedCategoryId.value;

  // Filtered menus based on search and category
  List<Menu> get filteredMenus {
    List<Menu> filtered = List.from(_menus);

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (menu) =>
                menu.name.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ||
                (menu.description?.toLowerCase().contains(
                      _searchQuery.value.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategoryId.value > 0) {
      filtered = filtered
          .where((menu) => menu.categoryId == _selectedCategoryId.value)
          .toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Set selected category
  void setSelectedCategory(int categoryId) {
    _selectedCategoryId.value = categoryId;
  }

  // Clear filters
  void clearFilters() {
    _searchQuery.value = '';
    _selectedCategoryId.value = 0;
  }

  // Fetch all menus (public endpoint)
  Future<void> fetchMenus() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get('/menus');

      if (response['success']) {
        // Handle nested response structure
        final responseData = response['data'];
        final List<dynamic> menuData;

        if (responseData is Map && responseData.containsKey('data')) {
          // Nested structure: {"success": true, "data": {"message": "...", "data": [...]}}
          menuData = responseData['data'] ?? [];
        } else if (responseData is List) {
          // Direct array: {"success": true, "data": [...]}
          menuData = responseData;
        } else {
          // Unknown structure
          menuData = [];
        }

        _menus.value = menuData.map((json) => Menu.fromJson(json)).toList();
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch menus';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch menu by ID (public endpoint)
  Future<Menu?> getMenuById(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get('/menus/$id');

      if (response['success']) {
        return Menu.fromJson(response['data']);
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch menu';
        return null;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch seller's own menus (protected endpoint)
  Future<void> fetchMyMenus() async {
    try {
      print('Starting fetchMyMenus...');
      _isLoading.value = true;
      _errorMessage.value = '';

      // Get current user and token
      final currentUser = await _authService.getUser();
      final token = await _authService.getToken();

      print(
        'Current user: ${currentUser?.id}, Token: ${token != null ? 'exists' : 'null'}',
      );

      if (currentUser == null || token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      try {
        // First try the specific penjual menus endpoint
        print('Trying penjual menus endpoint...');
        final response = await _apiService.getMyMenus(token);
        print('Response: $response');

        if (response['success'] == true ||
            response['message'] == 'Menus retrieved successfully') {
          // Handle nested response structure
          final responseData = response['data'];
          final List<dynamic> menusData;

          if (responseData is Map && responseData.containsKey('data')) {
            // Nested structure: {"success": true, "data": {"message": "...", "data": [...]}}
            menusData = responseData['data'] ?? [];
          } else if (responseData is List) {
            // Direct array: {"success": true, "data": [...]}
            menusData = responseData;
          } else {
            // Unknown structure
            menusData = [];
          }

          print('Found ${menusData.length} menus');
          _myMenus.value = menusData
              .map((json) => Menu.fromJson(json))
              .toList();
          print('Successfully loaded ${_myMenus.length} menus');
          return;
        }
      } catch (e) {
        // If the penjual endpoint fails, fall back to filtering all menus
        print('Fallback to general menus endpoint: $e');
      }

      // Fallback: Use general menus endpoint and filter by current user
      final response = await _apiService.get('/menus', token: token);

      if (response['success']) {
        // Handle nested response structure
        final responseData = response['data'];
        final List<dynamic> menusData;

        if (responseData is Map && responseData.containsKey('data')) {
          // Nested structure: {"success": true, "data": {"message": "...", "data": [...]}}
          menusData = responseData['data'] ?? [];
        } else if (responseData is List) {
          // Direct array: {"success": true, "data": [...]}
          menusData = responseData;
        } else {
          // Unknown structure
          menusData = [];
        }

        final allMenus = menusData.map((json) => Menu.fromJson(json)).toList();

        // Filter menus by current user (penjual)
        _myMenus.value = allMenus
            .where((menu) => menu.penjualId == currentUser.id)
            .toList();
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch menus';
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print('Error fetching my menus: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Create new menu (seller only)
  Future<bool> createMenu({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    String? imageUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final Map<String, dynamic> response;

      // Check if imageUrl is a file path (for uploaded images) or URL
      if (imageUrl != null && File(imageUrl).existsSync()) {
        // Upload as multipart form data
        final fields = {
          'name': name,
          'description': description,
          'price': price.toString(),
          'stock': stock.toString(),
          'category_id': categoryId.toString(),
        };

        response = await _apiService.postMultipart(
          '/menus',
          fields: fields,
          filePath: imageUrl,
          fileFieldName: 'image',
          token: token,
        );
      } else {
        // Regular JSON post (for URL or no image)
        final data = {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null) 'image_url': imageUrl,
        };

        response = await _apiService.post('/menus', data: data, token: token);
      }

      if (response['success']) {
        // Refresh menus after creating
        await fetchMyMenus();
        await fetchMenus();

        Get.snackbar(
          'Success',
          'Menu created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to create menu';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update existing menu (seller only)
  Future<bool> updateMenu({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    String? imageUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final Map<String, dynamic> response;

      // Check if imageUrl is a file path (for uploaded images) or URL
      if (imageUrl != null && File(imageUrl).existsSync()) {
        // Upload as multipart form data - Laravel expects POST with _method field for PUT
        final fields = {
          '_method': 'PUT',
          'name': name,
          'description': description,
          'price': price.toString(),
          'stock': stock.toString(),
          'category_id': categoryId.toString(),
        };

        response = await _apiService.postMultipart(
          '/menus/$id',
          fields: fields,
          filePath: imageUrl,
          fileFieldName: 'image',
          token: token,
        );
      } else {
        // Regular JSON put (for URL or no image)
        final data = {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null) 'image_url': imageUrl,
        };

        response = await _apiService.put(
          '/menus/$id',
          data: data,
          token: token,
        );
      }

      if (response['success']) {
        // Refresh menus after updating
        await fetchMyMenus();
        await fetchMenus();

        Get.snackbar(
          'Success',
          'Menu updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to update menu';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete menu (seller only)
  Future<bool> deleteMenu(int id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete('/menus/$id', token: token);

      if (response['success']) {
        // Refresh menus after deleting
        await fetchMyMenus();
        await fetchMenus();

        Get.snackbar(
          'Success',
          'Menu deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to delete menu';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Search menus
  Future<void> searchMenus(String query) async {
    setSearchQuery(query);
    // Since we're using local filtering, no need to make API call
    // But you can implement server-side search if needed
  }

  // Filter menus by category
  Future<void> filterByCategory(int categoryId) async {
    setSelectedCategory(categoryId);
    // Since we're using local filtering, no need to make API call
    // But you can implement server-side filtering if needed
  }
}
