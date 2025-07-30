import 'package:flutter/material.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';

/// Centralized navigation configuration to eliminate duplication
class NavigationItems {
  /// Main navigation destinations used across the app
  static const List<NavigationDestination> mainDestinations = [
    NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard),
    NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders),
    NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory),
    NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production),
    NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration),
  ];

  /// Navigation destinations for pages that include vendors
  static const List<NavigationDestination> withVendorsDestinations = [
    NavigationDestination(icon: Icon(Icons.dashboard), label: UITextConstants.dashboard),
    NavigationDestination(icon: Icon(Icons.shopping_cart), label: UITextConstants.orders),
    NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.inventory),
    NavigationDestination(icon: Icon(Icons.print), label: UITextConstants.production),
    NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: UITextConstants.administration),
    NavigationDestination(icon: Icon(Icons.people), label: UITextConstants.vendors),
  ];

  /// Navigation destinations for cards/inventory pages
  static const List<NavigationDestination> cardsDestinations = [NavigationDestination(icon: Icon(Icons.inventory), label: UITextConstants.cards)];

  /// Get navigation destinations based on page type
  static List<NavigationDestination> getDestinations(NavigationType type) {
    switch (type) {
      case NavigationType.main:
        return mainDestinations;
      case NavigationType.withVendors:
        return withVendorsDestinations;
      case NavigationType.cards:
        return cardsDestinations;
    }
  }
}

/// Navigation types for different page contexts
enum NavigationType { main, withVendors, cards }
