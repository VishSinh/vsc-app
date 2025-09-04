import 'dart:async';
import 'package:vsc_app/core/utils/app_logger.dart';

/// Base class for all application events
abstract class AppEvent {}

/// Event emitted when a card is deleted
class CardDeletedEvent extends AppEvent {
  final String cardId;

  CardDeletedEvent(this.cardId);

  @override
  String toString() => 'CardDeletedEvent(cardId: $cardId)';
}

/// Event emitted when a card is updated
class CardUpdatedEvent extends AppEvent {
  final String cardId;

  CardUpdatedEvent(this.cardId);

  @override
  String toString() => 'CardUpdatedEvent(cardId: $cardId)';
}

/// Event emitted when a card is created
class CardCreatedEvent extends AppEvent {
  final String cardId;

  CardCreatedEvent(this.cardId);

  @override
  String toString() => 'CardCreatedEvent(cardId: $cardId)';
}

/// Global event bus service for decoupled communication between providers
///
/// This service allows providers to communicate without direct dependencies,
/// making the code more maintainable and testable.
class EventBusService {
  static final EventBusService _instance = EventBusService._internal();
  factory EventBusService() => _instance;
  EventBusService._internal();

  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();

  /// Stream of all events
  Stream<AppEvent> get events => _eventController.stream;

  /// Stream of specific event type
  Stream<T> eventsOfType<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  /// Emit an event to all subscribers
  void emit(AppEvent event) {
    AppLogger.service('EventBusService', 'Emitting event: ${event.toString()}');
    _eventController.add(event);
  }

  /// Check if there are any active listeners
  bool get hasListeners => _eventController.hasListener;

  /// Dispose the service (typically called when app is closing)
  void dispose() {
    AppLogger.service('EventBusService', 'Disposing event bus service');
    _eventController.close();
  }
}
