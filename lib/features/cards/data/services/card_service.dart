import 'package:dio/dio.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/cards/data/models/card_requests.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/core/utils/file_upload_utils.dart';
import 'package:image_picker/image_picker.dart';

/// Data layer service for card API communication
/// Handles all API calls related to cards using DTOs only
class CardService extends ApiService {
  /// Get cards with pagination
  Future<ApiResponse<List<CardResponse>>> getCards({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.cardsEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        return json.map((cardJson) => CardResponse.fromJson(cardJson as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  /// Get card by ID
  Future<ApiResponse<CardResponse>> getCardById(String id) async {
    return await executeRequest(() => get('${AppConstants.cardsEndpoint}$id/'), (json) => CardResponse.fromJson(json as Map<String, dynamic>));
  }

  /// Get card by barcode
  Future<ApiResponse<CardResponse>> getCardByBarcode(String barcode) async {
    return await executeRequest(
      () => get('${AppConstants.cardsEndpoint}?barcode=$barcode'),
      (json) => CardResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Search for similar cards using image upload
  Future<ApiResponse<List<CardResponse>>> searchSimilarCards(XFile imageFile) async {
    return await executeRequest(
      () async {
        final multipartFile = await FileUploadUtils.createMultipartFileFromXFile(imageFile);
        return post(AppConstants.similarCardsEndpoint, data: FormData.fromMap({'image': multipartFile}));
      },
      (json) {
        if (json is List<dynamic>) return json.map((cardJson) => CardResponse.fromJson(cardJson as Map<String, dynamic>)).toList();
        throw Exception('Invalid response format');
      },
    );
  }

  /// Create a new card with image upload
  Future<ApiResponse<MessageData>> createCard({required XFile imageFile, required CreateCardRequest request}) async {
    return await executeRequest(() async {
      final multipartFile = await FileUploadUtils.createMultipartFileFromXFile(imageFile);
      final formData = FormData.fromMap({
        'image': multipartFile,
        'cost_price': request.costPrice.toString(),
        'sell_price': request.sellPrice.toString(),
        'quantity': request.quantity.toString(),
        'max_discount': request.maxDiscount.toString(),
        'vendor_id': request.vendorId,
      });
      return post(AppConstants.cardsEndpoint, data: formData);
    }, (json) => MessageData.fromJson(json as Map<String, dynamic>));
  }

  /// Purchase card stock
  Future<ApiResponse<Map<String, dynamic>>> purchaseCardStock(String cardId, int quantity) async {
    return await executeRequest(
      () => post('${AppConstants.cardsEndpoint}$cardId/purchase/', data: {'quantity': quantity}),
      (json) => json as Map<String, dynamic>,
    );
  }
}
