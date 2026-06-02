// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userAppointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAppointmentModel _$UserAppointmentModelFromJson(
        Map<String, dynamic> json) =>
    UserAppointmentModel(
      AID: json['AID'] as String?,
      Address: json['Address'] as String?,
      City: json['City'] as String?,
      Description: json['Description'] as String?,
      District: json['District'] as String?,
      Email: json['Email'] as String?,
      Mobile: json['Mobile'] as String?,
      NIC: json['NIC'] as String?,
      Name: json['Name'] as String?,
      ProfileImage: json['ProfileImage'] as String?,
      RequestedDate: json['RequestedDate'] as String?,
      ScheduledDate: json['ScheduledDate'] as String?,
      Status: json['Status'] as String?,
      Type: json['Type'] as String?,
    );

Map<String, dynamic> _$UserAppointmentModelToJson(
        UserAppointmentModel instance) =>
    <String, dynamic>{
      'AID': instance.AID,
      'Address': instance.Address,
      'City': instance.City,
      'Description': instance.Description,
      'District': instance.District,
      'Email': instance.Email,
      'Mobile': instance.Mobile,
      'NIC': instance.NIC,
      'Name': instance.Name,
      'ProfileImage': instance.ProfileImage,
      'RequestedDate': instance.RequestedDate,
      'ScheduledDate': instance.ScheduledDate,
      'Status': instance.Status,
      'Type': instance.Type,
    };
