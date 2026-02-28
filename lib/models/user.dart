class UserAddress {
  final String city;
  final String street;
  final int number;
  final String zipcode;

  UserAddress({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      city:    json['city']    ?? '',
      street:  json['street']  ?? '',
      number:  json['number']  ?? 0,
      zipcode: json['zipcode'] ?? '',
    );
  }
}

class UserName {
  final String firstname;
  final String lastname;

  UserName({required this.firstname, required this.lastname});

  factory UserName.fromJson(Map<String, dynamic> json) {
    return UserName(
      firstname: json['firstname'] ?? '',
      lastname:  json['lastname']  ?? '',
    );
  }

  String get fullName => '$firstname $lastname';
}

class User {
  final int id;
  final String email;
  final String username;
  final String phone;
  final UserName name;
  final UserAddress address;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.name,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:       json['id'],
      email:    json['email']    ?? '',
      username: json['username'] ?? '',
      phone:    json['phone']    ?? '',
      name:     UserName.fromJson(json['name']    ?? {}),
      address:  UserAddress.fromJson(json['address'] ?? {}),
    );
  }
}