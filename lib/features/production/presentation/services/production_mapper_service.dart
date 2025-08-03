import 'package:vsc_app/features/production/data/models/box_order_requests.dart';
import 'package:vsc_app/features/production/data/models/printing_job_requests.dart';
import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
import 'package:vsc_app/features/production/presentation/models/printing_job_update_form_model.dart';
import 'package:vsc_app/core/enums/box_status.dart';
import 'package:vsc_app/core/enums/order_box_type.dart';
import 'package:vsc_app/core/enums/printing_status.dart';

/// Mapper service for converting form models to API requests
class ProductionMapperService {
  //BoxOrderMapperService/ Convert form model to API request, only including changed fields
  static BoxOrderUpdateRequest? formModelToRequest(BoxOrderUpdateFormModel formModel) {
    final request = <String, dynamic>{};
    bool hasAnyChanges = false;

    // Check box maker ID
    if (_isValueChanged(formModel.boxMakerId, formModel.currentBoxMakerId)) {
      request['box_maker_id'] = formModel.currentBoxMakerId;
      hasAnyChanges = true;
    }

    // Check total box cost
    if (_isValueChanged(formModel.totalBoxCost, formModel.currentTotalBoxCost)) {
      request['total_box_cost'] = formModel.currentTotalBoxCost;
      hasAnyChanges = true;
    }

    // Check box status
    if (_isValueChanged(formModel.boxStatus, formModel.currentBoxStatus)) {
      request['box_status'] = formModel.currentBoxStatus?.toApiString();
      hasAnyChanges = true;
    }

    // Check box type
    if (_isValueChanged(formModel.boxType, formModel.currentBoxType)) {
      request['box_type'] = formModel.currentBoxType?.toApiString();
      hasAnyChanges = true;
    }

    // Check box quantity
    if (_isValueChanged(formModel.boxQuantity, formModel.currentBoxQuantity)) {
      request['box_quantity'] = formModel.currentBoxQuantity;
      hasAnyChanges = true;
    }

    // Check estimated completion
    if (_isValueChanged(formModel.estimatedCompletion, formModel.currentEstimatedCompletion)) {
      request['estimated_completion'] = formModel.currentEstimatedCompletion?.toIso8601String();
      hasAnyChanges = true;
    }

    // Return null if no changes, otherwise return the request
    return hasAnyChanges ? BoxOrderUpdateRequest.fromJson(request) : null;
  }

  /// Convert printing job form model to API request, only including changed fields
  static PrintingJobUpdateRequest? printingJobUpdateFormModelToRequest(PrintingJobUpdateFormModel formModel) {
    final request = <String, dynamic>{};
    bool hasAnyChanges = false;

    // Check printer ID
    if (_isValueChanged(formModel.printerId, formModel.currentPrinterId)) {
      request['printer_id'] = formModel.currentPrinterId;
      hasAnyChanges = true;
    }

    // Check tracing studio ID
    if (_isValueChanged(formModel.tracingStudioId, formModel.currentTracingStudioId)) {
      request['tracing_studio_id'] = formModel.currentTracingStudioId;
      hasAnyChanges = true;
    }

    // Check total printing cost
    if (_isValueChanged(formModel.totalPrintingCost, formModel.currentTotalPrintingCost)) {
      request['total_printing_cost'] = formModel.currentTotalPrintingCost;
      hasAnyChanges = true;
    }

    // Check printing status
    if (_isValueChanged(formModel.printingStatus, formModel.currentPrintingStatus)) {
      request['printing_status'] = formModel.currentPrintingStatus?.toApiString();
      hasAnyChanges = true;
    }

    // Check print quantity
    if (_isValueChanged(formModel.printQuantity, formModel.currentPrintQuantity)) {
      request['print_quantity'] = formModel.currentPrintQuantity;
      hasAnyChanges = true;
    }

    // Check estimated completion
    if (_isValueChanged(formModel.estimatedCompletion, formModel.currentEstimatedCompletion)) {
      request['estimated_completion'] = formModel.currentEstimatedCompletion?.toIso8601String();
      hasAnyChanges = true;
    }

    // Return null if no changes, otherwise return the request
    return hasAnyChanges ? PrintingJobUpdateRequest.fromJson(request) : null;
  }

  /// Compare two values, treating null and empty string as same
  static bool _isValueChanged(dynamic original, dynamic current) {
    if (original == null && current == null) return false;
    if (original == null && current != null && current.toString().isEmpty) return false;
    if (current == null && original != null && original.toString().isEmpty) return false;
    if (original == null && current != null && current.toString().isNotEmpty) return true;
    if (current == null && original != null && original.toString().isNotEmpty) return true;
    return original != current;
  }
}
