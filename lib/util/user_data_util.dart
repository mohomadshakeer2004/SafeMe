/// Normalizes RTDB user maps — legacy records may omit NIC, Mobile, Address, etc.
class UserDataUtil {
  /// Old format: 9 digits + V/X. New format: 12 digits (e.g. 200405411177).
  static bool isValidNic(String value) {
    final nic = value.trim().toUpperCase();
    return RegExp(r'^(?:[0-9]{9}[VX]|[0-9]{12})$').hasMatch(nic);
  }

  static String normalizeNic(String value) => value.trim().toUpperCase();

  static String field(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value == null) return fallback;
    return value.toString();
  }

  static Map<String, dynamic> withDefaults(
    Map<String, dynamic> data,
    String nic,
  ) {
    return {
      ...data,
      'Name': field(data, 'Name'),
      'Email': field(data, 'Email'),
      'NIC': field(data, 'NIC', fallback: nic),
      'Mobile': field(data, 'Mobile'),
      'Address': field(data, 'Address'),
      'ProfileImage': field(data, 'ProfileImage'),
      'City': field(data, 'City'),
      'District': field(data, 'District'),
    };
  }

  static int mobileAsInt(Map<String, dynamic> data, {int fallback = 0}) {
    return int.tryParse(field(data, 'Mobile')) ?? fallback;
  }
}
