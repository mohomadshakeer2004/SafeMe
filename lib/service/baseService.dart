import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../Screens/Login/LoginPage.dart';

class BaseService {
  // OAuthSecureStorage _authSecureStorage = OAuthSecureStorage();

  Future<Map<String, Object>> onDioError(dynamic error, BuildContext context) async {
    EasyLoading.dismiss();

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return {
            "status": false,
            "error": false,
            "message": "Request is cancelled",
          };

        case DioExceptionType.connectionTimeout:
          return {
            "status": false,
            "error": false,
            "message": "Connection Timeout",
          };

        case DioExceptionType.sendTimeout:
          return {
            "status": false,
            "error": false,
            "message": "Sending Timeout",
          };

        case DioExceptionType.receiveTimeout:
          return {
            "status": false,
            "error": false,
            "message": "Receiving Timeout",
          };

        case DioExceptionType.badResponse:
          {
            switch (error.response!.statusCode) {
              case 401:
                {
                  await logout();
                 // ExtendedNavigator.named('Base').replace(Routes.welcomeScreen);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)  =>  LoginPage(),));
                  return {
                    "status": false,
                    "error": false,
                    "message": "Can't authenticate. Please retry or check app updates.r",
                  };
                }

              case 403:
                {
                  await logout();
                  //ExtendedNavigator.named('Base').replace(Routes.welcomeScreen);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)  =>  LoginPage(),));
                  return {
                    "status": false,
                    "error": false,
                    "message": "Can't authenticate. Please retry or check app updates.",
                  };
                }

              case 400:
                await logout();

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
                return error.response!.data["hint"] == null
                    ? error.response!.data.toString()
                    : error.response!.data["hint"] == ""
                    ? "Username and Password mismatch."
                    : error.response!.data["hint"];

              case 500:
                return {
                  "status": false,
                  "message":
                  "You have encountered a server error. Please contact Us."
                };

              default:
                return {
                  "status": false,
                  "error": false,
                  "message": "Please check your connectivity."
                  // "message": error.response.data.toString(),
                };
            }
          }


        case DioExceptionType.unknown:
        // await logout();
        // ExtendedNavigator.named('Base').replace(Routes.loading);
          return {
            "status": false,
            "error": false,
            "message": "Please check your connectivity."
            // "message": error.error.toString(),
          };

        default:
          return {
            "status": false,
            "error": false,
            "message": "Please check your connectivity."
            // "message": error.message,
          };
      }
    }
    else {
      return {
        "status": false,
        "error": false,
        "message": error.toString()
        // "message": error.message,
      };
    }
  }

  Future<bool> logout() async {
    try {
   //   await _authSecureStorage.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
