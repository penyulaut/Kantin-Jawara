import '../widgets/custom_snackbar.dart';

class MerchantIdUtils {
  /// Validates and logs merchant ID vs user ID consistency
  static void validateMerchantData({
    required int requestedMerchantId,
    required Map<String, dynamic> responseData,
    bool showWarning = true,
  }) {
    try {
      // Extract user_id from various possible locations in the response
      int? actualUserId;

      if (responseData['user_id'] != null) {
        actualUserId = int.tryParse(responseData['user_id'].toString());
      } else if (responseData['merchant'] != null &&
          responseData['merchant']['id'] != null) {
        actualUserId = int.tryParse(responseData['merchant']['id'].toString());
      } else if (responseData['penjual_id'] != null) {
        actualUserId = int.tryParse(responseData['penjual_id'].toString());
      }

      if (actualUserId != null && actualUserId != requestedMerchantId) {
        final warningMessage =
            '''
DATA INCONSISTENCY DETECTED:
- Requested merchant_id: $requestedMerchantId  
- Actual user_id in response: $actualUserId
- This indicates a mapping issue between merchant_id and user_id
- Recommendation: Use user_id ($actualUserId) instead of merchant_id ($requestedMerchantId)
        ''';

        // print('WARNING: $warningMessage');

        if (showWarning) {
          CustomSnackbar.warning(
            'Merchant ID mismatch: Expected $requestedMerchantId, got user_id $actualUserId',
          );
        }

        return;
      }

      // print('MerchantIdUtils: ID mapping is consistent ($requestedMerchantId)');
    } catch (e) {
      // print('MerchantIdUtils: Error validating merchant data: $e');
    }
  }

  /// Extracts the correct user/merchant ID from response data
  static int? extractCorrectId(Map<String, dynamic> responseData) {
    // Try different possible locations for the ID
    if (responseData['user_id'] != null) {
      return int.tryParse(responseData['user_id'].toString());
    }
    if (responseData['merchant'] != null &&
        responseData['merchant']['id'] != null) {
      return int.tryParse(responseData['merchant']['id'].toString());
    }
    if (responseData['penjual_id'] != null) {
      return int.tryParse(responseData['penjual_id'].toString());
    }
    if (responseData['id'] != null) {
      return int.tryParse(responseData['id'].toString());
    }
    return null;
  }

  /// Provides debugging information about merchant/user ID mapping
  static void debugMerchantMapping(Map<String, dynamic> data) {
    // print('=== MERCHANT ID MAPPING DEBUG ===');
    // print('Raw data keys: ${data.keys.toList()}');

    if (data.containsKey('user_id')) {
      // print('user_id: ${data['user_id']}');
    }
    if (data.containsKey('merchant_id')) {
      // print('merchant_id: ${data['merchant_id']}');
    }
    if (data.containsKey('penjual_id')) {
      // print('penjual_id: ${data['penjual_id']}');
    }
    if (data.containsKey('merchant')) {
      // print('merchant data: ${data['merchant']}');
    }
    // print('==================================');
  }
}
