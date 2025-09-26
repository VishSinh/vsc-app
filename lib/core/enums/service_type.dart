import 'package:flutter/material.dart';

/// Service type enum for service items in orders
enum ServiceType { digitalCard, abhinandanPatr, carPoster, digitalVisitingCard }

/// Extension utilities for ServiceType enum
extension ServiceTypeExtension on ServiceType {
  /// Convert enum to API string
  String toApiString() {
    switch (this) {
      case ServiceType.digitalCard:
        return 'DIGITAL_CARD';
      case ServiceType.abhinandanPatr:
        return 'ABHINANDAN_PATR';
      case ServiceType.carPoster:
        return 'CAR_POSTER';
      case ServiceType.digitalVisitingCard:
        return 'DIGITAL_VISITING_CARD';
    }
  }

  /// Human-friendly display text
  String get displayText {
    switch (this) {
      case ServiceType.digitalCard:
        return 'Digital Card';
      case ServiceType.abhinandanPatr:
        return 'Abhinandan Patr';
      case ServiceType.carPoster:
        return 'Car Poster';
      case ServiceType.digitalVisitingCard:
        return 'Digital Visiting Card';
    }
  }

  /// Parse enum from API string
  static ServiceType? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'DIGITAL_CARD':
        return ServiceType.digitalCard;
      case 'ABHINANDAN_PATR':
        return ServiceType.abhinandanPatr;
      case 'CAR_POSTER':
        return ServiceType.carPoster;
      case 'DIGITAL_VISITING_CARD':
        return ServiceType.digitalVisitingCard;
      default:
        return null;
    }
  }

  /// Optional color for UI badges
  Color get color {
    switch (this) {
      case ServiceType.digitalCard:
        return Colors.teal;
      case ServiceType.abhinandanPatr:
        return Colors.indigo;
      case ServiceType.carPoster:
        return Colors.deepOrange;
      case ServiceType.digitalVisitingCard:
        return Colors.purple;
    }
  }
}
