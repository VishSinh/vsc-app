import 'package:vsc_app/features/orders/presentation/models/order_view_models.dart';

bool hasBoxRequirements(OrderViewModel order) {
  return order.orderItems.any((item) => item.requiresBox);
}

bool hasPrintingRequirements(OrderViewModel order) {
  return order.orderItems.any((item) => item.requiresPrinting);
}

bool isAnyBoxExpenseMissing(OrderViewModel order) {
  for (final item in order.orderItems) {
    if (item.boxOrders != null) {
      for (final box in item.boxOrders!) {
        if (box.totalBoxExpense == null) {
          return true;
        }
      }
    }
  }
  return false;
}

bool isAnyPrintingOrTracingExpenseMissing(OrderViewModel order) {
  for (final item in order.orderItems) {
    if (item.printingJobs != null) {
      for (final job in item.printingJobs!) {
        if (job.totalPrintingExpense == null || job.totalTracingExpense == null) {
          return true;
        }
      }
    }
  }
  return false;
}

String? getBoxMakerName(OrderViewModel order) {
  for (final item in order.orderItems) {
    if (item.boxOrders != null) {
      for (final box in item.boxOrders!) {
        if (box.boxMakerName != null && box.boxMakerName!.isNotEmpty) {
          return box.boxMakerName;
        }
      }
    }
  }
  return null;
}

String? getPrinterName(OrderViewModel order) {
  for (final item in order.orderItems) {
    if (item.printingJobs != null) {
      for (final job in item.printingJobs!) {
        if (job.printerName != null && job.printerName!.isNotEmpty) {
          return job.printerName;
        }
      }
    }
  }
  return null;
}

String? getTracingStudioName(OrderViewModel order) {
  for (final item in order.orderItems) {
    if (item.printingJobs != null) {
      for (final job in item.printingJobs!) {
        if (job.tracingStudioName != null && job.tracingStudioName!.isNotEmpty) {
          return job.tracingStudioName;
        }
      }
    }
  }
  return null;
}
