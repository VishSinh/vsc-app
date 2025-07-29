import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/models/card_model.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/core/constants/app_constants.dart';

class CardService extends BaseService {
  /// Get cards with pagination
  Future<ApiResponse<List<Card>>> getCards({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.cardsEndpoint}?page=$page&page_size=$pageSize'), (json) {
      // json here is already the data array from the API response
      if (json is List<dynamic>) {
        return json.map((cardJson) => Card.fromJson(cardJson as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  /// Get card by ID
  Future<ApiResponse<Card>> getCardById(String id) async {
    return await executeRequest(() => get('${AppConstants.cardsEndpoint}$id/'), (json) => Card.fromJson(json as Map<String, dynamic>));
  }

  /// Get card by barcode
  Future<ApiResponse<Card>> getCardByBarcode(String barcode) async {
    return await executeRequest(() => get('${AppConstants.cardsEndpoint}?barcode=$barcode'), (json) => Card.fromJson(json as Map<String, dynamic>));
  }

  /// Create a new card
  Future<ApiResponse<MessageData>> createCard({
    required String image,
    required double costPrice,
    required double sellPrice,
    required int quantity,
    required double maxDiscount,
    required String vendorId,
  }) async {
    final request = CreateCardRequest(
      image: image,
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      maxDiscount: maxDiscount,
      vendorId: vendorId,
    );

    return await executeRequest(
      () => post(AppConstants.cardsEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get similar cards based on image URL
  Future<ApiResponse<List<Card>>> getSimilarCards(String imageUrl) async {
    try {
      final response = await dio.get(AppConstants.similarCardsEndpoint, queryParameters: {'image': imageUrl});
      return handleResponse<List<Card>>(response, (json) {
        if (json is List) {
          return json.map((item) => Card.fromJson(item)).toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse<List<Card>>(
        success: false,
        data: null,
        error: ErrorData(code: 'NETWORK_ERROR', message: 'Failed to get similar cards: $e', details: ''),
      );
    }
  }

  /// Purchase card stock
  Future<ApiResponse<Map<String, dynamic>>> purchaseCardStock(String cardId, int quantity) async {
    try {
      final response = await dio.patch('${AppConstants.cardsEndpoint}$cardId/purchase/', data: {'quantity': quantity});
      return handleResponse<Map<String, dynamic>>(response, (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }
        return {};
      });
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        data: null,
        error: ErrorData(code: 'NETWORK_ERROR', message: 'Failed to purchase card stock: $e', details: ''),
      );
    }
  }
}
