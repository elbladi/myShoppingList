import 'package:flutter/material.dart';

class Cart {
  String id;
  String name;
  String image;
  bool checked;

  Cart({
    @required this.id,
    @required this.name,
    @required this.image,
    @required this.checked,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'image': this.image,
      'checked': this.checked,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'image': this.image,
      'checked': this.checked ? 1 : 0,
    };
  }

  Cart copyWith({
    String id,
    String name,
    String image,
    bool checked,
  }) {
    return new Cart(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      checked: checked ?? this.checked,
    );
  }
}
