
import 'package:firebase_database/firebase_database.dart';

import 'baseService.dart';

class UserService {

  Future<bool> login(String nic, String password) async {

      final databaseRef = FirebaseDatabase.instance.ref();

      try {
        var response =
        databaseRef.child('/PublicUsers/All/').child(nic).child('Password');
        DatabaseEvent event = await response.once();
        print(event.snapshot.value);
        print("/////////////////////////////////");

        if (password == event.snapshot.value) {
          print("Account Validation Done");
          return true;
        } else {
          print("Account Validation Fail");
          return false;
        }
      } catch (e) {
        print(e);
        return false;

      }
    }
  }




