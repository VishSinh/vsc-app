import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';

/// Form model for updating box orders
class BoxOrderUpdateFormModel {
  // Original values (populated from current box order data)
  String? boxMakerId;
  String? totalBoxCost;
  BoxStatus? boxStatus;
  OrderBoxType? boxType;
  int? boxQuantity;
  DateTime? estimatedCompletion;

  // Current values (user input)
  String? currentBoxMakerId;
  String? currentTotalBoxCost;
  BoxStatus? currentBoxStatus;
  OrderBoxType? currentBoxType;
  int? currentBoxQuantity;
  DateTime? currentEstimatedCompletion;

  BoxOrderUpdateFormModel({this.boxMakerId, this.totalBoxCost, this.boxStatus, this.boxType, this.boxQuantity, this.estimatedCompletion});

  /// Create from current box order data
  factory BoxOrderUpdateFormModel.fromCurrentData({
    String? boxMakerId,
    String? totalBoxCost,
    String? boxStatus,
    String? boxType,
    int? boxQuantity,
    String? estimatedCompletion,
  }) {
    return BoxOrderUpdateFormModel(
      boxMakerId: boxMakerId,
      totalBoxCost: totalBoxCost,
      boxStatus: BoxStatusExtension.fromApiString(boxStatus),
      boxType: OrderBoxTypeExtension.fromApiString(boxType),
      boxQuantity: boxQuantity,
      estimatedCompletion: estimatedCompletion != null ? DateTime.tryParse(estimatedCompletion) : null,
    );
  }

  /// Check if form has any changes
  bool get hasChanges {
    return _isValueChanged(boxMakerId, currentBoxMakerId) ||
        _isValueChanged(totalBoxCost, currentTotalBoxCost) ||
        _isValueChanged(boxStatus, currentBoxStatus) ||
        _isValueChanged(boxType, currentBoxType) ||
        _isValueChanged(boxQuantity, currentBoxQuantity) ||
        _isValueChanged(estimatedCompletion, currentEstimatedCompletion);
  }

  /// Compare two values, treating null and empty string as same
  bool _isValueChanged(dynamic original, dynamic current) {
    if (original == null && current == null) return false;
    if (original == null && current != null && current.toString().isEmpty) return false;
    if (current == null && original != null && original.toString().isEmpty) return false;
    if (original == null && current != null && current.toString().isNotEmpty) return true;
    if (current == null && original != null && original.toString().isNotEmpty) return true;
    return original != current;
  }

  /// Clear all form data
  void clear() {
    boxMakerId = null;
    totalBoxCost = null;
    boxStatus = null;
    boxType = null;
    boxQuantity = null;
    estimatedCompletion = null;

    // Reset current values
    currentBoxMakerId = null;
    currentTotalBoxCost = null;
    currentBoxStatus = null;
    currentBoxType = null;
    currentBoxQuantity = null;
    currentEstimatedCompletion = null;
  }
}
