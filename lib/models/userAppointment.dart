import 'package:json_annotation/json_annotation.dart';

part 'userAppointment.g.dart';

@JsonSerializable()
class UserAppointmentModel {
  UserAppointmentModel({
    this.AID,
    this.Address,
    this.City,
    this.Description,
    this.District,
    this.Email,
    this.Mobile,
    this.NIC,
    this.Name,
    this.ProfileImage,
    this.RequestedDate,
    this.ScheduledDate,
    this.Status,
    this.Type
  });

  String? AID;
  String? Address;
  String? City;
  String? Description;
  String? District;
  String? Email;
  String? Mobile;
  String? NIC;
  String? Name;
  String? ProfileImage;
  String? RequestedDate;
  String? ScheduledDate;
  String? Status;
  String? Type;

  factory UserAppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$UserAppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAppointmentModelToJson(this);
}
