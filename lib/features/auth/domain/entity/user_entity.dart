

class UserEntity {
  //Baas assign id to user.
  //FB called it uid;
  final String id;

  //Data Integrity - Truth is preserve
  //helps to keep One unified Entity rather than seperate for each sub-feature
  final String? email; 

  final String? phoneNumber;

  UserEntity({required this.id, required this.email, this.phoneNumber});
}
