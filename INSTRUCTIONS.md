# Development Instructions & Clean Architecture Guidelines

This document outlines the key development principles, architecture, and standards that should be followed when working on this project. These guidelines ensure code quality, maintainability, and consistency across the codebase.

## Project Architecture

This project uses a simplified 2-layer architecture:

### 1. Data Layer
- **Location**: `features/<module>/data/`
- **Responsibility**: Handles all API interactions and data transfer models
- **Includes**:
  - Request models (`*_requests.dart`)
  - Response models (`*_responses.dart`) 
  - API services (`*_service.dart`)

### 2. Presentation Layer
- **Location**: `features/<module>/presentation/`
- **Responsibility**: Handles all UI logic, state management, and UI-specific models
- **Includes**:
  - Form models (`*_form_models.dart`)
  - View models (`*_view_models.dart`)
  - Providers (`*_provider.dart`)
  - Pages
  - Reusable widgets
  - Services - Validators, helpers, calculation services

## Data Flow Guidelines

- **Form flow**: FormModel → validated → converted to RequestModel → passed to API service
- **Fetch flow**: ResponseModel → converted to ViewModel → used in UI
- **Conversions** within the same layer (e.g., between two presentation models) can be done directly

## State Management & UI Development

### State Management
- **No setState**: Do not use `setState` in any widget
  - If the widget needs local state, use a Provider (ChangeNotifier)
    - Move the provider class to its own file in `presentation/providers/`
  - If the state comes from the parent, pass it down via constructor along with callbacks

### Separation of Concerns
- **Never embed business logic in UI files**: All business logic (API calls, data transformation, validation) should be delegated to controllers, viewmodels, or services
- **UI widgets should be stateless** and free of business logic
- **Any state used by a widget** should come from a Provider

### Responsive Design
- **Every screen must be responsive**: Use appropriate layouts for different screen sizes:
  - Desktop: sidebars, tables, and modals
  - Mobile: cards, bottom sheets, or list views
- **Tablet Full Screen Mode**: Tablets automatically enter immersive full screen mode (like games) hiding system UI for a distraction-free experience. Users can temporarily reveal system UI by swiping from screen edges.

### UI Standards
- **Follow design system standards**: UI components must adhere to the established design system, using shared:
  - Styles
  - Colors
  - Typography
  - Spacing
  - Layout tokens

### Loading States
- **Use DoubleBounce**: Use `DoubleBounce` from `flutter_spinkit` for any loading state UI
- **Use standard loading patterns**:
  - LoadingWidget use only from shared_widgets.dart

## Validation & Business Logic

### Validation Guidelines
- All form validation must reside in the presentation layer
- Validation logic **should not** be written inside Providers
- Simple validations can be placed inside FormModels directly
- For validations that require access to multiple FormModel fields or other contextual logic, create a dedicated file in:
  - `presentation/services/<feature>_validator.dart`

### Business Logic and Calculations
- Presentation-specific calculations or lightweight business rules can exist in:
  - `presentation/services/<feature>_service.dart`  
  - `presentation/services/<feature>_calculation.dart`
- These may include:
  - Price calculations
  - Cross-field logic checks
  - Local decision making for UI before API submission
- These services must not contain side-effects or mutate state. They should be pure functions.

## Cross-Feature Rules

- You can use API services and view models from other modules
- Do not use providers from other modules to prevent shared state conflicts
- Each feature should manage its own state independently
- If an API from another module is needed, call the service method directly from your own provider

## Code Quality & Reusability

### Code Reusability
- **Reuse existing models and enums**: Always reuse existing models, enums, and services when applicable; avoid redefining shared domain entities
- **Check before creating new components**: Always check for existing constants, utils, enums, or components before creating new ones to prevent redundancy and improve maintainability
- **Avoid code duplication**: Extract repeated logic into feature-level or core-level utils depending on usage scope

### Constants
- **Extract all hardcoded values**: Never hardcode strings, numbers, durations, or booleans — move them to constants; create a new one if no suitable constant exists

### Comments
- **Use meaningful comments only**: Add comments only when the logic is non-trivial or difficult to understand; avoid commenting self-explanatory code or restating what the code already makes clear

## File Naming Conventions

- `*_requests.dart` → API request DTOs
- `*_responses.dart` → API response DTOs
- `*_service.dart` → Service class with API calls
- `*_form_models.dart` → Models bound to input forms
- `*_view_models.dart` → Models for formatting UI display
- `*_provider.dart` → State management for a feature or page
- `*_validators.dart` → Input or business validation logic

## Best Practices Summary

1. Keep UI and business logic separate
2. Reuse existing components and models
3. Design responsive UIs for all screen sizes
4. Follow established design patterns and standards
5. Use appropriate loading indicators
6. Extract constants instead of hardcoding values
7. Add comments only when necessary for clarity
8. Check for existing implementations before creating new ones
9. Avoid duplicating code across the application
