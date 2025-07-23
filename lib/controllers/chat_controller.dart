import 'package:get/get.dart';
import '../models/chat.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxMap<int, List<Chat>> _chatsByTransaction = <int, List<Chat>>{}.obs;
  final RxList<Transaction> _chatList = <Transaction>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  Map<int, List<Chat>> get chatsByTransaction => _chatsByTransaction;
  List<Transaction> get chatList => _chatList;
  int get unreadCount => _unreadCount.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchChatList();
    fetchUnreadCount();
  }

  Future<void> fetchChatList() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.get('/chats', token: token);
      if (response['success']) {
        // Handle the response format where data contains {chats: []}
        final responseData = response['data'];
        List<dynamic> chatListData = [];

        if (responseData is Map) {
          if (responseData.containsKey('chats')) {
            // API returns {"success": true, "data": {"chats": [...]}}
            chatListData = responseData['chats'] as List<dynamic>? ?? [];
          } else if (responseData.containsKey('data')) {
            // API returns {"success": true, "data": {"data": [...]}}
            chatListData = responseData['data'] as List<dynamic>? ?? [];
          }
        } else if (responseData is List) {
          // Direct list format
          chatListData = responseData;
        }

        print('ChatController: Processing ${chatListData.length} chat items');
        _chatList.value = chatListData
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch chat list';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final response = await _apiService.get(
        '/chats/unread-count',
        token: token,
      );
      if (response['success']) {
        _unreadCount.value = response['data']['unread_count'] ?? 0;
      }
    } catch (e) {
      print('Error fetching unread count: $e');
      // Set default value when API fails
      _unreadCount.value = 0;
    }
  }

  Future<void> fetchChatMessages(int transactionId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return;
      }

      final response = await _apiService.get(
        '/transactions/$transactionId/chats',
        token: token,
      );
      if (response['success']) {
        // Handle nested response structure
        final responseData = response['data'];

        if (responseData is Map) {
          final List<dynamic> chatData =
              responseData['chats'] ?? responseData['data'] ?? [];
          final List<Chat> chats = chatData
              .map((json) => Chat.fromJson(json))
              .toList();
          _chatsByTransaction[transactionId] = chats;

          // Update unread count
          _unreadCount.value = responseData['unread_count'] ?? 0;
        } else {
          print(
            'ChatController: Unexpected chat response format: $responseData',
          );
          _chatsByTransaction[transactionId] = [];
        }
      } else {
        _errorMessage.value =
            response['message'] ?? 'Failed to fetch chat messages';
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> sendMessage({
    required int transactionId,
    String? message,
    String? attachmentPath,
    MessageType messageType = MessageType.text,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final data = <String, dynamic>{
        'message_type': messageType.toString().split('.').last,
      };

      if (message != null) data['message'] = message;
      if (attachmentPath != null) data['attachment'] = attachmentPath;

      final response = await _apiService.post(
        '/transactions/$transactionId/chats',
        data: data,
        token: token,
      );

      if (response['success']) {
        // Add the new message to local list
        final newChat = Chat.fromJson(response['data']['chat']);
        if (_chatsByTransaction.containsKey(transactionId)) {
          _chatsByTransaction[transactionId]!.add(newChat);
        } else {
          _chatsByTransaction[transactionId] = [newChat];
        }

        // Refresh chat list to update latest message
        await fetchChatList();
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to send message';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }
  }

  Future<bool> deleteMessage(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _errorMessage.value = 'User not authenticated';
        return false;
      }

      final response = await _apiService.delete('/chats/$chatId', token: token);
      if (response['success']) {
        // Remove message from local lists
        for (var transactionId in _chatsByTransaction.keys) {
          _chatsByTransaction[transactionId]?.removeWhere(
            (chat) => chat.id == chatId,
          );
        }

        Get.snackbar('Success', 'Message deleted successfully');
        return true;
      } else {
        _errorMessage.value = response['message'] ?? 'Failed to delete message';
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: $e';
      Get.snackbar('Error', _errorMessage.value);
      return false;
    }
  }

  List<Chat> getChatMessages(int transactionId) {
    return _chatsByTransaction[transactionId] ?? [];
  }

  void markMessagesAsRead(int transactionId) {
    if (_chatsByTransaction.containsKey(transactionId)) {
      for (var chat in _chatsByTransaction[transactionId]!) {
        if (!chat.isRead) {
          _chatsByTransaction[transactionId] =
              _chatsByTransaction[transactionId]!
                  .map(
                    (c) => c.id == chat.id
                        ? c.copyWith(isRead: true, readAt: DateTime.now())
                        : c,
                  )
                  .toList();
        }
      }
    }
  }

  void clearChatMessages(int transactionId) {
    _chatsByTransaction.remove(transactionId);
  }

  void clearAllChats() {
    _chatsByTransaction.clear();
    _chatList.clear();
    _unreadCount.value = 0;
  }
}
