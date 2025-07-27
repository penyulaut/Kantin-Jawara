import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_item.dart';
import '../../utils/app_theme.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());


    return Scaffold(
      backgroundColor: AppTheme.lightGray.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'Obrolan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.royalBlueDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchChatList();
            },
            tooltip: 'Segarkan Obrolan',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
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
                  'Memuat obrolan...',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.red),
                const SizedBox(height: 16),
                Text(
                  'Ups! Terjadi kesalahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchChatList(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.royalBlueDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.chatList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(height: 24),
                Text(
                  'Belum ada obrolan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai mengobrol saat Anda melakukan pemesanan',
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.goldenPoppy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.goldenPoppy.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '💡 Tempatkan pesanan untuk mulai mengobrol dengan penjual',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.royalBlueDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchChatList(),
          color: AppTheme.royalBlueDark,
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.lightGray.withOpacity(0.3), Colors.white],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.chatList.length,
              itemBuilder: (context, index) {
                final chatItem = controller.chatList[index];
                return _buildChatItem(context, chatItem);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatItem chatItem) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.lightGray.withOpacity(0.3)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {


              try {
                Get.toNamed(
                  '/chat',
                  arguments: {'transactionId': chatItem.transactionId},
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal membuka obrolan: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: Icon(Icons.error, color: Colors.white),
                );
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                'Pesanan #${chatItem.transactionId}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.royalBlueDark,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        chatItem.transactionStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          chatItem.transactionStatus,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(chatItem.transactionStatus),
                      style: TextStyle(
                        color: _getStatusColor(chatItem.transactionStatus),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (chatItem.latestMessage != null) ...[
                    Row(
                      children: [
                        Icon(Icons.chat, size: 16, color: AppTheme.goldenPoppy),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${chatItem.latestMessage!.senderName}: ${chatItem.latestMessage!.message}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          chatItem.latestMessage!.formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Belum ada pesan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mediumGray,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (chatItem.unreadCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chatItem.unreadCount} Belum dibaca',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlueDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.royalBlueDark,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'Menunggu':
        return 'Menunggu pembayaran';
      case 'Dibayar':
        return 'Sudah dibayar';
      case 'Dikonfirmasi':
        return 'Pesanan Dikonfirmasi';
      case 'Siap':
        return 'Siap untuk diambil';
      case 'Selesai':
        return 'Selesai';
      case 'Dibatalkan':
        return 'Dibatalkan';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'Menunggu':
        return Colors.orange;
      case 'Dibayar':
        return AppTheme.usafaBlue;
      case 'Dikonfirmasi':
        return AppTheme.goldenPoppy;
      case 'Siap':
        return Colors.green;
      case 'Selesai':
        return AppTheme.royalBlueDark;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return AppTheme.mediumGray;
    }
  }
}
