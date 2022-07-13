class UserModel {
  String? uid;
  String? Fname;
  String? Lname;
  String? phone;

  //receiving data from firebase
  UserModel({this.uid, this.Fname, this.Lname, this.phone});

  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        Fname: map['Fname'],
        Lname: map['Lname'],
        phone: map['phone']);
  }

  //sending data to firebase
  Map<String, dynamic> toMap() {
    return {
      'Uid': uid,
      'phone': phone,
      'firstName': Fname,
      'lastName': Lname,
    };
  }
}
