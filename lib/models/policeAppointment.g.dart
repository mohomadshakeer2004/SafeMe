// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policeAppointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoliceAppointmentModel _$PoliceAppointmentModelFromJson(
        Map<String, dynamic> json) =>
    PoliceAppointmentModel(
      AIDP: json['AIDP'] as String?,
      City: json['City'] as String?,
      Email: json['Email'] as String?,
      Mobile: json['Mobile'] as String?,
      NIC: json['NIC'] as String?,
      ScheduledDate: json['ScheduledDate'] as String?,
      Status: json['Status'] as String?,
      Type: json['Type'] as String?,
    );

Map<String, dynamic> _$PoliceAppointmentModelToJson(
        PoliceAppointmentModel instance) =>
    <String, dynamic>{
      'AIDP': instance.AIDP,
      'City': instance.City,
      'Email': instance.Email,
      'Mobile': instance.Mobile,
      'NIC': instance.NIC,
      'ScheduledDate': instance.ScheduledDate,
      'Status': instance.Status,
      'Type': instance.Type,
    };
