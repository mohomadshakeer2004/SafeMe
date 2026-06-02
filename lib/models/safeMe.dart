import 'package:json_annotation/json_annotation.dart';

part 'safeMe.g.dart';

@JsonSerializable()
class SafeMeModel {
  SafeMeModel(
      {this.SID,
      this.Address,
      this.AudioMP3,
      this.City,
      this.Date,
      this.District,
      this.Email,
      this.Image1,
      this.Image2,
      this.Image3,
      this.Image4,
      this.Image5,
      this.Latitude,
      this.Longitude,
      this.Mobile,
      this.NIC,
      this.Name,
      this.ProfileImage,
      this.Severity,
      this.Status});

  String? SID;
  String? Address;
  String? AudioMP3;
  String? City;
  String? Date;
  String? District;
  String? Email;
  String? Image1;
  String? Image2;
  String? Image3;
  String? Image4;
  String? Image5;
  String? Latitude;
  String? Longitude;
  String? Mobile;
  String? NIC;
  String? Name;
  String? ProfileImage;
  String? Severity;
  String? Status;

  factory SafeMeModel.fromJson(Map<String, dynamic> json) =>
      _$SafeMeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SafeMeModelToJson(this);
}
