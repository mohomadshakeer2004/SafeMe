import 'package:json_annotation/json_annotation.dart';

part 'complaint.g.dart';

@JsonSerializable()
class ComplaintModel {
  ComplaintModel({
    this.CID,
    this.Address,
    this.City,
    this.Date,
    this.Description,
    this.District,
    this.Email,
    this.Image1,
    this.Image2,
    this.Latitude,
    this.Longitude,
    this.Mobile,
    this.NIC,
    this.Name,
    this.ProfileImage,
    this.Reason,
    this.Status,
    this.Type
  });

  String? CID;
  String? Address;
  String? City;
  String? Date;
  String? Description;
  String? District;
  String? Email;
  String? Image1;
  String? Image2;
  String? Latitude;
  String? Longitude;
  String? Mobile;
  String? NIC;
  String? Name;
  String? ProfileImage;
  String? Reason;
  String? Status;
  String? Type;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) =>
      _$ComplaintModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComplaintModelToJson(this);
}

//flutter pub run build_runner watch --delete-conflicting-outputs