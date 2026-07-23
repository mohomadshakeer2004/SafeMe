import 'package:flutter/material.dart';

/// Sri Lanka's 25 districts with major cities/towns.
/// City lists always end with [otherLabel] ("Other").
class SriLankaLocations {
  static const String otherLabel = 'Other';

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

  /// Major cities / DS-division towns by district.
  static const Map<String, List<String>> citiesByDistrict = {
    'Ampara': [
      'Ampara',
      'Akkaraipattu',
      'Kalmunai',
      'Sainthamaruthu',
      'Sammanthurai',
      'Pottuvil',
      'Uhana',
      'Dehiattakandiya',
      'Lahugala',
      'Mahaoya',
    ],
    'Anuradhapura': [
      'Anuradhapura',
      'Kekirawa',
      'Thambuttegama',
      'Medawachchiya',
      'Nochchiyagama',
      'Habarana',
      'Galenbindunuwewa',
      'Mihintale',
      'Horowpothana',
      'Eppawala',
    ],
    'Badulla': [
      'Badulla',
      'Bandarawela',
      'Haputale',
      'Ella',
      'Welimada',
      'Mahiyanganaya',
      'Passara',
      'Hali Ela',
      'Diyatalawa',
      'Sorabora',
    ],
    'Batticaloa': [
      'Batticaloa',
      'Eravur',
      'Kattankudy',
      'Valaichchenai',
      'Chenkalady',
      'Oddamavadi',
      'Kalkudah',
      'Vakarai',
      'Manmunai',
      'Kiran',
    ],
    'Colombo': [
      'Colombo',
      'Dehiwala',
      'Mount Lavinia',
      'Moratuwa',
      'Sri Jayawardenepura Kotte',
      'Maharagama',
      'Nugegoda',
      'Kaduwela',
      'Kolonnawa',
      'Kesbewa',
      'Homagama',
      'Piliyandala',
      'Battaramulla',
      'Rajagiriya',
      'Wellampitiya',
    ],
    'Galle': [
      'Galle',
      'Hikkaduwa',
      'Ambalangoda',
      'Elpitiya',
      'Baddegama',
      'Ahangama',
      'Unawatuna',
      'Karapitiya',
      'Balapitiya',
      'Bentota',
      'Habaraduwa',
    ],
    'Gampaha': [
      'Gampaha',
      'Negombo',
      'Ja-Ela',
      'Wattala',
      'Kelaniya',
      'Kadawatha',
      'Minuwangoda',
      'Veyangoda',
      'Nittambuwa',
      'Attanagalla',
      'Ragama',
      'Seeduwa',
      'Kiribathgoda',
      'Divulapitiya',
    ],
    'Hambantota': [
      'Hambantota',
      'Tangalle',
      'Tissamaharama',
      'Ambalantota',
      'Beliatta',
      'Weeraketiya',
      'Sooriyawewa',
      'Walasmulla',
      'Kataragama',
      'Lunugamvehera',
    ],
    'Jaffna': [
      'Jaffna',
      'Nallur',
      'Chavakachcheri',
      'Point Pedro',
      'Karainagar',
      'Kayts',
      'Velanai',
      'Kopay',
      'Tellippalai',
      'Kankesanthurai',
    ],
    'Kalutara': [
      'Kalutara',
      'Panadura',
      'Horana',
      'Beruwala',
      'Aluthgama',
      'Matugama',
      'Bandaragama',
      'Wadduwa',
      'Ingiriya',
      'Bulathsinhala',
      'Agalawatta',
    ],
    'Kandy': [
      'Kandy',
      'Peradeniya',
      'Katugastota',
      'Gampola',
      'Nawalapitiya',
      'Akurana',
      'Pilimatalawa',
      'Wattegama',
      'Kadugannawa',
      'Gelioya',
      'Digana',
      'Kundasale',
    ],
    'Kegalle': [
      'Kegalle',
      'Mawanella',
      'Warakapola',
      'Rambukkana',
      'Ruwanwella',
      'Galigamuwa',
      'Dehiowita',
      'Deraniyagala',
      'Yatiyantota',
      'Bulathkohupitiya',
    ],
    'Kilinochchi': [
      'Kilinochchi',
      'Pallai',
      'Poonakary',
      'Kandavalai',
      'Karachchi',
      'Paranthan',
      'Elephant Pass',
    ],
    'Kurunegala': [
      'Kurunegala',
      'Kuliyapitiya',
      'Narammala',
      'Pannala',
      'Wariyapola',
      'Mawathagama',
      'Polgahawela',
      'Alawwa',
      'Nikaweratiya',
      'Giriulla',
      'Ibbagamuwa',
      'Bingiriya',
    ],
    'Mannar': [
      'Mannar',
      'Nanattan',
      'Musali',
      'Madhu',
      'Pesalai',
      'Thalaimannar',
      'Murunkan',
    ],
    'Matale': [
      'Matale',
      'Dambulla',
      'Sigiriya',
      'Galewela',
      'Ukuwela',
      'Rattota',
      'Pallepola',
      'Naula',
      'Yatawatta',
      'Wilgamuwa',
    ],
    'Matara': [
      'Matara',
      'Weligama',
      'Akuressa',
      'Hakmana',
      'Kamburupitiya',
      'Dikwella',
      'Mirissa',
      'Deniyaya',
      'Kottegoda',
      'Devinuwara',
    ],
    'Monaragala': [
      'Monaragala',
      'Wellawaya',
      'Bibile',
      'Buttala',
      'Kataragama',
      'Siyambalanduwa',
      'Medagama',
      'Thanamalwila',
      'Sewanagala',
    ],
    'Mullaitivu': [
      'Mullaitivu',
      'Oddusuddan',
      'Puthukkudiyiruppu',
      'Maritimepattu',
      'Thunukkai',
      'Manthai East',
      'Weli Oya',
    ],
    'Nuwara Eliya': [
      'Nuwara Eliya',
      'Hatton',
      'Maskeliya',
      'Talawakele',
      'Ginigathhena',
      'Ragala',
      'Walapane',
      'Kotagala',
      'Pundaluoya',
      'Nanu Oya',
    ],
    'Polonnaruwa': [
      'Polonnaruwa',
      'Kaduruwela',
      'Hingurakgoda',
      'Medirigiriya',
      'Dimbulagala',
      'Lankapura',
      'Elahera',
      'Welikanda',
      'Giritale',
    ],
    'Puttalam': [
      'Puttalam',
      'Chilaw',
      'Wennappuwa',
      'Nattandiya',
      'Marawila',
      'Dankotuwa',
      'Anamaduwa',
      'Kalpitiya',
      'Madampe',
      'Pallama',
    ],
    'Ratnapura': [
      'Ratnapura',
      'Embilipitiya',
      'Balangoda',
      'Eheliyagoda',
      'Kuruwita',
      'Pelmadulla',
      'Kalawana',
      'Godakawela',
      'Kahawatta',
      'Nivithigala',
    ],
    'Trincomalee': [
      'Trincomalee',
      'Kinniya',
      'Kantale',
      'Mutur',
      'Nilaveli',
      'China Bay',
      'Kuchchaveli',
      'Serunuwara',
      'Gomarankadawala',
      'Thampalagamam',
    ],
    'Vavuniya': [
      'Vavuniya',
      'Nedunkeni',
      'Cheddikulam',
      'Omanthai',
      'Vavuniya South',
      'Vengalacheddikulam',
      'Settikulam',
    ],
  };

  /// Flat list kept for legacy callers — prefer [citiesForDistrict].
  static List<String> get cities {
    final set = <String>{};
    for (final list in citiesByDistrict.values) {
      set.addAll(list);
    }
    final sorted = set.toList()..sort();
    if (!sorted.contains(otherLabel)) {
      sorted.add(otherLabel);
    } else {
      sorted.remove(otherLabel);
      sorted.add(otherLabel);
    }
    return sorted;
  }

  /// Cities for a district, always ending with "Other". Empty if no district yet.
  static List<String> citiesForDistrict(String? district) {
    if (district == null || district.isEmpty) return const [];
    final base = List<String>.from(citiesByDistrict[district] ?? const []);
    if (!base.contains(otherLabel)) {
      base.add(otherLabel);
    }
    return base;
  }

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
