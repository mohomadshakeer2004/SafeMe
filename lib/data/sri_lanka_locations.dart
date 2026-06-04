import 'package:flutter/material.dart';

/// Districts and cities for dropdowns (values must be unique).
class SriLankaLocations {
  static const List<String> districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  static const List<String> cities = [
    'Gampaha',
    'Veyangoda',
    'Minuwangoda',
    'Nittabuwa',
    'Aththnagalla',
    'Kaduwela',
    'Kolonnawa',
    'Maharagama',
    'Kesbewa',
    'Nugegoda',
    'Ahangama',
    'Ambalangoda',
    'Balapitiya',
  ];

  static List<DropdownMenuItem<String>> dropdownItems(List<String> values) {
    return values
        .map(
          (value) => DropdownMenuItem<String>(
            alignment: AlignmentDirectional.centerStart,
            value: value,
            child: Text(value),
          ),
        )
        .toList();
  }

  /// Returns [value] if it exists in [options], otherwise null (safe for dropdown value).
  static String? validOption(String? value, List<String> options) {
    if (value == null || value.isEmpty) return null;
    return options.contains(value) ? value : null;
  }
}
