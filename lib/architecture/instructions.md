# Clean Architecture Rules

## ✅ ALLOWED

- Converting a presentation model to a domain model via a Mapper located in the domain layer is correct and not a violation
- If it's pure UI representation, you can map directly between models in presentation/models/
- Domain layer can import both data models and presentation models for conversion purposes
- Presentation layer can import domain models and domain services
- Data layer can import other data models and HTTP/JSON packages
- Cross-feature imports of shared services (logging, validation, permissions) are acceptable

## ❌ FORBIDDEN

- Direct import of data models in presentation layer (must go through domain)
- Direct import of API services in presentation layer (must go through domain)
- Business logic in presentation models (belongs in domain services)
- UI formatting in domain models (belongs in presentation models)
- Flutter imports in data layer
- JSON annotations in domain models
- Direct cross-feature imports of presentation models (use domain models instead)
- Direct cross-feature imports of data models (use domain models instead)

## 🔄 CONVERSION FLOWS

- FormModel → DomainModel → RequestDTO (via mapper)
- ResponseDTO → DomainModel → ViewModel (via mapper)
- PresentationModel → PresentationModel (direct, same layer)
- DomainModel → DomainModel (direct, same layer)

## 📝 NAMING

- Data: `*_requests.dart`, `*_responses.dart`, `*_service.dart`
- Domain: `*_service.dart`, `*_mapper_service.dart`, `*_validators.dart`
- Presentation: `*_form_models.dart`, `*_view_models.dart`, `*_provider.dart` 