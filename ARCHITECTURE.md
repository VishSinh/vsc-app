# 🏗️ VSC App Architecture Documentation

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture Principles](#architecture-principles)
- [Directory Structure](#directory-structure)
- [Layer Separation](#layer-separation)
- [Feature Organization](#feature-organization)
- [Data Flow](#data-flow)
- [State Management](#state-management)
- [API Communication](#api-communication)
- [Validation & Business Logic](#validation--business-logic)
- [UI Patterns](#ui-patterns)
- [Conventions & Standards](#conventions--standards)

## 🎯 Overview

This Flutter application follows **Clean Architecture** principles with **Domain-Driven Design (DDD)** and **MVVM (Model-View-ViewModel)** patterns. The architecture emphasizes:

- **Separation of Concerns**: Clear boundaries between data, domain, and presentation layers
- **Feature-First Organization**: Code organized by business features rather than technical layers
- **Testability**: Business logic isolated from UI and external dependencies
- **Maintainability**: Clear data flow and dependency direction
- **Scalability**: Modular structure that supports team development

## 🏛️ Architecture Principles

### **Clean Architecture Layers**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Pages     │  │  Widgets    │  │  Providers  │       │
│  │             │  │             │  │ (ViewModels)│       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Services   │  │ Validators  │  │   Models    │       │
│  │ (Business)  │  │             │  │ (ViewModels)│       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Services   │  │   Models    │  │  Repositories│       │
│  │   (API)     │  │ (API/DB)   │  │             │       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### **Dependency Direction**
- **Presentation** → **Domain** → **Data**
- **Inner layers** never depend on **outer layers**
- **Dependencies** point **inward**

## 📁 Directory Structure

```
lib/
├── app/                          # App-level configuration
│   ├── app_config.dart          # App-wide configuration
│   ├── app_router.dart          # Navigation setup
│   └── app_theme.dart           # Theme configuration
│
├── core/                         # Shared infrastructure
│   ├── constants/               # App-wide constants
│   ├── enums/                   # Shared enums
│   ├── models/                  # Shared data models
│   ├── providers/               # Base providers
│   ├── services/                # Shared services
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Shared UI components
│
└── features/                    # Feature modules
    ├── auth/                    # Authentication feature
    │   ├── data/
    │   │   └── models/         # API request/response models
    │   ├── domain/
    │   │   └── services/       # Business logic services
    │   └── presentation/
    │       ├── models/         # UI-specific models (ViewModels)
    │       ├── pages/          # Screen widgets
    │       ├── providers/      # State management
    │       ├── validators/     # Input validation
    │       └── widgets/        # Feature-specific UI components
    │
    ├── orders/                  # Order management feature
    │   ├── data/
    │   │   └── models/         # Order API models
    │   ├── domain/
    │   │   └── services/       # Order business logic
    │   └── presentation/
    │       ├── models/         # Order ViewModels
    │       ├── pages/          # Order screens
    │       ├── providers/      # Order state management
    │       ├── validators/     # Order validation
    │       └── widgets/        # Order UI components
    │
    ├── cards/                   # Card management feature
    │   ├── data/
    │   │   └── models/         # Card API models
    │   ├── domain/
    │   │   └── services/       # Card business logic
    │   └── presentation/
    │       ├── models/         # Card ViewModels
    │       ├── pages/          # Card screens
    │       ├── providers/      # Card state management
    │       ├── validators/     # Card validation
    │       └── widgets/        # Card UI components
    │
    └── [other_features]/        # Additional features...
```

## 🏗️ Layer Separation

### **1. Data Layer (`data/`)**
**Purpose**: Handle external data sources (APIs, databases)

**Components**:
- **API Models**: Request/Response models for backend communication
- **API Services**: HTTP client services for API calls
- **Repositories**: Data access abstraction (future)

**Example**:
```dart
// lib/features/cards/data/models/card_responses.dart
@JsonSerializable()
class CardResponse {
  final String id;
  final String sellPrice;
  final String costPrice;
  // ... API-specific fields
}

// lib/core/services/card_service.dart
class CardService extends BaseService {
  Future<ApiResponse<List<CardResponse>>> getCards() async {
    // API communication logic
  }
}
```

### **2. Domain Layer (`domain/`)**
**Purpose**: Core business logic and rules

**Components**:
- **Business Services**: Core business operations
- **Validators**: Input validation logic
- **Domain Models**: Business entities (future)

**Example**:
```dart
// lib/features/cards/domain/services/card_business_service.dart
class CardBusinessService {
  double calculateProfitMargin(double sellPrice, double costPrice) {
    return sellPrice > 0 ? ((sellPrice - costPrice) / sellPrice) * 100 : 0.0;
  }
}

// lib/features/cards/presentation/validators/card_validators.dart
class CardValidators {
  static String? validateCostPrice(String costPrice) {
    // Validation logic
  }
}
```

### **3. Presentation Layer (`presentation/`)**
**Purpose**: UI logic and state management

**Components**:
- **ViewModels**: UI-specific data models
- **Providers**: State management (MVVM ViewModels)
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components

**Example**:
```dart
// lib/features/cards/presentation/models/card_view_models.dart
class CardViewModel {
  final String formattedSellPrice;
  final double profitMargin;
  // ... UI-specific computed properties
  
  factory CardViewModel.fromApiModel(CardResponse apiModel) {
    // Convert API model to UI model
  }
}

// lib/features/cards/presentation/providers/card_provider.dart
class CardProvider extends BaseProvider with AutoSnackBarMixin {
  List<CardViewModel> _cards = [];
  // ... state management
}
```

## 🎯 Feature Organization

### **Feature Structure**
Each feature follows the same internal structure:

```
feature_name/
├── data/
│   └── models/
│       ├── feature_requests.dart    # API request models
│       ├── feature_responses.dart   # API response models
│       └── feature_api_models.dart  # Additional API models
├── domain/
│   └── services/
│       └── feature_business_service.dart  # Business logic
└── presentation/
    ├── models/
    │   ├── feature_view_models.dart    # UI models
    │   ├── feature_form_models.dart    # Form state models
    │   └── feature_item_form_data.dart # Simple form data
    ├── pages/
    │   ├── feature_list_page.dart      # List screens
    │   ├── feature_detail_page.dart    # Detail screens
    │   └── feature_create_page.dart    # Creation screens
    ├── providers/
    │   └── feature_provider.dart       # State management
    ├── validators/
    │   └── feature_validators.dart     # Input validation
    └── widgets/
        ├── feature_card.dart           # Reusable widgets
        ├── feature_form.dart           # Form widgets
        └── feature_list_item.dart      # List item widgets
```

### **Cross-Feature Dependencies**
- **Features** can depend on **core** utilities
- **Features** should **NOT** depend on other features directly
- **Shared logic** goes in **core** layer

## 🔄 Data Flow

### **Typical Data Flow Pattern**

```
1. User Action (UI)
   ↓
2. Provider Method Call
   ↓
3. Business Service (Domain Logic)
   ↓
4. API Service (Data Layer)
   ↓
5. Backend API
   ↓
6. API Response (Data Layer)
   ↓
7. Convert to ViewModel (Presentation)
   ↓
8. Update UI State
   ↓
9. UI Rebuild
```

### **Example: Card Creation Flow**

```dart
// 1. User submits form
CardEntryForm(onSubmit: () => cardProvider.createCard())

// 2. Provider delegates to business service
class CardProvider {
  Future<void> createCard() async {
    final validationError = _cardBusinessService.validateCardForm(formModel);
    if (validationError != null) {
      setError(validationError);
      return;
    }
    
    final response = await _cardService.createCard(request);
    if (response.success) {
      setSuccess('Card created successfully');
    }
  }
}

// 3. Business service handles validation
class CardBusinessService {
  String? validateCardForm(CardFormViewModel formModel) {
    return CardValidators.validateCardForm(formModel);
  }
}

// 4. API service handles HTTP communication
class CardService extends BaseService {
  Future<ApiResponse<MessageData>> createCard(CreateCardRequest request) async {
    return await uploadMultipart(/* ... */);
  }
}
```

## 🎛️ State Management

### **Provider Pattern (MVVM)**
- **Providers** act as **ViewModels** in MVVM pattern
- **State** is managed through **ChangeNotifier**
- **UI** observes state changes and rebuilds

### **Base Provider Architecture**
```dart
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _success;
  BuildContext? _context;

  // Common state management methods
  void setLoading(bool loading);
  void setError(String? error);
  void setSuccess(String? success);
  void setContext(BuildContext context);
}
```

### **AutoSnackBar Mixin**
```dart
mixin AutoSnackBarMixin on BaseProvider {
  @override
  void setError(String? error) {
    super.setError(error);
    if (error != null && _context != null) {
      SnackBarUtils.showError(_context!, error);
    }
  }
}
```

### **Feature Provider Example**
```dart
class CardProvider extends BaseProvider with AutoSnackBarMixin {
  final CardService _cardService = CardService();
  final CardBusinessService _cardBusinessService = CardBusinessService();
  
  List<CardViewModel> _cards = [];
  CardFormViewModel _formModel = CardFormViewModel.empty();
  
  // Getters
  List<CardViewModel> get cards => _cards;
  CardFormViewModel get formModel => _formModel;
  
  // Methods
  Future<void> loadCards() async {
    setLoading(true);
    final response = await _cardService.getCards();
    if (response.success) {
      _cards = response.data!.map((api) => CardViewModel.fromApiModel(api)).toList();
    } else {
      setError(response.error?.message);
    }
    setLoading(false);
    notifyListeners();
  }
}
```

## 🌐 API Communication

### **Base Service Pattern**
```dart
abstract class BaseService {
  final Dio _dio;
  
  // Common HTTP methods
  Future<ApiResponse<T>> get<T>(String path, {T Function(Map<String, dynamic>)? fromJson});
  Future<ApiResponse<T>> post<T>(String path, {dynamic data, T Function(Map<String, dynamic>)? fromJson});
  Future<ApiResponse<T>> uploadMultipart<T>({required String path, required Map<String, dynamic> fields, required Map<String, dynamic> files, required T Function(Map<String, dynamic>) fromJson});
}
```

### **API Response Wrapper**
```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ErrorData? error;
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJson) {
    // Parse API response
  }
}
```

### **Error Handling**
- **Centralized error handling** in `BaseService`
- **Automatic SnackBar display** via `AutoSnackBarMixin`
- **Consistent error format** across all features

## ✅ Validation & Business Logic

### **Validation Strategy**
- **Validators** are **pure functions** with no side effects
- **Validation logic** is **centralized** in feature-specific validator classes
- **Form validation** happens in **providers** before API calls

### **Business Logic Separation**
- **Business rules** live in **domain services**
- **Calculations** and **complex logic** are isolated from UI
- **Providers** coordinate between **UI**, **validation**, and **business logic**

### **Example Validation Pattern**
```dart
class CardValidators {
  static String? validateCostPrice(String costPrice) {
    if (costPrice.isEmpty) return 'Cost price is required';
    final price = double.tryParse(costPrice);
    if (price == null || price <= 0) return 'Please enter a valid cost price';
    return null;
  }
  
  static String? validateCardForm(CardFormViewModel formModel) {
    // Comprehensive form validation
  }
}
```

## 🎨 UI Patterns

### **Responsive Design**
- **ResponsiveLayout**: Adaptive layouts for different screen sizes
- **ResponsiveText**: Scalable text sizing
- **AppConfig**: Centralized sizing and spacing constants

### **Widget Organization**
- **Shared Widgets**: Reusable components in `core/widgets/`
- **Feature Widgets**: Feature-specific components in `features/*/presentation/widgets/`
- **Page Widgets**: Screen-specific components in `features/*/presentation/pages/`

### **Form Patterns**
- **FormModels**: State management for form inputs
- **Validators**: Input validation logic
- **AutoSnackBar**: Automatic error/success message display

### **List Patterns**
- **ViewModels**: UI-specific data models for list items
- **Card Widgets**: Reusable card components for list items
- **Pagination**: Load more functionality (future)

## 📋 Conventions & Standards

### **Naming Conventions**

#### **Models**
- **API Models**: `CardResponse`, `CreateCardRequest`, `LoginResponse`
- **ViewModels**: `CardViewModel`, `OrderItemViewModel`, `AuthViewModel`
- **Form Models**: `CardFormViewModel`, `LoginFormViewModel`

#### **Services**
- **API Services**: `CardService`, `OrderService`, `AuthService`
- **Business Services**: `CardBusinessService`, `OrderPriceCalculatorService`

#### **Files**
- **API Models**: `*_requests.dart`, `*_responses.dart`, `*_api_models.dart`
- **ViewModels**: `*_view_models.dart`, `*_form_models.dart`
- **Services**: `*_service.dart`, `*_business_service.dart`
- **Validators**: `*_validators.dart`

### **Import Conventions**
- **Absolute imports only**: `package:vsc_app/features/cards/...`
- **No relative imports**: ❌ `../models/card_view_models.dart`
- **Feature isolation**: Features don't import from other features

### **Code Organization**
- **One class per file** for models and services
- **Grouped classes** for related ViewModels
- **Clear separation** between API and UI models

### **Error Handling**
- **Consistent error format** via `ApiResponse<T>`
- **Automatic SnackBar** via `AutoSnackBarMixin`
- **User-friendly messages** in presentation layer

### **State Management**
- **Providers extend BaseProvider** for common functionality
- **AutoSnackBarMixin** for automatic error/success display
- **Context setting** for SnackBar display
- **Loading states** managed consistently

## 🚀 Benefits of This Architecture

### **1. Maintainability**
- **Clear separation** of concerns
- **Feature isolation** prevents coupling
- **Consistent patterns** across features

### **2. Testability**
- **Business logic** isolated from UI
- **Pure functions** for validation
- **Mockable dependencies** for unit testing

### **3. Scalability**
- **Feature teams** can work independently
- **New features** follow established patterns
- **Shared utilities** reduce duplication

### **4. Developer Experience**
- **Clear file organization** makes navigation easy
- **Consistent patterns** reduce cognitive load
- **Type safety** prevents runtime errors

### **5. Performance**
- **Efficient state management** with ChangeNotifier
- **Lazy loading** of features (future)
- **Optimized rebuilds** with granular state

## 🔮 Future Enhancements

### **Planned Improvements**
- **Repository Pattern**: Abstract data access layer
- **Dependency Injection**: IoC container for services
- **Unit Testing**: Comprehensive test coverage
- **Integration Testing**: End-to-end test scenarios
- **Performance Monitoring**: Analytics and profiling
- **Code Generation**: Build-time code generation for models

### **Architecture Evolution**
- **Micro-frontend**: Feature-based deployment (future)
- **Plugin System**: Extensible feature architecture
- **Multi-platform**: Shared business logic across platforms

---

*This architecture documentation is a living document that evolves with the project. Updates are made as patterns emerge and best practices are established.* 