// ignore_for_file: body_might_complete_normally_nullable

class MechanicModel {
  final String fname;
  final String lname;
  final String email;
  final String? address;
  final String phone;
  final double lat;
  final double lng;
  final String? idfront;
  final String? idback;
  final bool verified;

  MechanicModel(
      {required this.fname,
      required this.verified,
      required this.lname,
      required this.idback,
      required this.idfront,
      required this.email,
      required this.address,
      required this.phone,
      required this.lat,
      required this.lng});

  Map<String, dynamic> toJson() => {
        "verified": verified,
        "idback": idback,
        "fname": fname,
        "idfront": idfront,
        "lname": lname,
        "email": email,
        "address": address,
        "phone": phone,
        "lat": lat,
        "lng": lng,
      };

  // static MechanicModel? fromSnap(DocumentSnapshot snap) {
  //   var snapshot = snap.data() as Map<String, dynamic>;
  //   return MechanicModel(
  //     fname: snapshot['fname'],
  //     lname: snapshot['lname'],
  //     email: snapshot['email'],
  //     password: snapshot['password'],
  //     address: snapshot['address'],
  //     phone: snapshot['phone'],
  //   );
  // }

  static MechanicModel? fromJson(Map<String, dynamic> json) => MechanicModel(
        verified: json['verified'],
        idback: json['idback'],
        idfront: json['idfront'],
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        address: json['address'],
        phone: json['phone'],
        lat: json['lat'],
        lng: json['lng'],
      );
}
