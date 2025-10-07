import 'package:dio/dio.dart';
import 'package:vsc_app/core/models/api_response.dart';
import 'package:vsc_app/core/services/base_service.dart';
import 'package:vsc_app/features/cards/data/models/card_requests.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';
import 'package:vsc_app/core/constants/app_constants.dart';
import 'package:vsc_app/features/cards/data/models/card_detail_response.dart';
import 'package:vsc_app/core/utils/file_upload_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vsc_app/features/cards/data/models/card_update_request.dart';
import 'package:vsc_app/core/utils/query_params.dart';

/// Data layer service for card API communication
/// Handles all API calls related to cards using DTOs only
class CardService extends ApiService {
  /// Get cards with pagination, filters and sorting
  Future<ApiResponse<List<CardResponse>>> getCards({
    int page = 1,
    int pageSize = 10,
    int? quantity,
    int? quantityGt,
    int? quantityGte,
    int? quantityLt,
    int? quantityLte,
    double? costPrice,
    double? costPriceGt,
    double? costPriceGte,
    double? costPriceLt,
    double? costPriceLte,
    String? sortBy,
    String? sortOrder,
  }) async {
    final params = QueryParamsBuilder()
        .withPagination(page: page, pageSize: pageSize)
        .withNumberFilter('quantity', eq: quantity, gt: quantityGt, gte: quantityGte, lt: quantityLt, lte: quantityLte)
        .withNumberFilter('cost_price', eq: costPrice, gt: costPriceGt, gte: costPriceGte, lt: costPriceLt, lte: costPriceLte)
        .withSort(sortBy: sortBy, sortOrder: sortOrder)
        .build();

    return await executeRequest(() => get(AppConstants.cardsEndpoint, queryParameters: params), (json) {
      if (json is List<dynamic>) {
        return json.map((cardJson) => CardResponse.fromJson(cardJson as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  /// Get card by ID
  Future<ApiResponse<CardResponse>> getCardById(String id) async {
    return await executeRequest(
      () => get('${AppConstants.cardsEndpoint}$id/'),
      (json) => CardResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get card sales/detail analytics by ID
  Future<ApiResponse<CardDetailResponse>> getCardDetail(String id) async {
    return await executeRequest(
      () => get('${AppConstants.cardsEndpoint}$id/detail/'),
      (json) => CardDetailResponse.fromJson(json as Map<String, dynamic>),
    );
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
  Future<CreateCardApiResponse> createCard({required XFile imageFile, required CreateCardRequest request}) async {
    return await executeRequest(() async {
      final multipartFile = await FileUploadUtils.createMultipartFileFromXFile(imageFile);
      final formData = FormData.fromMap({
        'image': multipartFile,
        'cost_price': request.costPrice.toString(),
        'sell_price': request.sellPrice.toString(),
        'quantity': request.quantity.toString(),
        'max_discount': request.maxDiscount.toString(),
        'vendor_id': request.vendorId,
        'card_type': request.cardType,
      });
      return post(AppConstants.cardsEndpoint, data: formData);
    }, (json) => CreateCardResponse.fromJson(json as Map<String, dynamic>));
  }

  /// Purchase card stock
  Future<ApiResponse<Map<String, dynamic>>> purchaseCardStock(String cardId, int quantity) async {
    return await executeRequest(
      () => post('${AppConstants.cardsEndpoint}$cardId/purchase/', data: {'quantity': quantity}),
      (json) => json as Map<String, dynamic>,
    );
  }

  /// Update a card
  Future<ApiResponse<Map<String, dynamic>>> updateCard(String cardId, XFile? image, CardUpdateRequest request) async {
    return await executeRequest(() async {
      if (image != null) {
        final multipartFile = await FileUploadUtils.createMultipartFileFromXFile(image);
        final formDataMap = <String, dynamic>{'image': multipartFile};

        // Add only non-null fields to FormData
        if (request.costPrice != null) formDataMap['cost_price'] = request.costPrice;
        if (request.sellPrice != null) formDataMap['sell_price'] = request.sellPrice;
        if (request.maxDiscount != null) formDataMap['max_discount'] = request.maxDiscount;
        if (request.quantity != null) formDataMap['quantity'] = request.quantity.toString();
        if (request.vendorId != null) formDataMap['vendor_id'] = request.vendorId;
        if (request.cardType != null) formDataMap['card_type'] = request.cardType;

        return patch('${AppConstants.cardsEndpoint}$cardId/', data: FormData.fromMap(formDataMap));
      } else {
        // Filter out null values for JSON request
        final filteredData = <String, dynamic>{};
        final requestJson = request.toJson();
        requestJson.forEach((key, value) {
          if (value != null) {
            filteredData[key] = value;
          }
        });
        return patch('${AppConstants.cardsEndpoint}$cardId/', data: filteredData);
      }
    }, (json) => json as Map<String, dynamic>);
  }

  /// Delete a card
  Future<ApiResponse<Map<String, dynamic>>> deleteCard(String cardId) async {
    return await executeRequest(() => delete('${AppConstants.cardsEndpoint}$cardId/'), (json) => json as Map<String, dynamic>);
  }
}
