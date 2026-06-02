import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel {
  UserModel(
      {this.Name,
      this.Address,
      this.City,
      this.District,
      this.Email,
      this.Mobile,
      this.NIC,
      this.Password,
      this.ProfileImage});

  String? Name;
  String? Address;
  String? City;
  String? District;
  String? Email;
  String? Mobile;
  String? NIC;
  String? Password;
  String? ProfileImage;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
