import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kantin_jawara/utils/app_theme.dart';
import 'dart:io';
import '../models/menu.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MenuController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Menu> _menus = <Menu>[].obs;
  final RxList<Menu> _myMenus = <Menu>[].obs;
  final RxList<Merchant> _merchants = <Merchant>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxInt _selectedCategoryId = 0.obs;
  final RxInt _selectedMerchantId = 0.obs;

  List<Menu> get menus => _menus;
  List<Menu> get myMenus => _myMenus;
  List<Merchant> get merchants => _merchants;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  int get selectedCategoryId => _selectedCategoryId.value;
  int get selectedMerchantId => _selectedMerchantId.value;

  List<Menu> get filteredMenus {
    List<Menu> filtered = List.from(_menus);

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

    if (_selectedCategoryId.value > 0) {
      filtered = filtered
          .where((menu) => menu.categoryId == _selectedCategoryId.value)
          .toList();
    }

    if (_selectedMerchantId.value > 0) {
      filtered = filtered
          .where((menu) => menu.penjualId == _selectedMerchantId.value)
          .toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
    fetchMerchants(); 
    _testImageConnectivity();
  }

  void _testImageConnectivity() async {
    try {
    } catch (e) {
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void setSelectedCategory(int categoryId) {
    _selectedCategoryId.value = categoryId;
    _selectedMerchantId.value =
        0; 
  }

  void setSelectedMerchant(int merchantId) {
    _selectedMerchantId.value = merchantId;
    _selectedCategoryId.value =
        0; 

    if (merchantId > 0) {
      fetchMenusByMerchant(merchantId);
    } else {
      fetchMenus(); 
    }
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedCategoryId.value = 0;
    _selectedMerchantId.value = 0;
  }

  Future<void> fetchMenus() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get('/menus');

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> menuData;

        if (responseData is List) {
          menuData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          menuData = responseData['data'] ?? [];
        } else {
          menuData = [];
        }

        _menus.value = menuData.map((json) => Menu.fromJson(json)).toList();
        await fetchMerchants();
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch menus';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

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

  Future<void> fetchMyMenus() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final currentUser = await _authService.getUser();
      final token = await _authService.getToken();


      if (currentUser == null || token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      try {
        final response = await _apiService.getMyMenus(token);

        if (response['success'] == true ||
            response['message'] == 'Menus retrieved successfully') {
          final responseData = response['data'];
          final List<dynamic> menusData;

          if (responseData is List) {
            menusData = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            menusData = responseData['data'] ?? [];
          } else {
            menusData = [];
          }

          _myMenus.value = menusData
              .map((json) => Menu.fromJson(json))
              .toList();
          return;
        }
      } catch (e) {
      }

      final response = await _apiService.get('/menus', token: token);

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> menusData;

        if (responseData is List) {
          menusData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          menusData = responseData['data'] ?? [];
        } else {
          menusData = [];
        }

        final allMenus = menusData.map((json) => Menu.fromJson(json)).toList();

        _myMenus.value = allMenus
            .where((menu) => menu.penjualId == currentUser.id)
            .toList();
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to fetch menus';
      }
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

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

      bool isLocalFile =
          imageUrl != null &&
          !imageUrl.startsWith('http://') &&
          !imageUrl.startsWith('https://') &&
          File(imageUrl).existsSync();


      if (isLocalFile) {
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
        final data = {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        };

        response = await _apiService.post('/menus', data: data, token: token);
      }


      if (response['success']) {
        await fetchMyMenus();
        await fetchMenus();

        Get.snackbar(
          'Success',
          'Menu created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.goldenPoppy,
          colorText: AppTheme.royalBlueDark,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: AppTheme.royalBlueDark),
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to create menu';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

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

      bool isLocalFile =
          imageUrl != null &&
          !imageUrl.startsWith('http://') &&
          !imageUrl.startsWith('https://') &&
          File(imageUrl).existsSync();


      if (isLocalFile) {
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
        final data = {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        };

        response = await _apiService.put(
          '/menus/$id',
          data: data,
          token: token,
        );
      }


      if (response['success']) {
        await fetchMyMenus();
        await fetchMenus();

        Get.snackbar(
          'Success',
          'Menu updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.goldenPoppy,
          colorText: AppTheme.royalBlueDark,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to update menu';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

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

  Future<void> searchMenus(String query) async {
    setSearchQuery(query);
  }

  Future<void> filterByCategory(int categoryId) async {
    setSelectedCategory(categoryId);
  }

  Future<void> fetchMerchants() async {
    try {

      final response = await _apiService.get('/merchants');

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> merchantData;

        if (responseData is List) {
          merchantData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          merchantData = responseData['data'] as List<dynamic>;
        } else {
          merchantData = [responseData];
        }

        _merchants.value = merchantData
            .map((data) => Merchant.fromJson(data as Map<String, dynamic>))
            .toList();

        for (var merchant in _merchants) {
        }
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to load merchants';

        _extractMerchantsFromMenus();
      }
    } catch (e) {
      _errorMessage.value = 'Error loading merchants: $e';

      _extractMerchantsFromMenus();
    }
  }

  void _extractMerchantsFromMenus() {
    if (_menus.isNotEmpty) {
      final Map<int, Merchant> merchantMap = {};

      for (final menu in _menus) {
        if (menu.penjualId != null) {
          merchantMap[menu.penjualId!] = Merchant(
            id: menu.penjualId!,
            name: 'Kantin ${menu.penjualId}', 
            description: 'Delicious food from our kitchen',
            imageUrl: null,
          );
        }
      }

      _merchants.value = merchantMap.values.toList();
    }
  }

  Future<void> fetchMenusByMerchant(int merchantId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiService.get('/merchants/$merchantId/menus');

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> menuData;

        if (responseData is List) {
          menuData = responseData;
        } else if (responseData is Map && responseData.containsKey('menus')) {
          menuData = responseData['menus'] as List<dynamic>;
        } else if (responseData is Map && responseData.containsKey('data')) {
          menuData = responseData['data'] as List<dynamic>;
        } else {
          menuData = [];
        }

        _menus.value = menuData
            .map((data) => Menu.fromJson(data as Map<String, dynamic>))
            .toList();

      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to load merchant menus';
      }
    } catch (e) {
      _errorMessage.value = 'Error loading merchant menus: $e';
    } finally {
      _isLoading.value = false;
    }
  }
}
