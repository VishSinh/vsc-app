# 🏗️ Clean Architecture Guide - Orders Feature

> **Purpose**: This guide helps developers understand and maintain Clean Architecture principles in the orders feature.

## 📁 Folder Structure & Responsibilities

```
lib/features/orders/
├── data/                    # External data layer (API, Database)
│   ├── models/             # API DTOs and serialization
│   └── services/           # Network/API communication
├── domain/                 # Business logic layer (pure Dart)
│   ├── models/            # Business entities
│   ├── services/          # Business logic and rules
│   └── validators/        # Business rule validations
└── presentation/           # UI layer (Flutter-specific)
    ├── models/            # Form and View models
    ├── pages/             # UI screens
    ├── providers/         # State management
    ├── validators/        # UI-specific validations
    └── widgets/           # Reusable UI components
```

---

## 🎯 Layer Responsibilities

### 📦 **Data Layer** (`data/`)

**Purpose**: Handle external data sources (APIs, databases)

#### `data/models/`
- **Contains**: API DTOs (Data Transfer Objects)
- **Must have**: `@JsonSerializable` annotations, `fromJson`/`toJson` methods
- **Examples**: `OrderItemApiModel`, `CreateOrderRequest`, `OrderResponse`
- **❌ Forbidden**: Business logic, UI formatting, Flutter imports

```dart
// ✅ CORRECT - data/models/order_api_models.dart
@JsonSerializable()
class OrderItemApiModel {
  @JsonKey(name: 'card_id')
  final String cardId;
  final int quantity;
  
  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) => 
      _$OrderItemApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemApiModelToJson(this);
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
  Future<ApiResponse<List<OrderResponse>>> getOrders() async {
    return await executeRequest(() => get('/orders'), (json) {
      return json.map((orderJson) => OrderResponse.fromJson(orderJson)).toList();
    });
  }
}
```

### 🏗️ **Domain Layer** (`domain/`)

**Purpose**: Pure business logic (no Flutter dependencies)

**Note**: Domain models should be pure data containers with direct field access. Avoid property access methods as they add unnecessary complexity. Business logic belongs in domain services.

#### `domain/models/`
- **Contains**: Pure business entities
- **Must have**: Immutable data, direct field access, no UI dependencies
- **Examples**: `Order`, `OrderItem`
- **❌ Forbidden**: `@JsonSerializable`, `TextEditingController`, Flutter imports, business calculations, property access methods

```dart
// ✅ CORRECT - domain/models/order.dart
class Order {
  final String id;
  final String customerId;
  final DateTime deliveryDate;
  final List<OrderItem> orderItems;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.orderItems,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  /// Create a copy with updated values
  Order copyWith({
    String? id,
    String? customerId,
    DateTime? deliveryDate,
    List<OrderItem>? orderItems,
    OrderStatus? status,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderItems: orderItems ?? this.orderItems,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ✅ CORRECT - Direct field access
final itemCount = order.orderItems.length;
final hasItems = order.orderItems.isNotEmpty;
```

#### `domain/services/`
- **Contains**: Business logic and domain rules
- **Must do**: Calculate totals, validate business rules, convert between layers
- **Examples**: `OrderPriceCalculatorService`, `OrderMapperService`
- **❌ Forbidden**: UI logic, API calls, presentation models

```dart
// ✅ CORRECT - domain/services/order_price_calculator_service.dart
class OrderPriceCalculatorService {
  /// Calculates total discount for an order
  double calculateTotalDiscount(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.discountAmount * item.quantity);
  }

  /// Calculates total additional costs (box + printing)
  double calculateTotalAdditionalCosts(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.boxCost + item.printingCost);
  }

  /// Validates if order is valid for submission
  bool validateOrderSubmission(Order order) {
    return order.customerId.isNotEmpty && 
           order.orderItems.isNotEmpty && 
           order.deliveryDate.isAfter(DateTime.now());
  }

  /// Calculates order total from list of domain items
  double calculateOrderTotal(List<OrderItem> items, Map<String, CardViewModel> cardDetails) {
    return items.fold(0.0, (total, item) => 
        total + calculateLineItemTotal(item, cardDetails[item.cardId]));
  }
}
```

#### `domain/validators/`
- **Contains**: Business rule validations
- **Must return**: `ValidationResult` or `Either<ValidationFailure, DomainModel>`
- **Examples**: Quantity validation, discount limits, business constraints
- **❌ Forbidden**: UI messages, form field validation

```dart
// ✅ CORRECT - domain/validators/order_validators.dart
class OrderDomainValidators {
  static ValidationResult validateQuantity(int quantity, int availableStock) {
    if (quantity <= 0) {
      return ValidationResult.failureSingle('quantity', 'Quantity must be greater than 0');
    }
    if (quantity > availableStock) {
      return ValidationResult.failureSingle('quantity', 'Quantity exceeds available stock');
    }
    return ValidationResult.success();
  }
}
```

### 🎨 **Presentation Layer** (`presentation/`)

**Purpose**: UI logic and state management

#### `presentation/models/`
- **Contains**: FormModels (mutable form state) and ViewModels (display formatting)
- **Must do**: Handle UI state, format data for display, manage form controllers
- **Examples**: `OrderItemFormViewModel`, `OrderItemViewModel`
- **❌ Forbidden**: Business logic, API serialization

```dart
// ✅ CORRECT - presentation/models/order_view_models.dart
class OrderItemViewModel {
  final String formattedDiscountAmount;
  final String formattedLineTotal;
  
  factory OrderItemViewModel.fromDomainModel(OrderItem domainModel, CardResponse card) {
    final lineTotal = domainModel.calculateLineTotal(card.sellPriceAsDouble);
    return OrderItemViewModel(
      formattedDiscountAmount: '₹${domainModel.discountAmount.toStringAsFixed(2)}',
      formattedLineTotal: '₹${lineTotal.toStringAsFixed(2)}',
    );
  }
}
```

#### `presentation/validators/`
- **Contains**: UI-specific validations
- **Must do**: Validate form fields, check UI state
- **Examples**: Required field validation, format checking
- **❌ Forbidden**: Business rule validation

```dart
// ✅ CORRECT - presentation/validators/order_validators.dart
class OrderValidators {
  static ValidationResult validateBarcode(String barcode) {
    if (barcode.trim().isEmpty) {
      return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
    }
    return ValidationResult.success();
  }
}
```

#### `presentation/providers/`
- **Contains**: State management and coordination
- **Must do**: Manage form state, call domain services, handle UI updates
- **Examples**: `OrderProvider`
- **❌ Forbidden**: Direct business logic, API calls

```dart
// ✅ CORRECT - presentation/providers/order_provider.dart
class OrderProvider extends BaseProvider {
  final OrderPriceCalculatorService _priceCalculator = OrderPriceCalculatorService();

  void addOrderItem(OrderItemFormViewModel formModel) {
    // Convert form model to domain model
    final domainItem = formModel.toDomainModel();
    
    // Validate business rules
    final validation = domain.OrderDomainValidators.validateOrderItem(domainItem, availableStock);
    if (!validation.isValid) {
      setError(validation.firstMessage);
      return;
    }
    
    // Calculate business logic using service
    final totalDiscount = _priceCalculator.calculateTotalDiscount([domainItem]);
    final totalAdditionalCosts = _priceCalculator.calculateTotalAdditionalCosts([domainItem]);
    
    // Check domain model fields directly
    if (domainItem.quantity <= 0) {
      setError('Quantity must be greater than 0');
      return;
    }
    
    // Add to order items
    _orderItems.add(OrderItemViewModel.fromDomainModel(domainItem, _currentCard));
    notifyListeners();
  }
}
```

---

## 🔁 Layer Communication Flow

### **Data Flow Pattern**

```
UI Form → FormModel → DomainModel → RequestDTO → API
API Response → ResponseDTO → DomainModel → ViewModel → UI Display
```

### **Detailed Flow Example**

1. **User Input** → `OrderItemFormViewModel` (presentation)
2. **Form Validation** → `OrderValidators.validateBarcode()` (presentation)
3. **Convert to Domain** → `formModel.toDomainModel()` (presentation)
4. **Business Validation** → `OrderDomainValidators.validateOrderItem()` (domain)
5. **Business Logic** → `OrderPriceCalculatorService.calculateLineItemTotal()` (domain)
6. **Convert to API** → `OrderMapperService.toApiModel()` (domain)
7. **API Call** → `OrderService.createOrder()` (data)
8. **Response Processing** → `OrderMapperService.fromApiResponse()` (domain)
9. **UI Update** → `OrderItemViewModel.fromDomainModel()` (presentation)

### **Conversion Points**

```dart
// FormModel → DomainModel
OrderItem domainItem = formModel.toDomainModel();

// DomainModel → RequestDTO
CreateOrderRequest request = OrderMapperService.toApiRequest(order);

// ResponseDTO → DomainModel
Order order = OrderMapperService.fromApiResponse(response);

// DomainModel → ViewModel
OrderItemViewModel viewModel = OrderItemViewModel.fromDomainModel(domainItem, card);
```

---

## 💡 File-Level Use Cases

### **Data Layer Files**

#### `data/models/order_api_models.dart`
- **Role**: API DTO for order items
- **Can import**: Other data models, JSON annotation
- **Cannot import**: Domain models, presentation models, Flutter packages
- **Usage**: API serialization/deserialization
- **Anti-pattern**: Adding business logic or UI formatting

#### `data/services/order_service.dart`
- **Role**: API communication for orders
- **Can import**: Data models, HTTP client, base service
- **Cannot import**: Domain services, presentation models
- **Usage**: Making HTTP requests to order endpoints
- **Anti-pattern**: Business logic, state management

### **Domain Layer Files**

#### `domain/models/order.dart`
- **Role**: Pure business entity
- **Can import**: Other domain models
- **Cannot import**: Data models, presentation models, Flutter packages
- **Usage**: Data representation, direct field access
- **Anti-pattern**: JSON annotations, UI state, business calculations, property access methods

#### `domain/services/order_mapper_service.dart`
- **Role**: Convert between data and domain models
- **Can import**: Data models, domain models
- **Cannot import**: Presentation models
- **Usage**: API response processing, request preparation
- **Anti-pattern**: UI formatting, business logic

#### `domain/validators/order_validators.dart`
- **Role**: Business rule validation
- **Can import**: Domain models, validation abstractions
- **Cannot import**: Data models, presentation models
- **Usage**: Enforce business constraints
- **Anti-pattern**: UI messages, form validation

### **Presentation Layer Files**

#### `presentation/models/order_view_models.dart`
- **Role**: UI display formatting
- **Can import**: Domain models, data models (for conversion)
- **Cannot import**: Domain services
- **Usage**: Format data for UI display
- **Anti-pattern**: Business logic, API calls

#### `presentation/providers/order_provider.dart`
- **Role**: State management and coordination
- **Can import**: All layers (with proper conversion)
- **Cannot import**: Direct cross-layer usage
- **Usage**: Manage UI state, coordinate between layers
- **Anti-pattern**: Direct business logic, API calls

---

## ✅ Naming Conventions

### **Data Layer**
- **DTOs**: `*_api_models.dart`, `*_requests.dart`, `*_responses.dart`
- **Services**: `*_service.dart`

### **Domain Layer**
- **Models**: Pure nouns (`order.dart`, `order_item.dart`)
- **Services**: `*_service.dart`, `*_mapper_service.dart`
- **Validators**: `*_validators.dart`

### **Presentation Layer**
- **Form Models**: `*_form_models.dart`, `*_form_view_model.dart`
- **View Models**: `*_view_models.dart`, `*_view_model.dart`
- **Validators**: `*_validators.dart`
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

### **Domain Validators** (`domain/validators/`)
- **Purpose**: Business rule enforcement
- **Returns**: `ValidationResult`
- **Examples**: Quantity limits, discount constraints, business rules

```dart
static ValidationResult validateDiscountAmount(double discountAmount, double maxDiscount) {
  if (discountAmount > maxDiscount) {
    return ValidationResult.failureSingle('discount', 
        'Discount cannot exceed ₹${maxDiscount.toStringAsFixed(2)}');
  }
  return ValidationResult.success();
}
```

### **Presentation Validators** (`presentation/validators/`)
- **Purpose**: UI-specific validation
- **Returns**: `ValidationResult`
- **Examples**: Required fields, format validation, UI state checks

```dart
static ValidationResult validateBarcode(String barcode) {
  if (barcode.trim().isEmpty) {
    return ValidationResult.failureSingle('barcode', 'Please enter a barcode');
  }
  return ValidationResult.success();
}
```

### **Provider Integration**

```dart
// In OrderProvider
void searchCardByBarcode(String barcode) async {
  // UI validation
  final barcodeResult = presentation.OrderValidators.validateBarcode(barcode);
  if (!barcodeResult.isValid) {
    setError(barcodeResult.firstMessage);
    return;
  }
  
  // Business validation
  final cardNotInOrderResult = domain.OrderDomainValidators.validateCardNotInOrder(
      barcode, _domainOrderItems);
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
  
  factory OrderItemViewModel.fromDomainModel(OrderItem item) {
    return OrderItemViewModel(
      formattedPrice: '₹${item.price.toStringAsFixed(2)}',
    );
  }
}

// ❌ WRONG - Business logic in ViewModel
class OrderItemViewModel {
  double calculateTotal() { // Business logic belongs in domain
    return price * quantity + tax;
  }
}
```

### **Derived Fields**
- **Domain Models**: Direct field access only (e.g., `order.orderItems.length`)
- **Domain Services**: Business calculations (totals, discounts, validation)
- **ViewModels**: UI formatting only

### **Cross-Layer Usage**
- **✅ Correct**: Use mapper services for conversion
- **❌ Wrong**: Direct cross-layer model usage

```dart
// ✅ CORRECT
final domainItem = OrderMapperService.fromApiModel(apiItem);
final viewModel = OrderItemViewModel.fromDomainModel(domainItem);

// ❌ WRONG
final viewModel = OrderItemViewModel.fromApiModel(apiItem); // Direct conversion
```

---

## 🔐 Forbidden Violations

### **Data Layer Violations**
```dart
// ❌ WRONG - data/models/order.dart
import 'package:flutter/material.dart'; // No Flutter imports in data layer

class OrderApiModel {
  Widget buildWidget() { // No UI logic in data layer
    return Text('Order');
  }
}
```

### **Domain Layer Violations**
```dart
// ❌ WRONG - domain/models/order.dart
import 'package:json_annotation/json_annotation.dart'; // No JSON in domain

@JsonSerializable() // Domain models should be pure
class Order {
  // ...
}
```

### **Presentation Layer Violations**
```dart
// ❌ WRONG - presentation/models/order_view_models.dart
class OrderViewModel {
  double calculateBusinessTotal() { // No business logic in presentation
    return items.fold(0.0, (sum, item) => sum + item.price);
  }
}
```

### **Cross-Feature Violations**
```dart
// ❌ WRONG - domain/services/order_price_calculator_service.dart
import 'package:vsc_app/features/cards/presentation/models/card_view_models.dart';
// Should use domain models or interfaces instead
```

---

## 🏁 Conclusion

### **Key Principles**
1. **Dependency Rule**: Each layer can only depend on the layer below
2. **No Horizontal Imports**: Features should not import other features' presentation models
3. **Conversion Required**: Use mapper services for cross-layer data flow
4. **Separation of Concerns**: Business logic in domain, UI logic in presentation

### **Maintenance Checklist**
- [ ] No Flutter imports in data layer
- [ ] No JSON annotations in domain models
- [ ] No business logic in presentation models
- [ ] Use ValidationResult for all validations
- [ ] Convert between layers using mapper services
- [ ] Keep cross-feature dependencies minimal

### **Onboarding New Developers**
1. Read this guide before making changes
2. Follow the naming conventions
3. Use the validation system consistently
4. When in doubt, ask: "Does this belong in this layer?"

---

> **Remember**: Clean Architecture is about making your code testable, maintainable, and scalable. Each layer has a specific responsibility, and violating these boundaries makes the code harder to understand and modify. 