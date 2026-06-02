// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplaintModel _$ComplaintModelFromJson(Map<String, dynamic> json) =>
    ComplaintModel(
      CID: json['CID'] as String?,
      Address: json['Address'] as String?,
      City: json['City'] as String?,
      Date: json['Date'] as String?,
      Description: json['Description'] as String?,
      District: json['District'] as String?,
      Email: json['Email'] as String?,
      Image1: json['Image1'] as String?,
      Image2: json['Image2'] as String?,
      Latitude: json['Latitude'] as String?,
      Longitude: json['Longitude'] as String?,
      Mobile: json['Mobile'] as String?,
      NIC: json['NIC'] as String?,
      Name: json['Name'] as String?,
      ProfileImage: json['ProfileImage'] as String?,
      Reason: json['Reason'] as String?,
      Status: json['Status'] as String?,
      Type: json['Type'] as String?,
    );

Map<String, dynamic> _$ComplaintModelToJson(ComplaintModel instance) =>
    <String, dynamic>{
      'CID': instance.CID,
      'Address': instance.Address,
      'City': instance.City,
      'Date': instance.Date,
      'Description': instance.Description,
      'District': instance.District,
      'Email': instance.Email,
      'Image1': instance.Image1,
      'Image2': instance.Image2,
      'Latitude': instance.Latitude,
      'Longitude': instance.Longitude,
      'Mobile': instance.Mobile,
      'NIC': instance.NIC,
      'Name': instance.Name,
      'ProfileImage': instance.ProfileImage,
      'Reason': instance.Reason,
      'Status': instance.Status,
      'Type': instance.Type,
    };
