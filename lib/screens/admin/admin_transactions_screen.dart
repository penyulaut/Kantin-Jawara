import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  late final AdminController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalBlueDark.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Semua Transaksi',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kelola & pantau transaksi',
                          style: TextStyle(
                            color: AppTheme.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => controller.fetchTransactions(),
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.3),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Menunggu', TransactionStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dibayar', TransactionStatus.paid),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dikonfirmasi', TransactionStatus.confirmed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Siap', TransactionStatus.ready),
                  const SizedBox(width: 8),
                  _buildFilterChip('Selesai', TransactionStatus.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dibatalkan', TransactionStatus.cancelled),
                ],
              ),
            ),
          ),

          Expanded(
            child: GetBuilder<AdminController>(
              builder: (adminController) {
                if (adminController.isLoading) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.royalBlueDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.royalBlueDark,
                              ),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat Transaksi...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (adminController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppTheme.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            adminController.errorMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                adminController.fetchTransactions(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.royalBlueDark,
                              foregroundColor: AppTheme.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (adminController.transactions.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.mediumGray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 48,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak Ada Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada transaksi yang ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adminController.fetchTransactions(),
                  color: AppTheme.royalBlueDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: adminController.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = adminController.transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionStatus? status) {
    final isSelected = status == null
        ? true // "Semua" is always considered selected for now
        : false; // You can implement selection logic here

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppTheme.white : AppTheme.darkGray,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.royalBlueDark,
      backgroundColor: AppTheme.white,
      checkmarkColor: AppTheme.white,
      side: BorderSide(
        color: isSelected ? AppTheme.royalBlueDark : AppTheme.mediumGray,
        width: 1,
      ),
      onSelected: (selected) {
        if (status == null) {
          controller.fetchTransactions();
        } else {
          controller.fetchTransactions();
        }
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGray.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.white,
                AppTheme.royalBlueDark.withOpacity(0.01),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pesanan #${transaction.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  _buildStatusChip(transaction.status),
                ],
              ),
              const SizedBox(height: 12),

              if (transaction.customerName != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaction.customerName!,
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              if (transaction.penjual != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      size: 16,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Penjual: ${transaction.penjual!.name}',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        size: 16,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getOrderTypeText(transaction.orderType),
                        style: TextStyle(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldenPoppy,
                          AppTheme.goldenPoppy.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${_formatCurrency(transaction.totalPrice)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (transaction.createdAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppTheme.mediumGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dibuat: ${_formatDate(transaction.createdAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getOrderTypeText(OrderType orderType) {
    switch (orderType) {
      case OrderType.dineIn:
        return 'Makan di Tempat';
      case OrderType.takeaway:
        return 'Bawa Pulang';
      case OrderType.delivery:
        return 'Antar';
    }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    final color = AppTheme.getStatusColorFromEnum(status);
    final statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.white,
        ),
      ),
    );
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'MENUNGGU';
      case TransactionStatus.paid:
        return 'DIBAYAR';
      case TransactionStatus.confirmed:
        return 'DIKONFIRMASI';
      case TransactionStatus.ready:
        return 'SIAP';
      case TransactionStatus.completed:
        return 'SELESAI';
      case TransactionStatus.cancelled:
        return 'DIBATALKAN';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.royalBlueDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.royalBlueDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Detail Transaksi #${transaction.id}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transaction.customerName != null) ...[
                _buildDetailRow('Pelanggan', transaction.customerName!),
                const SizedBox(height: 8),
              ],
              if (transaction.customerPhone != null) ...[
                _buildDetailRow('Telepon', transaction.customerPhone!),
                const SizedBox(height: 8),
              ],
              if (transaction.penjual != null) ...[
                _buildDetailRow('Penjual', transaction.penjual!.name),
                const SizedBox(height: 8),
              ],
              _buildDetailRow(
                'Jenis Pesanan',
                _getOrderTypeText(transaction.orderType),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Status', _getStatusText(transaction.status)),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Total',
                'Rp ${_formatCurrency(transaction.totalPrice)}',
              ),
              const SizedBox(height: 8),
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                _buildDetailRow('Catatan', transaction.notes!),
                const SizedBox(height: 8),
              ],
              if (transaction.createdAt != null) ...[
                _buildDetailRow(
                  'Waktu Dibuat',
                  _formatDate(transaction.createdAt!),
                ),
              ],
              if (transaction.items != null &&
                  transaction.items!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 16,
                            color: AppTheme.darkGray,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Item Pesanan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...transaction.items!.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: AppTheme.mediumGray,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item.menu?.name ?? 'Menu Tidak Diketahui'} x${item.quantity} - Rp ${_formatCurrency(item.unitPrice)}',
                                  style: TextStyle(
                                    color: AppTheme.darkGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tutup',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGray,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
