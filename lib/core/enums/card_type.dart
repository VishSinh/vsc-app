import 'package:flutter/material.dart';

/// Card type enum and helpers (mirrors backend TextChoices)
enum CardType {
  single,
  birthday,
  mundan,
  carryBag,
  threeFold,
  fiveFold,
  envelope11x5,
  envelope9x7,
  jumbo,
  box,
  padding,
  urduEnvelope11x5,
  urduEnvelope9x7,
  urduCarryBag,
  urduJumbo,
  urduBox,
  urduPadding,
}

extension CardTypeExtension on CardType {
  /// Convert enum to API string
  String toApiString() {
    switch (this) {
      case CardType.single:
        return 'SINGLE';
      case CardType.birthday:
        return 'BIRTHDAY';
      case CardType.mundan:
        return 'MUNDAN';
      case CardType.carryBag:
        return 'CARRY_BAG';
      case CardType.threeFold:
        return 'THREE_FOLD';
      case CardType.fiveFold:
        return 'FIVE_FOLD';
      case CardType.envelope11x5:
        return 'ENVELOPE_11X5';
      case CardType.envelope9x7:
        return 'ENVELOPE_9X7';
      case CardType.jumbo:
        return 'JUMBO';
      case CardType.box:
        return 'BOX';
      case CardType.padding:
        return 'PADDING';
      case CardType.urduEnvelope11x5:
        return 'URDU_ENVELOPE_11X5';
      case CardType.urduEnvelope9x7:
        return 'URDU_ENVELOPE_9X7';
      case CardType.urduCarryBag:
        return 'URDU_CARRY_BAG';
      case CardType.urduJumbo:
        return 'URDU_JUMBO';
      case CardType.urduBox:
        return 'URDU_BOX';
      case CardType.urduPadding:
        return 'URDU_PADDING';
    }
  }

  /// Human-friendly display text
  String get displayText {
    switch (this) {
      case CardType.single:
        return 'Single';
      case CardType.birthday:
        return 'Birthday';
      case CardType.mundan:
        return 'Mundan';
      case CardType.carryBag:
        return 'CarryBag';
      case CardType.threeFold:
        return 'ThreeFold';
      case CardType.fiveFold:
        return 'FiveFold';
      case CardType.envelope11x5:
        return 'Envelope11x5';
      case CardType.envelope9x7:
        return 'Envelope9x7';
      case CardType.jumbo:
        return 'Jumbo';
      case CardType.box:
        return 'Box';
      case CardType.padding:
        return 'Padding';
      case CardType.urduEnvelope11x5:
        return 'UrduEnvelope11x5';
      case CardType.urduEnvelope9x7:
        return 'UrduEnvelope9x7';
      case CardType.urduCarryBag:
        return 'UrduCarryBag';
      case CardType.urduJumbo:
        return 'UrduJumbo';
      case CardType.urduBox:
        return 'UrduBox';
      case CardType.urduPadding:
        return 'UrduPadding';
    }
  }

  /// Optional color for UI badges
  Color get color {
    switch (this) {
      case CardType.single:
        return Colors.blueGrey;
      case CardType.birthday:
        return Colors.pink;
      case CardType.mundan:
        return Colors.brown;
      case CardType.carryBag:
        return Colors.teal;
      case CardType.threeFold:
        return Colors.indigo;
      case CardType.fiveFold:
        return Colors.deepPurple;
      case CardType.envelope11x5:
        return Colors.blue;
      case CardType.envelope9x7:
        return Colors.lightBlue;
      case CardType.jumbo:
        return Colors.orange;
      case CardType.box:
        return Colors.green;
      case CardType.padding:
        return Colors.grey;
      case CardType.urduEnvelope11x5:
        return Colors.blueAccent;
      case CardType.urduEnvelope9x7:
        return Colors.cyan;
      case CardType.urduCarryBag:
        return Colors.tealAccent;
      case CardType.urduJumbo:
        return Colors.deepOrange;
      case CardType.urduBox:
        return Colors.greenAccent;
      case CardType.urduPadding:
        return Colors.grey;
    }
  }

  /// Parse enum from API string
  static CardType? fromApiString(String? apiString) {
    if (apiString == null) return null;
    switch (apiString.toUpperCase()) {
      case 'SINGLE':
        return CardType.single;
      case 'BIRTHDAY':
        return CardType.birthday;
      case 'MUNDAN':
        return CardType.mundan;
      case 'CARRY_BAG':
        return CardType.carryBag;
      case 'THREE_FOLD':
        return CardType.threeFold;
      case 'FIVE_FOLD':
        return CardType.fiveFold;
      case 'ENVELOPE_11X5':
        return CardType.envelope11x5;
      case 'ENVELOPE_9X7':
        return CardType.envelope9x7;
      case 'JUMBO':
        return CardType.jumbo;
      case 'BOX':
        return CardType.box;
      case 'PADDING':
        return CardType.padding;
      case 'URDU_ENVELOPE_11X5':
        return CardType.urduEnvelope11x5;
      case 'URDU_ENVELOPE_9X7':
        return CardType.urduEnvelope9x7;
      case 'URDU_CARRY_BAG':
        return CardType.urduCarryBag;
      case 'URDU_JUMBO':
        return CardType.urduJumbo;
      case 'URDU_BOX':
        return CardType.urduBox;
      case 'URDU_PADDING':
        return CardType.urduPadding;
      default:
        return null;
    }
  }
}
