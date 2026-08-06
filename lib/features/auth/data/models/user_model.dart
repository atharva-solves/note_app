//import pasckage "as" : to avoid naming collision btwn FB's User Class v/s your own class.
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:note_app/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity {

  UserModel({required super.id, required super.email,required super.phoneNumber});

  factory UserModel.fromFireBaseUser({required firebase.User firebaseUser,String? verifiedPhone}) {
    return UserModel(id: firebaseUser.uid, email: firebaseUser.email,phoneNumber: verifiedPhone);
  }
}
