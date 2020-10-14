import 'package:flutter/material.dart';

class User {
  String id;
  String name;
  String itemListId;
  String cartId;
  Config config;
  String avatar;
  String email;
  String password;
  List<dynamic> backgrounds;

  User(
      {@required this.id,
      @required this.name,
      @required this.itemListId,
      @required this.cartId,
      @required this.config,
      @required this.backgrounds,
      @required this.email,
      @required this.password,
      @required this.avatar});

  User copyWith({
    String id,
    String name,
    String itemListId,
    String cartId,
    String avatar,
    Config config,
    List<dynamic> backgrounds,
    String password,
    String email,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      itemListId: itemListId ?? this.itemListId,
      cartId: cartId ?? this.cartId,
      config: config ?? this.config,
      backgrounds: backgrounds ?? this.backgrounds,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
    );
  }

  User.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    this.id = json['id'];
    this.itemListId = json['itemListId'];
    this.cartId = json['cartId'];
    this.config = Config(
      // firstTime: json['config']['firstTime'],
      background: json['config']['background'],
      fontColor: json['config']['fontColor'],
    );
    this.backgrounds = json['backgrounds'];
    this.email = json['email'];
    this.password = json['password'];
  }
}

class Config {
  String background;
  Color fontColor;
  // bool firstTime;

  Map<String, dynamic> toJson() {
    return {
      'background': this.background,
      'fontColor': this.fontColor,
    };
  }

  Config({
    this.fontColor,
    // @required this.firstTime,
    @required this.background,
  });
}
