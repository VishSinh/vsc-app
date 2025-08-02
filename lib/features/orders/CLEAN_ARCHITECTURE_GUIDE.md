# 🏗️ Clean Architecture Guide - Orders Feature

> **Purpose**: This guide helps developers understand and maintain Clean Architecture principles in the orders feature using Data and Presentation layers.

## 📁 Folder Structure & Responsibilities

```
lib/features/orders/
├── data/                    # External data layer (API, Database)
│   ├── models/             # API DTOs and serialization
│   └── services/           # Network/API communication
└── presentation/           # UI layer (Flutter-specific)
    ├── models/            # Form and View models
    ├── pages/             # UI screens
    ├── providers/         # State management
    ├── validators/        # UI-specific validations
    ├── services/          # Business logic and data conversion
    └── widgets/           # Reusable UI components
```

---

## 🎯 Layer Responsibilities

### 📦 **Data Layer** (`data/`)

**Purpose**: Handle external data sources (APIs, databases)

#### `data/models/`
- **Contains**: API DTOs (Data Transfer Objects)
- **Must have**: `@JsonSerializable` annotations, `fromJson`/`toJson` methods
- **Examples**: `OrderItemRequest`, `CreateOrderRequest`, `OrderResponse`
- **❌ Forbidden**: Business logic, UI formatting, Flutter imports

```dart
// ✅ CORRECT - data/models/order_requests.dart
@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;
  final String name;
  @JsonKey(name: 'delivery_date')
  final String deliveryDate;
  @JsonKey(name: 'order_items')
  final List<OrderItemRequest> orderItems;

  const CreateOrderRequest({
    required this.customerId,
    required this.name,
    required this.deliveryDate,
    required this.orderItems,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}
```

#### `data/services/`
- **Contains**: API communication services
- **Must do**: Make HTTP requests, handle responses, use DTOs
- **Examples**: `OrderService` for API calls
- **❌ Forbidden**: Business logic, UI state management

```dart
// ✅ CORRECT - data/services/order_service.dart
class OrderService extends BaseService {
  Future<ApiResponse<List<OrderResponse>>> getOrders({int page = 1, int pageSize = 10}) async {
    return await executeRequest(() => get('${AppConstants.ordersEndpoint}?page=$page&page_size=$pageSize'), (json) {
      if (json is List<dynamic>) {
        return json.map((orderJson) => OrderResponse.fromJson(orderJson)).toList();
      }
      throw Exception('Invalid response format');
    });
  }

  Future<ApiResponse<MessageData>> createOrder({required CreateOrderRequest request}) async {
    return await executeRequest(
      () => post(AppConstants.ordersEndpoint, data: request.toJson()),
      (json) => MessageData.fromJson(json as Map<String, dynamic>),
    );
  }
}
```

### 🎨 **Presentation Layer** (`presentation/`)

**Purpose**: UI logic, state management, and business logic coordination

#### `presentation/models/`
- **Contains**: FormModels (mutable form state) and ViewModels (display formatting)
- **Must do**: Handle UI state, format data for display, manage form controllers
- **Examples**: `OrderCreationFormViewModel`, `OrderViewModel`
- **❌ Forbidden**: API serialization, direct business calculations

```dart
// ✅ CORRECT - presentation/models/order_form_models.dart
class OrderCreationFormViewModel {
  String? customerId;
  String? name;
  String? deliveryDate;
  List<OrderItemCreationFormViewModel>? orderItems;
  String? specialInstruction;

  OrderCreationFormViewModel({
    this.customerId,
    this.name,
    this.deliveryDate,
    this.orderItems,
    this.specialInstruction,
  });

  /// Check if the form is valid
  bool get isValid {
    return customerId != null &&
        customerId!.isNotEmpty &&
        name != null &&
        name!.isNotEmpty &&
        deliveryDate != null &&
        deliveryDate!.isNotEmpty &&
        orderItems != null &&
        orderItems!.isNotEmpty &&
        orderItems!.every((item) => item.isValid);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    if (customerId == null || customerId!.isEmpty) {
      errors.add('Customer is required');
    }
    if (name == null || name!.isEmpty) {
      errors.add('Order name is required');
    }
    return errors;
  }
}
```

#### `presentation/services/`
- **Contains**: Business logic, data conversion, and coordination between data and presentation
- **Must do**: Convert between data and presentation models, perform business calculations
- **Examples**: `OrderMapperService`, `OrderPriceCalculatorService`
- **❌ Forbidden**: UI state management, direct API calls

```dart
// ✅ CORRECT - presentation/services/order_mapper_service.dart
class OrderMapperService {
  /// Convert order creation form to request DTO
  static CreateOrderRequest orderCreationFormToRequest(OrderCreationFormViewModel formModel) {
    final orderItems = formModel.orderItems?.map((item) => orderItemCreationFormToRequest(item)).toList() ?? [];

    return CreateOrderRequest(
      customerId: formModel.customerId!,
      name: formModel.name!,
      deliveryDate: formModel.deliveryDate!,
      orderItems: orderItems,
    );
  }

  /// Convert API response to view model
  static OrderViewModel orderResponseToViewModel(OrderResponse responseModel) {
    return OrderViewModel(
      id: responseModel.id,
      name: responseModel.name,
      customerId: responseModel.customerId,
      staffId: responseModel.staffId,
      orderDate: DateTime.parse(responseModel.orderDate),
      deliveryDate: DateTime.parse(responseModel.deliveryDate),
      orderStatus: responseModel.orderStatus,
      specialInstruction: responseModel.specialInstruction,
      orderItems: responseModel.orderItems.map((item) => orderItemResponseToViewModel(item)).toList(),
    );
  }
}
```

#### `presentation/validators/`
- **Contains**: UI-specific validations and business rule validations
- **Must do**: Validate form fields, check UI state, enforce business rules
- **Examples**: Required field validation, format checking, business constraints
- **❌ Forbidden**: API calls, state management

```dart
// ✅ CORRECT - presentation/validators/order_validators.dart
class OrderValidators {
  static ValidationResult validateBarcode(String barcode) {
    if (barcode.trim().isEmpty) {
      return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
    }
    return ValidationResult.success();
  }

  static ValidationResult validateQuantity(int quantity, int availableStock) {
    if (quantity <= 0) {
      return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
    }
    if (quantity > availableStock) {
      return ValidationResult.failureSingle('quantity', 'Quantity exceeds available stock');
    }
    return ValidationResult.success();
  }

  static ValidationResult validateDiscountAmount(double discountAmount, double maxDiscount) {
    if (discountAmount > maxDiscount) {
      return ValidationResult.failureSingle('discount', 
          'Discount cannot exceed ₹${maxDiscount.toStringAsFixed(2)}');
    }
    return ValidationResult.success();
  }
}
```

#### `presentation/providers/`
- **Contains**: State management and coordination
- **Must do**: Manage form state, call data services, handle UI updates, coordinate business logic
- **Examples**: `OrderProvider`
- **❌ Forbidden**: Direct business calculations, API serialization

```dart
// ✅ CORRECT - presentation/providers/order_provider.dart
class OrderProvider extends BaseProvider {
  final OrderService _orderService = OrderService();
  final OrderCreationFormViewModel _orderCreationForm = OrderCreationFormViewModel(orderItems: []);

  // Getters for form data
  List<OrderItemCreationFormViewModel> get orderItems => _orderCreationForm.orderItems ?? [];
  String? get selectedCustomerId => _orderCreationForm.customerId;
  String? get orderName => _orderCreationForm.name;
  String? get deliveryDate => _orderCreationForm.deliveryDate;

  // Order creation methods
  void addOrderItem(OrderItemCreationFormViewModel item) {
    _orderCreationForm.orderItems!.add(item);
    notifyListeners();
  }

  void setOrderName(String orderName) {
    _orderCreationForm.name = orderName;
    notifyListeners();
  }

  void setDeliveryDate(String deliveryDate) {
    _orderCreationForm.deliveryDate = deliveryDate;
    notifyListeners();
  }

  Future<bool> createOrder() async {
    try {
      setLoading(true);
      clearMessages();

      // Validate form
      if (!_orderCreationForm.isValid) {
        setError(_orderCreationForm.validationErrors.first);
        return false;
      }

      // Convert to API request
      final request = OrderMapperService.orderCreationFormToRequest(_orderCreationForm);
      final response = await _orderService.createOrder(request: request);

      if (response.success) {
        setSuccess('Order created successfully');
        reset();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to create order');
        return false;
      }
    } catch (e) {
      setError('Error creating order: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> fetchOrders({int page = 1, int pageSize = 10}) async {
    try {
      setLoading(true);
      clearMessages();

      final response = await _orderService.getOrders(page: page, pageSize: pageSize);

      if (response.success) {
        _orders.clear();
        // Convert API responses to view models
        final orderViewModels = (response.data ?? []).map((orderResponse) => 
            OrderMapperService.orderResponseToViewModel(orderResponse)).toList();
        _orders.addAll(orderViewModels);
        _pagination = response.pagination;
        notifyListeners();
        return true;
      } else {
        setError(response.error?.message ?? 'Failed to fetch orders');
        return false;
      }
    } catch (e) {
      setError('Error fetching orders: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  @override
  void reset() {
    _orderCreationForm.orderItems?.clear();
    _orderCreationForm.orderItems ??= [];
    _orderCreationForm.customerId = null;
    _orderCreationForm.name = null;
    _orderCreationForm.deliveryDate = null;
    _orderCreationForm.specialInstruction = null;
    super.reset();
  }
}
```

---

## 🔁 Layer Communication Flow

### **Data Flow Pattern**

```
UI Form → FormModel → RequestDTO → API
API Response → ResponseDTO → ViewModel → UI Display
```

### **Detailed Flow Example**

1. **User Input** → `OrderCreationFormViewModel` (presentation)
2. **Form Validation** → `OrderValidators.validateBarcode()` (presentation)
3. **Convert to API** → `OrderMapperService.orderCreationFormToRequest()` (presentation)
4. **API Call** → `OrderService.createOrder()` (data)
5. **Response Processing** → `OrderMapperService.orderResponseToViewModel()` (presentation)
6. **UI Update** → `OrderViewModel` (presentation)

### **Conversion Points**

```dart
// FormModel → RequestDTO
CreateOrderRequest request = OrderMapperService.orderCreationFormToRequest(formModel);

// ResponseDTO → ViewModel
OrderViewModel viewModel = OrderMapperService.orderResponseToViewModel(response);

// Business calculations in presentation services
double totalAmount = OrderPriceCalculatorService.calculateOrderTotal(orderItems, cardDetails);
```

---

## 💡 File-Level Use Cases

### **Data Layer Files**

#### `data/models/order_requests.dart`
- **Role**: API DTO for order creation
- **Can import**: Other data models, JSON annotation
- **Cannot import**: Presentation models, Flutter packages
- **Usage**: API serialization/deserialization
- **Anti-pattern**: Adding business logic or UI formatting

#### `data/services/order_service.dart`
- **Role**: API communication for orders
- **Can import**: Data models, HTTP client, base service
- **Cannot import**: Presentation models
- **Usage**: Making HTTP requests to order endpoints
- **Anti-pattern**: Business logic, state management

### **Presentation Layer Files**

#### `presentation/models/order_form_models.dart`
- **Role**: Form state management
- **Can import**: Validation abstractions
- **Cannot import**: Data models, Flutter packages
- **Usage**: Form validation, state management
- **Anti-pattern**: API serialization, business calculations

#### `presentation/services/order_mapper_service.dart`
- **Role**: Convert between data and presentation models
- **Can import**: Data models, presentation models
- **Cannot import**: Flutter packages
- **Usage**: API response processing, request preparation
- **Anti-pattern**: UI formatting, state management

#### `presentation/validators/order_validators.dart`
- **Role**: Validation logic (UI and business rules)
- **Can import**: Validation abstractions
- **Cannot import**: Data models, presentation models
- **Usage**: Form validation, business rule enforcement
- **Anti-pattern**: API calls, state management

#### `presentation/providers/order_provider.dart`
- **Role**: State management and coordination
- **Can import**: All layers (with proper conversion)
- **Cannot import**: Direct cross-layer usage
- **Usage**: Manage UI state, coordinate between layers
- **Anti-pattern**: Direct business logic, API serialization

---

## ✅ Naming Conventions

### **Data Layer**
- **DTOs**: `*_requests.dart`, `*_responses.dart`
- **Services**: `*_service.dart`

### **Presentation Layer**
- **Form Models**: `*_form_models.dart`
- **View Models**: `*_view_models.dart`
- **Validators**: `*_validators.dart`
- **Services**: `*_mapper_service.dart`, `*_calculator_service.dart`
- **Providers**: `*_provider.dart`

---

## 🧪 Validation System

### **Shared Validation Abstractions**

```dart
// lib/core/validation/validation_result.dart
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  
  factory ValidationResult.success() => ValidationResult._(isValid: true, errors: []);
  factory ValidationResult.failure(List<ValidationError> errors) => 
      ValidationResult._(isValid: false, errors: errors);
}
```

### **Presentation Validators** (`presentation/validators/`)
- **Purpose**: UI-specific and business rule validations
- **Returns**: `ValidationResult`
- **Examples**: Required fields, format validation, business constraints

```dart
class OrderValidators {
  static ValidationResult validateBarcode(String barcode) {
    if (barcode.trim().isEmpty) {
      return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
    }
    return ValidationResult.success();
  }

  static ValidationResult validateDiscountAmount(double discountAmount, double maxDiscount) {
    if (discountAmount > maxDiscount) {
      return ValidationResult.failureSingle('discount', 
          'Discount cannot exceed ₹${maxDiscount.toStringAsFixed(2)}');
    }
    return ValidationResult.success();
  }
}
```

### **Provider Integration**

```dart
// In OrderProvider
void searchCardByBarcode(String barcode) async {
  // UI validation
  final barcodeResult = OrderValidators.validateBarcode(barcode);
  if (!barcodeResult.isValid) {
    setError(barcodeResult.firstMessage);
    return;
  }
  
  // Business validation
  final cardNotInOrderResult = OrderValidators.validateCardNotInOrder(
      barcode, _orderItems);
  if (!cardNotInOrderResult.isValid) {
    setError(cardNotInOrderResult.firstMessage);
    return;
  }
  
  // Proceed with API call
}
```

---

## ⚠️ Edge Cases & Guidance

### **ViewModels with Formatting Logic**
- **✅ Acceptable**: Minor formatting in presentation models
- **❌ Unacceptable**: Business calculations in presentation

```dart
// ✅ CORRECT - Formatting in ViewModel
class OrderItemViewModel {
  final String formattedPrice;
  
  factory OrderItemViewModel.fromApiModel(OrderItemResponse apiModel) {
    return OrderItemViewModel(
      formattedPrice: '₹${apiModel.pricePerItem}',
    );
  }
}

// ❌ WRONG - Business logic in ViewModel
class OrderItemViewModel {
  double calculateTotal() { // Business logic belongs in services
    return price * quantity + tax;
  }
}
```

### **Business Logic Location**
- **Presentation Services**: Business calculations, data conversion
- **Providers**: State management, coordination
- **ViewModels**: UI formatting only

### **Cross-Layer Usage**
- **✅ Correct**: Use mapper services for conversion
- **❌ Wrong**: Direct cross-layer model usage

```dart
// ✅ CORRECT
final request = OrderMapperService.orderCreationFormToRequest(formModel);
final viewModel = OrderMapperService.orderResponseToViewModel(apiResponse);

// ❌ WRONG
final viewModel = OrderItemViewModel.fromApiModel(apiItem); // Direct conversion
```

---

## 🔐 Forbidden Violations

### **Data Layer Violations**
```dart
// ❌ WRONG - data/models/order_requests.dart
import 'package:flutter/material.dart'; // No Flutter imports in data layer

class CreateOrderRequest {
  Widget buildWidget() { // No UI logic in data layer
    return Text('Order');
  }
}
```

### **Presentation Layer Violations**
```dart
// ❌ WRONG - presentation/models/order_form_models.dart
import 'package:json_annotation/json_annotation.dart'; // No JSON in presentation

@JsonSerializable() // Presentation models should not have JSON annotations
class OrderCreationFormViewModel {
  // ...
}
```

### **Cross-Feature Violations**
```dart
// ❌ WRONG - presentation/services/order_mapper_service.dart
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
// Should use data models or interfaces instead
```

---

## 🏁 Conclusion

### **Key Principles**
1. **Dependency Rule**: Presentation layer can depend on data layer, but not vice versa
2. **No Horizontal Imports**: Features should not import other features' presentation models
3. **Conversion Required**: Use mapper services for cross-layer data flow
4. **Separation of Concerns**: Business logic in presentation services, UI logic in presentation models

### **Maintenance Checklist**
- [ ] No Flutter imports in data layer
- [ ] No JSON annotations in presentation models
- [ ] No business logic in view models
- [ ] Use ValidationResult for all validations
- [ ] Convert between layers using mapper services
- [ ] Keep cross-feature dependencies minimal

### **Onboarding New Developers**
1. Read this guide before making changes
2. Follow the naming conventions
3. Use the validation system consistently
4. When in doubt, ask: "Does this belong in this layer?"

---

> **Remember**: Clean Architecture with Data and Presentation layers is about making your code testable, maintainable, and scalable. Each layer has a specific responsibility, and violating these boundaries makes the code harder to understand and modify. 