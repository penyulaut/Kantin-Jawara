import 'dart:io';

import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';

class PembeliController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxList<Transaction> _transactions = <Transaction>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();

      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.getPembeliTransactions(token);

      if (response['success']) {
        final responseData = response['data'];
        final List<dynamic> transactionData;

        if (responseData is Map && responseData.containsKey('data')) {
          transactionData = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          transactionData = responseData;
        } else {
          transactionData = [];
        }

        _transactions.value = transactionData
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch transactions';

        if (response['message']?.contains('Unauthenticated') == true ||
            response['message']?.contains('401') == true) {
          await _authService.clearUserData();
          Get.offAllNamed('/login');
        }
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createTransaction({
    required double totalPrice,
    required List<Map<String, dynamic>> items,
    String? notes,
    String? customerName,
    String? customerPhone,
    String? orderType,
    String? paymentMethod,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {
        'total_price': totalPrice,
        'items': items,
        'notes': notes,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'order_type': orderType ?? 'takeaway',
        'payment_method': paymentMethod ?? 'Bank Transfer',
      };

      final response = await _apiService.post(
        '/transactions',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions();
        Get.snackbar(
          'Success',
          'Order created successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to create order';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> uploadPaymentProof({
    required int transactionId,
    required File proofFile,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return {'success': false, 'message': 'User not authenticated'};
      }

      final response = await _apiService.uploadPaymentProof(
        transactionId: transactionId,
        proofFile: proofFile,
        token: token,
      );

      if (response['success'] == true) {
        final message =
            response['message'] ?? 'Bukti pembayaran berhasil diupload';
        final proofUrl = response['proof_url'];

        Get.snackbar('Success', message);
        return {'success': true, 'message': message, 'proof_url': proofUrl};
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to upload payment proof';
        Get.snackbar('Error', _errorMessage.value);
        return {'success': false, 'message': _errorMessage.value};
      }
    } catch (e) {
      print('Exception in uploadPaymentProof: $e');
      _errorMessage.value = 'Error uploading payment proof: $e';
      Get.snackbar('Error', _errorMessage.value);
      return {'success': false, 'message': _errorMessage.value};
    } finally {
      print('Setting loading to false');
      _isLoading.value = false;
    }
  }

  Future<bool> makePayment({
    required int transactionId,
    required double amount,
    required String method,
    String? proofPath,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {
        'transaction_id': transactionId,
        'amount': amount,
        'method': method,
        'proof': proofPath,
      };

      final response = await _apiService.post(
        '/payments',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions();
        Get.snackbar(
          'Success',
          'Payment submitted successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to submit payment';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> cancelTransaction(int transactionId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = {'status': 'cancelled'};
      final response = await _apiService.put(
        '/transactions/$transactionId',
        data: data,
        token: token,
      );
      if (response['success']) {
        await fetchTransactions();
        Get.snackbar(
          'Success',
          'Transaction cancelled successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to cancel transaction';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  List<Transaction> getTransactionsByStatus(TransactionStatus status) {
    return _transactions
        .where((transaction) => transaction.status == status)
        .toList();
  }

  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> markTransactionAsPaid({
    required int transactionId,
    String? paymentNote,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return {'success': false, 'message': 'User not authenticated'};
      }

      final response = await _apiService.markTransactionAsPaid(
        token: token,
        transactionId: transactionId,
        paymentNote: paymentNote,
      );

      if (response['success'] == true) {
        final apiResponse = response['data'];
        final message =
            apiResponse['message'] ??
            'Transaksi berhasil ditandai sebagai sudah dibayar';

        await fetchTransactions();

        Get.snackbar(
          'Success',
          message,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        return {'success': true, 'message': message, 'data': apiResponse};
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to mark transaction as paid';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return {'success': false, 'message': _errorMessage.value};
      }
    } catch (e) {
      _errorMessage.value = 'Error marking transaction as paid: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return {'success': false, 'message': _errorMessage.value};
    } finally {
      _isLoading.value = false;
    }
  }
}
