// import 'package:vsc_app/core/providers/base_provider.dart';
// import 'package:vsc_app/core/models/api_response.dart';
// import 'package:vsc_app/features/production/data/services/production_service.dart';
// import 'package:vsc_app/features/production/data/models/box_order_requests.dart';
// import 'package:vsc_app/features/production/data/models/printing_job_requests.dart';
// import 'package:vsc_app/features/production/presentation/models/box_maker_view_model.dart';
// import 'package:vsc_app/features/production/presentation/models/box_order_update_form_model.dart';
// import 'package:vsc_app/core/enums/box_status.dart';
// import 'package:vsc_app/core/enums/order_box_type.dart';

// /// Provider for managing production state and operations
// class ProductionProvider extends BaseProvider {
//   final ProductionService _productionService = ProductionService();

//   // State for box orders
//   bool _isUpdatingBoxOrder = false;
//   String? _lastBoxOrderUpdateError;

//   // State for printing jobs
//   bool _isUpdatingPrintingJob = false;
//   String? _lastPrintingJobUpdateError;

//   // State for box makers
//   bool _isLoadingBoxMakers = false;
//   List<BoxMakerViewModel> _boxMakers = [];
//   String? _lastBoxMakersError;

//   // Getters
//   bool get isUpdatingBoxOrder => _isUpdatingBoxOrder;
//   bool get isUpdatingPrintingJob => _isUpdatingPrintingJob;
//   bool get isLoadingBoxMakers => _isLoadingBoxMakers;
//   String? get lastBoxOrderUpdateError => _lastBoxOrderUpdateError;
//   String? get lastPrintingJobUpdateError => _lastPrintingJobUpdateError;
//   String? get lastBoxMakersError => _lastBoxMakersError;
//   List<BoxMakerViewModel> get boxMakers => List.unmodifiable(_boxMakers);

//   /// Fetch box makers
//   Future<void> fetchBoxMakers({int page = 1, int pageSize = 10}) async {
//     try {
//       setLoading(true);
//       _isLoadingBoxMakers = true;
//       _lastBoxMakersError = null;
//       clearMessages();
//       notifyListeners();

//       final response = await _productionService.getBoxMakers(page: page, pageSize: pageSize);

//       if (response.success) {
//         _boxMakers = BoxMakerViewModel.fromResponseList(response.data!);
//       } else {
//         _lastBoxMakersError = response.error?.message ?? 'Failed to fetch box makers';
//         setError(_lastBoxMakersError!);
//       }
//     } catch (e) {
//       _lastBoxMakersError = e.toString();
//       setError('Error fetching box makers: $e');
//     } finally {
//       setLoading(false);
//       _isLoadingBoxMakers = false;
//       notifyListeners();
//     }
//   }

//   /// Update box order status and details
//   Future<void> updateBoxOrder({required String boxOrderId, required BoxOrderUpdateFormModel formModel}) async {
//     try {
//       setLoading(true);
//       _isUpdatingBoxOrder = true;
//       _lastBoxOrderUpdateError = null;
//       clearMessages();
//       notifyListeners();

//       // Convert form model to API request
//       final request = BoxOrderUpdateRequest(
//         boxMakerId: formModel.boxMakerId,
//         totalBoxCost: formModel.totalBoxCost,
//         boxStatus: formModel.boxStatus?.toApiString(),
//         boxType: formModel.boxType?.toApiString(),
//         boxQuantity: formModel.boxQuantity,
//         estimatedCompletion: formModel.estimatedCompletion?.toIso8601String(),
//       );

//       final response = await _productionService.updateBoxOrder(boxOrderId: boxOrderId, request: request);

//       if (response.success) {
//         setSuccess('Box order updated successfully');
//       } else {
//         _lastBoxOrderUpdateError = response.error?.message ?? 'Failed to update box order';
//         setError(_lastBoxOrderUpdateError!);
//       }
//     } catch (e) {
//       _lastBoxOrderUpdateError = e.toString();
//       setError('Error updating box order: $e');
//     } finally {
//       setLoading(false);
//       _isUpdatingBoxOrder = false;
//       notifyListeners();
//     }
//   }

//   /// Update printing job status and details
//   Future<void> updatePrintingJob({required String printingJobId, required PrintingJobUpdateRequest request}) async {
//     try {
//       setLoading(true);
//       _isUpdatingPrintingJob = true;
//       _lastPrintingJobUpdateError = null;
//       clearMessages();
//       notifyListeners();

//       final response = await _productionService.updatePrintingJob(printingJobId: printingJobId, request: request);

//       if (response.success) {
//         setSuccess('Printing job updated successfully');
//       } else {
//         _lastPrintingJobUpdateError = response.error?.message ?? 'Failed to update printing job';
//         setError(_lastPrintingJobUpdateError!);
//       }
//     } catch (e) {
//       _lastPrintingJobUpdateError = e.toString();
//       setError('Error updating printing job: $e');
//     } finally {
//       setLoading(false);
//       _isUpdatingPrintingJob = false;
//       notifyListeners();
//     }
//   }

//   /// Clear error states
//   void clearErrors() {
//     _lastBoxOrderUpdateError = null;
//     _lastPrintingJobUpdateError = null;
//     _lastBoxMakersError = null;
//     notifyListeners();
//   }
// }
