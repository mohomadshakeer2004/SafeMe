// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      Name: json['Name'] as String?,
      Address: json['Address'] as String?,
      City: json['City'] as String?,
      District: json['District'] as String?,
      Email: json['Email'] as String?,
      Mobile: json['Mobile'] as String?,
      NIC: json['NIC'] as String?,
      Password: json['Password'] as String?,
      ProfileImage: json['ProfileImage'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'Name': instance.Name,
      'Address': instance.Address,
      'City': instance.City,
      'District': instance.District,
      'Email': instance.Email,
      'Mobile': instance.Mobile,
      'NIC': instance.NIC,
      'Password': instance.Password,
      'ProfileImage': instance.ProfileImage,
    };
