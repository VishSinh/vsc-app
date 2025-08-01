import '../../data/models/order_api_models.dart';
import '../../data/models/order_responses.dart';
import '../../domain/models/order.dart';
import '../../domain/models/order_item.dart';
import '../../domain/services/order_price_calculator_service.dart';
import 'package:vsc_app/features/cards/data/models/card_responses.dart';

/// UI-specific representation of an order item with computed properties
class OrderItemViewModel {
  final String cardId;
  final String discountAmount;
  final int quantity;
  final bool requiresBox;
  final bool requiresPrinting;
  final BoxType? boxType;
  final String? totalBoxCost;
  final String? totalPrintingCost;

  // UI-specific computed properties
  final double discountAmountAsDouble;
  final double boxCostAsDouble;
  final double printingCostAsDouble;
  final double lineItemTotal;
  final String formattedDiscountAmount;
  final String formattedBoxCost;
  final String formattedPrintingCost;
  final String formattedLineTotal;

  const OrderItemViewModel({
    required this.cardId,
    required this.discountAmount,
    required this.quantity,
    required this.requiresBox,
    required this.requiresPrinting,
    this.boxType,
    this.totalBoxCost,
    this.totalPrintingCost,
    required this.discountAmountAsDouble,
    required this.boxCostAsDouble,
    required this.printingCostAsDouble,
    required this.lineItemTotal,
    required this.formattedDiscountAmount,
    required this.formattedBoxCost,
    required this.formattedPrintingCost,
    required this.formattedLineTotal,
  });

  /// Convert from API model to UI model
  factory OrderItemViewModel.fromApiModel(OrderItemApiModel apiModel, CardResponse card) {
    final discountAmountAsDouble = double.tryParse(apiModel.discountAmount) ?? 0.0;
    final boxCostAsDouble = apiModel.requiresBox ? (double.tryParse(apiModel.totalBoxCost ?? '0') ?? 0.0) : 0.0;
    final printingCostAsDouble = apiModel.requiresPrinting ? (double.tryParse(apiModel.totalPrintingCost ?? '0') ?? 0.0) : 0.0;

    final basePrice = card.sellPriceAsDouble;
    final lineItemTotal = ((basePrice - discountAmountAsDouble) * apiModel.quantity) + boxCostAsDouble + printingCostAsDouble;

    return OrderItemViewModel(
      cardId: apiModel.cardId,
      discountAmount: apiModel.discountAmount,
      quantity: apiModel.quantity,
      requiresBox: apiModel.requiresBox,
      requiresPrinting: apiModel.requiresPrinting,
      boxType: apiModel.boxType,
      totalBoxCost: apiModel.totalBoxCost,
      totalPrintingCost: apiModel.totalPrintingCost,
      discountAmountAsDouble: discountAmountAsDouble,
      boxCostAsDouble: boxCostAsDouble,
      printingCostAsDouble: printingCostAsDouble,
      lineItemTotal: lineItemTotal,
      formattedDiscountAmount: '₹${discountAmountAsDouble.toStringAsFixed(2)}',
      formattedBoxCost: '₹${boxCostAsDouble.toStringAsFixed(2)}',
      formattedPrintingCost: '₹${printingCostAsDouble.toStringAsFixed(2)}',
      formattedLineTotal: '₹${lineItemTotal.toStringAsFixed(2)}',
    );
  }

  /// Convert from domain model to UI model
  factory OrderItemViewModel.fromDomainModel(OrderItem domainModel, CardResponse card) {
    final basePrice = card.sellPriceAsDouble;
    final lineItemTotal = domainModel.calculateLineTotal(basePrice);

    return OrderItemViewModel(
      cardId: domainModel.cardId,
      discountAmount: domainModel.discountAmount.toString(),
      quantity: domainModel.quantity,
      requiresBox: domainModel.requiresBox,
      requiresPrinting: domainModel.requiresPrinting,
      boxType: domainModel.boxType == OrderBoxType.folding
          ? BoxType.folding
          : domainModel.boxType == OrderBoxType.complete
          ? BoxType.complete
          : null,
      totalBoxCost: domainModel.boxCost.toString(),
      totalPrintingCost: domainModel.printingCost.toString(),
      discountAmountAsDouble: domainModel.discountAmount,
      boxCostAsDouble: domainModel.boxCost,
      printingCostAsDouble: domainModel.printingCost,
      lineItemTotal: lineItemTotal,
      formattedDiscountAmount: '₹${domainModel.discountAmount.toStringAsFixed(2)}',
      formattedBoxCost: '₹${domainModel.boxCost.toStringAsFixed(2)}',
      formattedPrintingCost: '₹${domainModel.printingCost.toStringAsFixed(2)}',
      formattedLineTotal: '₹${lineItemTotal.toStringAsFixed(2)}',
    );
  }

  /// Convert to API model for backend communication
  OrderItemApiModel toApiModel() {
    return OrderItemApiModel(
      cardId: cardId,
      discountAmount: discountAmount,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType,
      totalBoxCost: totalBoxCost,
      totalPrintingCost: totalPrintingCost,
    );
  }

  /// Convert to domain model
  OrderItem toDomainModel() {
    return OrderItem(
      cardId: cardId,
      discountAmount: discountAmountAsDouble,
      quantity: quantity,
      requiresBox: requiresBox,
      requiresPrinting: requiresPrinting,
      boxType: boxType == BoxType.folding
          ? OrderBoxType.folding
          : boxType == BoxType.complete
          ? OrderBoxType.complete
          : null,
      boxCost: boxCostAsDouble,
      printingCost: printingCostAsDouble,
    );
  }
}

/// UI-specific representation of an order with computed properties
class OrderSummaryViewModel {
  final String id;
  final String customerId;
  final String deliveryDate;
  final List<OrderItemViewModel> orderItems;
  final String status;
  final String totalAmount;
  final String createdAt;

  // UI-specific computed properties
  final double totalAmountAsDouble;
  final double totalDiscount;
  final double totalAdditionalCosts;
  final String formattedTotalAmount;
  final String formattedTotalDiscount;
  final String formattedTotalAdditionalCosts;
  final String formattedDeliveryDate;
  final String formattedCreatedDate;

  const OrderSummaryViewModel({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.orderItems,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.totalAmountAsDouble,
    required this.totalDiscount,
    required this.totalAdditionalCosts,
    required this.formattedTotalAmount,
    required this.formattedTotalDiscount,
    required this.formattedTotalAdditionalCosts,
    required this.formattedDeliveryDate,
    required this.formattedCreatedDate,
  });

  /// Convert from API model to UI model
  factory OrderSummaryViewModel.fromApiModel(OrderResponse apiModel, Map<String, CardResponse> cardDetails) {
    final orderItems = apiModel.orderItems.map((item) {
      final card = cardDetails[item.cardId];
      if (card == null) {
        throw Exception('Card not found for item ${item.cardId}');
      }
      return OrderItemViewModel.fromApiModel(item, card);
    }).toList();

    final totalAmountAsDouble = double.tryParse(apiModel.totalAmount) ?? 0.0;
    final totalDiscount = orderItems.fold(0.0, (sum, item) => sum + item.discountAmountAsDouble);
    final totalAdditionalCosts = orderItems.fold(0.0, (sum, item) => sum + item.boxCostAsDouble + item.printingCostAsDouble);

    return OrderSummaryViewModel(
      id: apiModel.id,
      customerId: apiModel.customerId,
      deliveryDate: apiModel.deliveryDate,
      orderItems: orderItems,
      status: apiModel.status,
      totalAmount: apiModel.totalAmount,
      createdAt: apiModel.createdAt,
      totalAmountAsDouble: totalAmountAsDouble,
      totalDiscount: totalDiscount,
      totalAdditionalCosts: totalAdditionalCosts,
      formattedTotalAmount: '₹${totalAmountAsDouble.toStringAsFixed(2)}',
      formattedTotalDiscount: '₹${totalDiscount.toStringAsFixed(2)}',
      formattedTotalAdditionalCosts: '₹${totalAdditionalCosts.toStringAsFixed(2)}',
      formattedDeliveryDate: _formatDate(apiModel.deliveryDate),
      formattedCreatedDate: _formatDate(apiModel.createdAt),
    );
  }

  /// Convert from domain model to UI model
  factory OrderSummaryViewModel.fromDomainModel(Order domainModel, Map<String, CardResponse> cardDetails) {
    final orderItems = domainModel.orderItems.map((item) {
      final card = cardDetails[item.cardId];
      if (card == null) {
        throw Exception('Card not found for item ${item.cardId}');
      }
      return OrderItemViewModel.fromDomainModel(item, card);
    }).toList();

    // Calculate totals using domain service
    final priceCalculator = OrderPriceCalculatorService();
    final totalDiscount = priceCalculator.calculateTotalDiscount(domainModel.orderItems);
    final totalAdditionalCosts = priceCalculator.calculateTotalAdditionalCosts(domainModel.orderItems);

    return OrderSummaryViewModel(
      id: domainModel.id,
      customerId: domainModel.customerId,
      deliveryDate: domainModel.deliveryDate.toIso8601String(),
      orderItems: orderItems,
      status: domainModel.status.name,
      totalAmount: domainModel.totalAmount.toString(),
      createdAt: domainModel.createdAt.toIso8601String(),
      totalAmountAsDouble: domainModel.totalAmount,
      totalDiscount: totalDiscount,
      totalAdditionalCosts: totalAdditionalCosts,
      formattedTotalAmount: '₹${domainModel.totalAmount.toStringAsFixed(2)}',
      formattedTotalDiscount: '₹${totalDiscount.toStringAsFixed(2)}',
      formattedTotalAdditionalCosts: '₹${totalAdditionalCosts.toStringAsFixed(2)}',
      formattedDeliveryDate: _formatDate(domainModel.deliveryDate.toIso8601String()),
      formattedCreatedDate: _formatDate(domainModel.createdAt.toIso8601String()),
    );
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
