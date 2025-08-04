import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/features/production/data/models/box_order_requests.dart';

class BoxOrderUpdateFormModel {
  // Original values
  String? boxMakerId;
  String? totalBoxCost;
  String? totalBoxExpense;
  BoxStatus? boxStatus;
  OrderBoxType? boxType;
  int? boxQuantity;
  DateTime? estimatedCompletion;

  // Current values
  String? currentBoxMakerId;
  String? currentTotalBoxCost;
  String? currentTotalBoxExpense;
  BoxStatus? currentBoxStatus;
  OrderBoxType? currentBoxType;
  int? currentBoxQuantity;
  DateTime? currentEstimatedCompletion;

  factory BoxOrderUpdateFormModel.fromCurrentData({
    String? boxMakerId,
    String? totalBoxCost,
    String? totalBoxExpense,
    String? boxStatus,
    String? boxType,
    int? boxQuantity,
    String? estimatedCompletion,
  }) {
    final model = BoxOrderUpdateFormModel._();
    model.boxMakerId = boxMakerId;
    model.totalBoxCost = totalBoxCost;
    model.totalBoxExpense = totalBoxExpense;
    model.boxStatus = BoxStatusExtension.fromApiString(boxStatus);
    model.boxType = OrderBoxTypeExtension.fromApiString(boxType);
    model.boxQuantity = boxQuantity;
    model.estimatedCompletion = estimatedCompletion != null ? DateTime.tryParse(estimatedCompletion) : null;

    // Initialize current values with original values
    model.currentBoxMakerId = model.boxMakerId;
    model.currentTotalBoxCost = model.totalBoxCost;
    model.currentTotalBoxExpense = model.totalBoxExpense;
    model.currentBoxStatus = model.boxStatus;
    model.currentBoxType = model.boxType;
    model.currentBoxQuantity = model.boxQuantity;
    model.currentEstimatedCompletion = model.estimatedCompletion;

    return model;
  }

  BoxOrderUpdateFormModel._();

  bool get hasChanges {
    return _isValueChanged(boxMakerId, currentBoxMakerId) ||
        _isValueChanged(totalBoxCost, currentTotalBoxCost) ||
        _isValueChanged(totalBoxExpense, currentTotalBoxExpense) ||
        _isValueChanged(boxStatus, currentBoxStatus) ||
        _isValueChanged(boxType, currentBoxType) ||
        _isValueChanged(boxQuantity, currentBoxQuantity) ||
        _isValueChanged(estimatedCompletion, currentEstimatedCompletion);
  }

  BoxOrderUpdateRequest? toApiRequest() {
    final request = <String, dynamic>{};
    bool hasAnyChanges = false;

    if (_isValueChanged(boxMakerId, currentBoxMakerId)) {
      request['box_maker_id'] = currentBoxMakerId;
      hasAnyChanges = true;
    }

    if (_isValueChanged(totalBoxCost, currentTotalBoxCost)) {
      request['total_box_cost'] = currentTotalBoxCost;
      hasAnyChanges = true;
    }

    if (_isValueChanged(totalBoxExpense, currentTotalBoxExpense)) {
      request['total_box_expense'] = currentTotalBoxExpense;
      hasAnyChanges = true;
    }

    if (_isValueChanged(boxStatus, currentBoxStatus)) {
      request['box_status'] = currentBoxStatus?.toApiString();
      hasAnyChanges = true;
    }

    if (_isValueChanged(boxType, currentBoxType)) {
      request['box_type'] = currentBoxType?.toApiString();
      hasAnyChanges = true;
    }

    if (_isValueChanged(boxQuantity, currentBoxQuantity)) {
      request['box_quantity'] = currentBoxQuantity;
      hasAnyChanges = true;
    }

    if (_isValueChanged(estimatedCompletion, currentEstimatedCompletion)) {
      request['estimated_completion'] = currentEstimatedCompletion?.toIso8601String();
      hasAnyChanges = true;
    }

    return hasAnyChanges ? BoxOrderUpdateRequest.fromJson(request) : null;
  }

  bool _isValueChanged(dynamic original, dynamic current) {
    if (original == null && current == null) return false;
    if (original == null && current != null && current.toString().isEmpty) return false;
    if (current == null && original != null && original.toString().isEmpty) return false;
    if (original == null && current != null && current.toString().isNotEmpty) return true;
    if (current == null && original != null && original.toString().isNotEmpty) return true;
    return original != current;
  }
}
