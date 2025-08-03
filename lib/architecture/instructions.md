# Clean Architecture and Coding Standards

## setState Usage

- Do not use `setState` in any widget.
  - If the widget needs local state, use a Provider (ChangeNotifier).
    - Move the provider class to its own file in `presentation/providers/`.
  - If the state comes from the parent, pass it down via constructor along with callbacks.

## Loading Indicators

- Use `DoubleBounce` from `flutter_spinkit` for any loading state UI.

## Project Architecture

This project uses a simplified 2-layer architecture:

### 1. Data Layer

- Location: `features/<module>/data/`
- Responsibility: Handles all API interactions and data transfer models.
- Includes:
  - Request models (`*_requests.dart`)
  - Response models (`*_responses.dart`)
  - API services (`*_api_service.dart`)

### 2. Presentation Layer

- Location: `features/<module>/presentation/`
- Responsibility: Handles all UI logic, state management, and UI-specific models.
- Includes:
  - Form models (`*_form_models.dart`)
  - View models (`*_view_models.dart`)
  - Providers (`*_provider.dart`)
  - Pages
  - Reusable widgets
  - Services - Validtors, helpers, services

## Data Flow Guidelines

- Form flow: FormModel → validated → converted to RequestModel → passed to API service
- Fetch flow: ResponseModel → converted to ViewModel → used in UI
- Conversions within the same layer (e.g., between two presentation models) can be done directly.

## Cross-Feature Rules

- You can use API services and view models from other modules.
- Do not use providers from other modules to prevent shared state conflicts.
- Each feature should manage its own state independently.
- If an API from another module is needed, call the service method directly from your own provider.

## Validation Guidelines

- All form validation must reside in the presentation layer.
- Validation logic **should not** be written inside Providers.
- Simple validations can be placed inside FormModels directly.
- For validations that require access to multiple FormModel fields or other contextual logic, create a dedicated file in:
  - `presentation/services/<feature>_validator.dart`

## Business Logic and Calculations in Presentation

- Presentation-specific calculations or lightweight business rules can exist in:
  - `presentation/services/<feature>_service.dart`  
  - `presentation/services/<feature>_calculation.dart`
- These may include:
  - Price calculations
  - Cross-field logic checks
  - Local decision making for UI before API submission
- These services must not contain side-effects or mutate state. They should be pure functions.

## Form → API Preparation

- ViewModels or FormModels may contain conversion methods **only if** they have all the necessary data internally.
- Otherwise, offload conversion or computation to services mentioned above.


## UI Component Rules

- UI widgets should be stateless and free of business logic.
- Any state used by a widget should come from a Provider.
- Avoid duplicating logic across widgets—extract shared behavior into utilities or models.

## File Naming

- `*_requests.dart` → API request DTOs
- `*_responses.dart` → API response DTOs
- `*_api_service.dart` → Service class with API calls
- `*_form_models.dart` → Models bound to input forms
- `*_view_models.dart` → Models for formatting UI display
- `*_provider.dart` → State management for a feature or page
- `*_validators.dart` → Input or business validation logic

