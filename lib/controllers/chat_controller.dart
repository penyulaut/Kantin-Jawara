import 'package:get/get.dart';
import '../models/chat.dart';
import '../models/chat_item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  final RxMap<int, List<Chat>> _chatsByTransaction = <int, List<Chat>>{}.obs;
  final RxList<ChatItem> _chatList = <ChatItem>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  Map<int, List<Chat>> get chatsByTransaction => _chatsByTransaction;
  List<ChatItem> get chatList => _chatList;
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
      // print('ChatController: Full API response: $response');

      if (response['success']) {
        final responseData = response['data'];
        List<dynamic> chatListData = [];

        if (responseData is Map) {
          if (responseData.containsKey('chats')) {
            final chatsData = responseData['chats'];
            if (chatsData is List) {
              chatListData = chatsData;
            } else {
              // print('ChatController: chats field is not a list: $chatsData');
            }
          } else {
            // print(
            // 'ChatController: Response data does not contain chats field: $responseData',
            // );
          }
        } else if (responseData is List) {
          chatListData = responseData;
        } else {
          // print('ChatController: Unexpected response format: $responseData');
        }

        // print('ChatController: Processing ${chatListData.length} chat items');
        // print('ChatController: Raw chat data: $chatListData');

        try {
          _chatList.value = chatListData
              .map((json) {
                if (json is Map<String, dynamic>) {
                  return ChatItem.fromJson(json);
                } else {
                  // print('ChatController: Invalid chat item format: $json');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<ChatItem>()
              .toList();

          // print('ChatController: Processed ${_chatList.length} chat items');
          for (var item in _chatList) {
            // print(
            // 'ChatController: Chat item - Transaction ID: ${item.transactionId}, Status: ${item.transactionStatus}',
            // );
          }
        } catch (e) {
          // print('ChatController: Error parsing chat items: $e');
          _errorMessage.value = 'Error parsing chat data: $e';
        }
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
      // print('Error fetching unread count: $e');
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

      // print('ChatController: fetchChatMessages response: $response');

      if (response['success']) {
        final responseData = response['data'];
        // print('ChatController: fetchChatMessages responseData: $responseData');

        if (responseData is Map) {
          List<Chat> chats = [];

          if (responseData.containsKey('chats')) {
            final chatsSection = responseData['chats'];
            if (chatsSection is Map && chatsSection.containsKey('data')) {
              final List<dynamic> chatData =
                  chatsSection['data'] as List<dynamic>? ?? [];
              chats = chatData
                  .map((json) {
                    try {
                      return Chat.fromJson(json);
                    } catch (e) {
                      // print(
                      // 'ChatController: Error parsing chat message: $e, JSON: $json',
                      // );
                      return null;
                    }
                  })
                  .where((chat) => chat != null)
                  .cast<Chat>()
                  .toList();
            } else if (chatsSection is List) {
              chats = chatsSection
                  .map((json) {
                    try {
                      return Chat.fromJson(json);
                    } catch (e) {
                      // print(
                      // 'ChatController: Error parsing chat message: $e, JSON: $json',
                      // );
                      return null;
                    }
                  })
                  .where((chat) => chat != null)
                  .cast<Chat>()
                  .toList();
            }
          }

          _chatsByTransaction[transactionId] = chats;
          // print(
          // 'ChatController: Stored ${chats.length} messages for transaction $transactionId',
          // );

          // Update unread count
          _unreadCount.value = responseData['unread_count'] ?? 0;
        } else {
          // print(
          // 'ChatController: Unexpected chat response format: $responseData',
          // );
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

      Map<String, dynamic> response;

      if (attachmentPath != null && messageType == MessageType.image) {
        // Use multipart upload for image attachments
        final fields = <String, String>{
          'message_type': messageType.toString().split('.').last,
        };

        if (message != null) {
          fields['message'] = message;
        }

        response = await _apiService.postMultipart(
          '/transactions/$transactionId/chats',
          fields: fields,
          filePath: attachmentPath,
          fileFieldName: 'attachment',
          token: token,
        );
      } else {
        // Use regular post for text messages
        final data = <String, dynamic>{
          'message_type': messageType.toString().split('.').last,
        };

        if (message != null) data['message'] = message;
        if (attachmentPath != null) data['attachment'] = attachmentPath;

        response = await _apiService.post(
          '/transactions/$transactionId/chats',
          data: data,
          token: token,
        );
      }

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

  Future<bool> sendImageMessage({
    required int transactionId,
    required String imagePath,
    String? message,
  }) async {
    return await sendMessage(
      transactionId: transactionId,
      message: message,
      attachmentPath: imagePath,
      messageType: MessageType.image,
    );
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

  int getUnreadCountForTransaction(int transactionId) {
    final chatItem = _chatList.firstWhereOrNull(
      (item) => item.transactionId == transactionId,
    );
    return chatItem?.unreadCount ?? 0;
  }

  bool hasUnreadMessages(int transactionId) {
    return getUnreadCountForTransaction(transactionId) > 0;
  }

  int getTotalUnreadCount() {
    return _chatList.fold(0, (sum, item) => sum + item.unreadCount);
  }
}
