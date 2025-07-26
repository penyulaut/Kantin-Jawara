import '../widgets/custom_snackbar.dart';

class MerchantIdUtils {
  static void validateMerchantData({
    required int requestedMerchantId,
    required Map<String, dynamic> responseData,
    bool showWarning = true,
  }) {
    try {
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


        if (showWarning) {
          CustomSnackbar.warning(
            'Merchant ID mismatch: Expected $requestedMerchantId, got user_id $actualUserId',
          );
        }

        return;
      }

    } catch (e) {
    }
  }

  static int? extractCorrectId(Map<String, dynamic> responseData) {
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

  static void debugMerchantMapping(Map<String, dynamic> data) {

    if (data.containsKey('user_id')) {
    }
    if (data.containsKey('merchant_id')) {
    }
    if (data.containsKey('penjual_id')) {
    }
    if (data.containsKey('merchant')) {
    }
  }
}
