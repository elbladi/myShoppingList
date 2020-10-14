import 'package:flutter/material.dart';

class Item {
  String id;
  String name;
  int quantity;
  String image;
  bool inCart;

  Item({
    @required this.id,
    @required this.image,
    @required this.name,
    @required this.quantity,
    @required this.inCart,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'image': this.image,
      'name': this.name,
      'quantity': this.quantity,
      'inCart': this.inCart
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'image': this.image,
      'name': this.name,
      'quantity': this.quantity,
      'inCart': this.inCart ? 1 : 0
    };
  }

  // List<Item> createList(List<Map<String, dynamic>> listFromDB) {

  // }

  Item copyWith({
    String id,
    String name,
    int quantity,
    String image,
    bool inCart,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      inCart: inCart ?? this.inCart,
    );
  }
}
