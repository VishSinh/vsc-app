import 'package:vsc_app/core/enums/bill_status.dart';
import 'package:vsc_app/features/bills/data/models/bill_get_response.dart';
import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';

class BillViewModel {
  final String id;
  final String orderId;
  final String orderName;
  final double taxPercentage;
  final BillStatus paymentStatus;
  final BillOrderViewModel order;
  final BillSummaryViewModel summary;

  BillViewModel({
    required this.id,
    required this.orderId,
    required this.orderName,
    required this.taxPercentage,
    required this.paymentStatus,
    required this.order,
    required this.summary,
  });

  /// Get the bill ID associated with this bill's order for navigation purposes
  String get orderBillId => id;

  factory BillViewModel.fromApiResponse(BillGetResponse response) {
    return BillViewModel(
      id: response.id,
      orderId: response.orderId,
      orderName: response.orderName,
      taxPercentage: double.tryParse(response.taxPercentage) ?? 0.0,
      paymentStatus: BillStatusExtension.fromApiString(response.paymentStatus) ?? BillStatus.pending,
      order: BillOrderViewModel.fromApiResponse(response.order),
      summary: BillSummaryViewModel.fromApiResponse(response.summary),
    );
  }
}

class BillOrderViewModel {
  final String id;
  final String name;
  final String customerId;
  final String customerName;
  final String staffId;
  final String staffName;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String orderStatus;
  final String specialInstruction;
  final List<BillOrderItemViewModel> orderItems;

  BillOrderViewModel({
    required this.id,
    required this.name,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderStatus,
    required this.specialInstruction,
    required this.orderItems,
  });

  factory BillOrderViewModel.fromApiResponse(BillOrderResponse response) {
    return BillOrderViewModel(
      id: response.id,
      name: response.name,
      customerId: response.customerId,
      customerName: response.customerName,
      staffId: response.staffId,
      staffName: response.staffName,
      orderDate: DateTime.parse(response.orderDate),
      deliveryDate: DateTime.parse(response.deliveryDate),
      orderStatus: response.orderStatus,
      specialInstruction: response.specialInstruction,
      orderItems: response.orderItems.map((item) => BillOrderItemViewModel.fromApiResponse(item as BillOrderItemResponse)).toList(),
    );
  }
}

class BillOrderItemViewModel extends OrderItemViewModel {
  final CalculatedCostsViewModel calculatedCosts;

  BillOrderItemViewModel({
    required super.id,
    required super.orderId,
    required super.orderName,
    required super.cardId,
    required super.quantity,
    required super.pricePerItem,
    required super.discountAmount,
    required super.requiresBox,
    required super.requiresPrinting,
    required this.calculatedCosts,
  }) : super(
         boxOrders: null, // Bill items don't have box_orders
         printingJobs: null, // Bill items don't have printing_jobs
       );

  factory BillOrderItemViewModel.fromApiResponse(BillOrderItemResponse response) {
    return BillOrderItemViewModel(
      id: response.id,
      orderId: response.orderId,
      orderName: response.orderName,
      cardId: response.cardId,
      quantity: response.quantity,
      pricePerItem: response.pricePerItem,
      discountAmount: response.discountAmount,
      requiresBox: response.requiresBox,
      requiresPrinting: response.requiresPrinting,
      calculatedCosts: CalculatedCostsViewModel.fromApiResponse(response.calculatedCosts),
    );
  }
}

class CalculatedCostsViewModel {
  final double baseCost;
  final double boxCost;
  final double printingCost;
  final double totalCost;

  CalculatedCostsViewModel({required this.baseCost, required this.boxCost, required this.printingCost, required this.totalCost});

  factory CalculatedCostsViewModel.fromApiResponse(CalculatedCostsResponse response) {
    return CalculatedCostsViewModel(
      baseCost: double.tryParse(response.baseCost) ?? 0.0,
      boxCost: double.tryParse(response.boxCost) ?? 0.0,
      printingCost: double.tryParse(response.printingCost) ?? 0.0,
      totalCost: double.tryParse(response.totalCost) ?? 0.0,
    );
  }

  // Formatted getters for UI
  String get formattedBaseCost => '₹${baseCost.toStringAsFixed(2)}';
  String get formattedBoxCost => '₹${boxCost.toStringAsFixed(2)}';
  String get formattedPrintingCost => '₹${printingCost.toStringAsFixed(2)}';
  String get formattedTotalCost => '₹${totalCost.toStringAsFixed(2)}';
}

class BillSummaryViewModel {
  final double itemsSubtotal;
  final double totalBoxCost;
  final double totalPrintingCost;
  final double grandTotal;
  final double taxPercentage;
  final double taxAmount;
  final double totalWithTax;

  BillSummaryViewModel({
    required this.itemsSubtotal,
    required this.totalBoxCost,
    required this.totalPrintingCost,
    required this.grandTotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalWithTax,
  });

  factory BillSummaryViewModel.fromApiResponse(BillSummaryResponse response) {
    return BillSummaryViewModel(
      itemsSubtotal: double.tryParse(response.itemsSubtotal) ?? 0.0,
      totalBoxCost: double.tryParse(response.totalBoxCost) ?? 0.0,
      totalPrintingCost: double.tryParse(response.totalPrintingCost) ?? 0.0,
      grandTotal: double.tryParse(response.grandTotal) ?? 0.0,
      taxPercentage: double.tryParse(response.taxPercentage) ?? 0.0,
      taxAmount: double.tryParse(response.taxAmount) ?? 0.0,
      totalWithTax: double.tryParse(response.totalWithTax) ?? 0.0,
    );
  }

  // Formatted getters for UI
  String get formattedItemsSubtotal => '₹${itemsSubtotal.toStringAsFixed(2)}';
  String get formattedTotalBoxCost => '₹${totalBoxCost.toStringAsFixed(2)}';
  String get formattedTotalPrintingCost => '₹${totalPrintingCost.toStringAsFixed(2)}';
  String get formattedGrandTotal => '₹${grandTotal.toStringAsFixed(2)}';
  String get formattedTaxPercentage => '${taxPercentage.toStringAsFixed(2)}%';
  String get formattedTaxAmount => '₹${taxAmount.toStringAsFixed(2)}';
  String get formattedTotalWithTax => '₹${totalWithTax.toStringAsFixed(2)}';
}
