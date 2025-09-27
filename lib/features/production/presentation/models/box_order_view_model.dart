import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/production/data/models/box_order_response.dart';

class BoxOrderViewModel {
  final String id;
  final String orderItemId;
  final String? boxMakerId;
  final String? boxMakerName;
  final OrderBoxType boxType;
  final int boxQuantity;
  final String totalBoxCost;
  final String? totalBoxExpense;
  final String boxStatus;
  final DateTime? estimatedCompletion;

  BoxOrderViewModel({
    required this.id,
    required this.orderItemId,
    this.boxMakerId,
    this.boxMakerName,
    required this.boxType,
    required this.boxQuantity,
    required this.totalBoxCost,
    this.totalBoxExpense,
    required this.boxStatus,
    this.estimatedCompletion,
  });

  factory BoxOrderViewModel.fromApiResponse(BoxOrderResponse response) {
    return BoxOrderViewModel(
      id: response.id,
      orderItemId: response.orderItemId,
      boxMakerId: response.boxMakerId,
      boxMakerName: response.boxMakerName,
      boxType: OrderBoxTypeExtension.fromApiString(response.boxType) ?? OrderBoxType.folding,
      boxQuantity: response.boxQuantity,
      totalBoxCost: response.totalBoxCost,
      totalBoxExpense: response.totalBoxExpense,
      boxStatus: response.boxStatus,
      estimatedCompletion: response.estimatedCompletion != null ? DateTime.parse(response.estimatedCompletion!) : null,
    );
  }
}
