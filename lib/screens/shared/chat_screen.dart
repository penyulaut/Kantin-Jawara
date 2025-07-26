import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat.dart';
import '../../utils/app_theme.dart';

class ChatScreen extends StatelessWidget {
  final int transactionId;
  final ChatController controller = Get.put(ChatController());
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  ChatScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    // Load messages when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchChatMessages(transactionId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$transactionId Chat'),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading ? null : () => _refreshMessages(),
              icon: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.refresh),
              tooltip: 'Refresh messages',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              final messages = controller.getChatMessages(transactionId);

              if (controller.isLoading && messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.royalBlueDark,
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading messages...',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we fetch the chat',
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        size: 64,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.royalBlueDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshMessages,
                color: AppTheme.royalBlueDark,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              );
            }),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkGray.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image upload button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.goldenPoppy.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppTheme.goldenPoppy.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _pickAndSendImage,
                    icon: Icon(
                      Icons.image,
                      color: AppTheme.goldenPoppy,
                      size: 20,
                    ),
                    tooltip: 'Send image',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppTheme.mediumGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppTheme.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: AppTheme.royalBlueDark,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppTheme.lightGray),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppTheme.lightGray.withOpacity(0.3),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      gradient: controller.isLoading
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.royalBlueDark,
                                AppTheme.usafaBlue,
                              ],
                            ),
                      color: controller.isLoading ? AppTheme.mediumGray : null,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: controller.isLoading ? null : _sendMessage,
                      icon: controller.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(Icons.send, color: Colors.white),
                      tooltip: 'Send message',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Chat message) {
    // Check if message is from current user by comparing sender ID
    final currentUserId = authController.currentUser?.id;
    final isFromCurrentUser = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.goldenPoppy.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.royalBlueDark,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: Get.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? AppTheme.royalBlueDark
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isFromCurrentUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isFromCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.message != null &&
                      message.message!.isNotEmpty) ...[
                    Text(
                      message.message!,
                      style: TextStyle(
                        color: isFromCurrentUser
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],

                  if (message.attachmentUrl != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showFullScreenImage(message.attachmentUrl!),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 250,
                          maxWidth: Get.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.attachmentUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.royalBlueDark,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  Text(
                    message.formattedTime,
                    style: TextStyle(
                      color: isFromCurrentUser
                          ? Colors.white70
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.royalBlueDark.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.royalBlueDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    final success = await controller.sendMessage(
      transactionId: transactionId,
      message: message,
      messageType: MessageType.text,
    );

    if (success) {
      messageController.clear();
    }
  }

  Future<void> _refreshMessages() async {
    await controller.fetchChatMessages(transactionId);
  }

  Future<void> _pickAndSendImage() async {
    try {
      // Request camera permission for camera option
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isDenied) {
        Get.snackbar(
          'Permission Required',
          'Camera permission is required to take photos.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: Icon(Icons.warning, color: Colors.white),
        );
        return;
      }

      // Show options dialog for camera or gallery
      final result = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(
            'Select Image Source',
            style: TextStyle(
              color: AppTheme.royalBlueDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.royalBlueDark),
                title: const Text('Camera'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppTheme.royalBlueDark,
                ),
                title: const Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      if (result == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: result,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Check file size (max 5MB)
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'Image size too large. Please select an image smaller than 5MB.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      // Show loading indicator
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.royalBlueDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sending image...',
                style: TextStyle(
                  color: AppTheme.royalBlueDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Send image
      final success = await controller.sendImageMessage(
        transactionId: transactionId,
        imagePath: pickedFile.path,
        message: messageController.text.trim().isNotEmpty
            ? messageController.text.trim()
            : null,
      );

      // Close loading dialog
      Get.back();

      if (success) {
        messageController.clear();
        Get.snackbar(
          'Success',
          'Image sent successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send image. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      // Close any open dialogs
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
