import 'package:json_annotation/json_annotation.dart';

part 'policeAppointment.g.dart';

@JsonSerializable()
class PoliceAppointmentModel {
  PoliceAppointmentModel({
    this.AIDP,
    this.City,
    this.Email,
    this.Mobile,
    this.NIC,
    this.ScheduledDate,
    this.Status,
    this.Type
  });

  String? AIDP;
  String? City;
  String? Email;
  String? Mobile;
  String? NIC;
  String? ScheduledDate;
  String? Status;
  String? Type;

  factory PoliceAppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$PoliceAppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PoliceAppointmentModelToJson(this);
}
