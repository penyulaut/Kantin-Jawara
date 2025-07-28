import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = Constants.baseUrl;

  Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {}

    return headers;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.loginEndpoint}'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.registerEndpoint}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String message = 'Registration failed';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = errors.values.first[0];
        } else if (data['message'] != null) {
          message = data['message'];
        }
        return {'success': false, 'message': message};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration not allowed',
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.logoutEndpoint}'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {'success': false, 'message': 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getProfile({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access'};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch profile. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: _getHeaders(token: token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Validation failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Update failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/change-password'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Validation failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Password change failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete-account'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Account deletion failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final headers = _getHeaders(token: token);

      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        if (endpoint.contains('merchant-payment-methods')) {
          return {'success': true, 'data': []};
        }
        return {'success': false, 'message': 'Resource not found'};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthenticated - please login again',
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(token: token),
        body: data != null ? jsonEncode(data) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        String message = 'Validation failed';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          message = errors.values.first[0];
        } else if (responseData['message'] != null) {
          message = responseData['message'];
        }
        return {'success': false, 'message': message};
      } else if (response.statusCode >= 500) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Server error occurred',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): ${response.body}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(token: token),
        body: data != null ? jsonEncode(data) : null,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        String message = 'Validation failed';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          message = errors.values.first[0];
        } else if (responseData['message'] != null) {
          message = responseData['message'];
        }
        return {'success': false, 'message': message};
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else if (response.statusCode == 204) {
        return {'success': true, 'message': 'Deleted successfully'};
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    return await get('/categories');
  }

  Future<Map<String, dynamic>> createCategory({
    required String token,
    required String name,
  }) async {
    return await post('/categories', data: {'name': name}, token: token);
  }

  Future<Map<String, dynamic>> updateCategory({
    required String token,
    required int id,
    required String name,
  }) async {
    return await put('/categories/$id', data: {'name': name}, token: token);
  }

  Future<Map<String, dynamic>> deleteCategory({
    required String token,
    required int id,
  }) async {
    return await delete('/categories/$id', token: token);
  }

  Future<Map<String, dynamic>> getMenus() async {
    return await get('/menus');
  }

  Future<Map<String, dynamic>> getMenu(int id) async {
    return await get('/menus/$id');
  }

  Future<Map<String, dynamic>> getMyMenus(String token) async {
    return await get('/penjual/menus', token: token);
  }

  Future<Map<String, dynamic>> createMenu({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/menus', data: data, token: token);
  }

  Future<Map<String, dynamic>> updateMenu({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    return await put('/menus/$id', data: data, token: token);
  }

  Future<Map<String, dynamic>> deleteMenu({
    required String token,
    required int id,
  }) async {
    return await delete('/menus/$id', token: token);
  }

  Future<Map<String, dynamic>> getPaymentMethods({String? token}) async {
    return await get('/payment-methods', token: token);
  }

  Future<Map<String, dynamic>> getPaymentMethod(int id, String token) async {
    return await get('/payment-methods/$id', token: token);
  }

  Future<Map<String, dynamic>> createPaymentMethod({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/payment-methods', data: data, token: token);
  }

  Future<Map<String, dynamic>> updatePaymentMethod({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    return await put('/payment-methods/$id', data: data, token: token);
  }

  Future<Map<String, dynamic>> deletePaymentMethod({
    required String token,
    required int id,
  }) async {
    return await delete('/payment-methods/$id', token: token);
  }

  Future<Map<String, dynamic>> getMerchantPaymentMethods({
    required String token,
    required int merchantId,
  }) async {
    return await get('/merchants/$merchantId/payment-methods', token: token);
  }

  Future<Map<String, dynamic>> getMerchantPaymentMethodsByUserId({
    required String token,
    required int userId,
  }) async {
    return await get('/users/$userId/payment-methods', token: token);
  }

  Future<Map<String, dynamic>> getMyMerchantPaymentMethods({
    required String token,
  }) async {
    return await get('/merchant-payment-methods', token: token);
  }

  Future<Map<String, dynamic>> getMerchantPaymentMethodsByPaymentId({
    required String token,
    required int paymentMethodId,
  }) async {
    return await get(
      '/merchant-payment-methods/$paymentMethodId',
      token: token,
    );
  }

  Future<Map<String, dynamic>> createMerchantPaymentMethod({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/merchant-payment-methods', data: data, token: token);
  }

  Future<Map<String, dynamic>> updateMerchantPaymentMethod({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    return await put('/merchant-payment-methods/$id', data: data, token: token);
  }

  Future<Map<String, dynamic>> deleteMerchantPaymentMethod({
    required String token,
    required int id,
  }) async {
    return await delete('/merchant-payment-methods/$id', token: token);
  }

  Future<Map<String, dynamic>> createTransaction({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/transactions', data: data, token: token);
  }

  Future<Map<String, dynamic>> getTransaction({
    required String token,
    required int id,
  }) async {
    return await get('/transactions/$id', token: token);
  }

  Future<Map<String, dynamic>> deleteTransaction({
    required String token,
    required int id,
  }) async {
    return await delete('/transactions/$id', token: token);
  }

  Future<Map<String, dynamic>> getPembeliTransactions(String token) async {
    return await get('/pembeli/transactions', token: token);
  }

  Future<Map<String, dynamic>> getPenjualTransactions(String token) async {
    return await get('/penjual/transactions', token: token);
  }

  Future<Map<String, dynamic>> getPenjualTransaction({
    required String token,
    required int id,
  }) async {
    return await get('/penjual/transactions/$id', token: token);
  }

  Future<Map<String, dynamic>> updateTransactionStatus({
    required String token,
    required int id,
    required String status,
  }) async {
    return await put(
      '/penjual/transactions/$id/status',
      data: {'status': status},
      token: token,
    );
  }

  Future<Map<String, dynamic>> createPayment({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/payments', data: data, token: token);
  }

  Future<Map<String, dynamic>> uploadPaymentProof({
    required String token,
    required int transactionId,
    required File proofFile,
  }) async {
    try {
      print(
        'ApiService uploadPaymentProof called with transactionId: $transactionId',
      ); // Debug log

      final uri = Uri.parse('$_baseUrl/payments/proof');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['transaction_id'] = transactionId.toString();

      final multipartFile = await http.MultipartFile.fromPath(
        'proof',
        proofFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        'ApiService uploadPaymentProof statusCode: ${response.statusCode}',
      ); // Debug log
      print(
        'ApiService uploadPaymentProof body: ${response.body}',
      ); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, ...data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to upload payment proof',
        };
      }
    } catch (e) {
      print('ApiService uploadPaymentProof error: $e'); // Debug log
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> markTransactionAsPaid({
    required String token,
    required int transactionId,
    String? paymentNote,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (paymentNote != null && paymentNote.isNotEmpty) {
        data['payment_note'] = paymentNote;
      }

      final response = await post(
        '/pembeli/transactions/$transactionId/mark-as-paid',
        data: data,
        token: token,
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadPaymentProofUrl({
    required String token,
    required int transactionId,
    required String proofUrl,
  }) async {
    try {
      print(
        'ApiService uploadPaymentProofUrl called with transactionId: $transactionId, proofUrl: $proofUrl',
      ); // Debug log

      final data = {'transaction_id': transactionId, 'proof_url': proofUrl};

      final response = await post('/payments/proof', data: data, token: token);

      print(
        'ApiService uploadPaymentProofUrl response: $response',
      ); // Debug log

      return response;
    } catch (e) {
      print('ApiService uploadPaymentProofUrl error: $e'); // Debug log
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getChatList(String token) async {
    return await get('/chats', token: token);
  }

  Future<Map<String, dynamic>> getUnreadCount(String token) async {
    return await get('/chats/unread-count', token: token);
  }

  Future<Map<String, dynamic>> getTransactionChats({
    required String token,
    required int transactionId,
  }) async {
    return await get('/transactions/$transactionId/chats', token: token);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int transactionId,
    required Map<String, dynamic> data,
  }) async {
    return await post(
      '/transactions/$transactionId/chats',
      data: data,
      token: token,
    );
  }

  Future<Map<String, dynamic>> deleteMessage({
    required String token,
    required int chatId,
  }) async {
    return await delete('/chats/$chatId', token: token);
  }

  Future<Map<String, dynamic>> getAdminUsers(String token) async {
    return await get('/admin/users', token: token);
  }

  Future<Map<String, dynamic>> getAdminTransactions(String token) async {
    return await get('/admin/transactions', token: token);
  }

  Future<Map<String, dynamic>> getAdminDashboard(String token) async {
    return await get('/admin/dashboard', token: token);
  }

  Future<Map<String, dynamic>> getAdminUserDetails({
    required String token,
    required int userId,
  }) async {
    return await get('/admin/users/$userId', token: token);
  }

  Future<Map<String, dynamic>> getAdminTransactionDetails({
    required String token,
    required int transactionId,
  }) async {
    return await get('/admin/transactions/$transactionId', token: token);
  }

  Future<Map<String, dynamic>> getCart(String token) async {
    return await get('/cart', token: token);
  }

  Future<Map<String, dynamic>> getCartByMerchant({
    required String token,
    required int merchantId,
  }) async {
    return await get('/cart/$merchantId', token: token);
  }

  Future<Map<String, dynamic>> addToCart({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await post('/cart/add', data: data, token: token);
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String token,
    required int itemId,
    required Map<String, dynamic> data,
  }) async {
    return await put('/cart/items/$itemId', data: data, token: token);
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String token,
    required int itemId,
  }) async {
    return await delete('/cart/items/$itemId', token: token);
  }

  Future<Map<String, dynamic>> clearCart(String token) async {
    return await delete('/cart', token: token);
  }

  Future<Map<String, dynamic>> clearCartByMerchant({
    required String token,
    required int merchantId,
  }) async {
    return await delete('/cart/$merchantId', token: token);
  }

  Future<Map<String, dynamic>> checkoutCart({
    required String token,
    required int merchantId,
    required Map<String, dynamic> data,
  }) async {
    return await post('/cart/$merchantId/checkout', data: data, token: token);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
    String? fileFieldName,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      final headers = _getHeaders(token: token);
      headers.forEach((key, value) {
        request.headers[key] = value;
      });

      request.fields.addAll(fields);

      if (filePath != null && fileFieldName != null) {
        final file = await http.MultipartFile.fromPath(fileFieldName, filePath);
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {'success': true, ...data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthenticated - please login again',
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> markPaymentAsPaid({
    required int transactionId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments/mark-paid'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'transaction_id': transactionId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, ...data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to mark payment as paid',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
