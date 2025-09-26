import 'dart:convert';

class User {
  final String customerId;
  final String name;
  final String email;
  final String phone;
  final String sex; // 'male' | 'female' | 'other'
  final int yearOfBirth;
  final String avatar; // URL or local path
  final List<Address> addresses;
  final List<CardDetail> cardDetails;
  final int interactive;
  final int bought;
  final int viewed;
  final String password;
  final String token;
  final List<Role> roles;
  final Metadata metadata;

  const User({
    required this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.sex,
    required this.yearOfBirth,
    required this.avatar,
    required this.addresses,
    required this.cardDetails,
    required this.interactive,
    required this.bought,
    required this.viewed,
    required this.password,
    required this.token,
    required this.roles,
    required this.metadata,
  });

  User copyWith({
    String? customerId,
    String? name,
    String? email,
    String? phone,
    String? sex,
    int? yearOfBirth,
    String? avatar,
    List<Address>? addresses,
    List<CardDetail>? cardDetails,
    int? interactive,
    int? bought,
    int? viewed,
    String? password,
    String? token,
    List<Role>? roles,
    Metadata? metadata,
  }) {
    return User(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      sex: sex ?? this.sex,
      yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      avatar: avatar ?? this.avatar,
      addresses: addresses ?? this.addresses,
      cardDetails: cardDetails ?? this.cardDetails,
      interactive: interactive ?? this.interactive,
      bought: bought ?? this.bought,
      viewed: viewed ?? this.viewed,
      password: password ?? this.password,
      token: token ?? this.token,
      roles: roles ?? this.roles,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'sex': sex,
      'yearOfBirth': yearOfBirth,
      'avatar': avatar,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'cardDetails': cardDetails.map((c) => c.toJson()).toList(),
      'interactive': interactive,
      'bought': bought,
      'viewed': viewed,
      'password': password,
      'token': token,
      'roles': roles.map((r) => r.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      sex: json['sex'] as String,
      yearOfBirth: (json['yearOfBirth'] as num).toInt(),
      avatar: json['avatar'] as String? ?? '',
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
      cardDetails: (json['cardDetails'] as List<dynamic>? ?? [])
          .map((e) => CardDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      interactive: (json['interactive'] as num?)?.toInt() ?? 0,
      bought: (json['bought'] as num?)?.toInt() ?? 0,
      viewed: (json['viewed'] as num?)?.toInt() ?? 0,
      password: json['password'] as String,
      token: json['token'] as String,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static User fromJsonString(String s) =>
      fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class Address {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  const Address({
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
  };

  static Address fromJson(Map<String, dynamic> json) => Address(
    line1: json['line1'] as String,
    line2: json['line2'] as String? ?? '',
    city: json['city'] as String,
    state: json['state'] as String,
    country: json['country'] as String,
    postalCode: json['postalCode'] as String,
  );
}

class CardDetail {
  final String holderName;
  final String cardNumberMasked; // Do not store raw PAN in plaintext
  final String expiryMonth;
  final String expiryYear;
  final String brand; // visa, mastercard, etc.

  const CardDetail({
    required this.holderName,
    required this.cardNumberMasked,
    required this.expiryMonth,
    required this.expiryYear,
    required this.brand,
  });

  Map<String, dynamic> toJson() => {
    'holderName': holderName,
    'cardNumberMasked': cardNumberMasked,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'brand': brand,
  };

  static CardDetail fromJson(Map<String, dynamic> json) => CardDetail(
    holderName: json['holderName'] as String,
    cardNumberMasked: json['cardNumberMasked'] as String,
    expiryMonth: json['expiryMonth'] as String,
    expiryYear: json['expiryYear'] as String,
    brand: json['brand'] as String,
  );
}

class Role {
  final String name; // 'user', 'parent', 'teacher', etc.
  const Role(this.name);

  Map<String, dynamic> toJson() => {'name': name};
  static Role fromJson(Map<String, dynamic> json) =>
      Role(json['name'] as String);
}

class Metadata {
  final String createdAtIso;
  final String updatedAtIso;
  final Map<String, dynamic> extra;

  const Metadata({
    required this.createdAtIso,
    required this.updatedAtIso,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() => {
    'createdAtIso': createdAtIso,
    'updatedAtIso': updatedAtIso,
    'extra': extra,
  };

  static Metadata fromJson(Map<String, dynamic> json) => Metadata(
    createdAtIso: json['createdAtIso'] as String,
    updatedAtIso: json['updatedAtIso'] as String,
    extra: (json['extra'] as Map<String, dynamic>?) ?? <String, dynamic>{},
  );
}
