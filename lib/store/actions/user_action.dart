// import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:myShoppingList/helper/Item_exception.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/user/pick_avatar.dart';
import 'package:myShoppingList/store/actions/user/set_background_image.dart';
import 'package:myShoppingList/store/states/user_state.dart';
import 'package:redux/redux.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../store.dart';
import 'login/logout_user.dart';

@immutable
class SetUserState {
  final UserState userState;

  SetUserState(this.userState);
}

Future<void> testser(Store<AppState> store) async {
// final response = await rootBundle.loadString('assets/data/Users.json');
// var jsonData = json.decode(response);
// jsonData = jsonData[1];

// Color fontColor = Color(int.parse(jsonData['config']['fontColor']));

// final loggedUser = User(
//   id: jsonData['id'],
//   cartId: jsonData['cartId'],
//   itemListId: jsonData['itemListId'],
//   name: jsonData['name'],
//   config: Config(
//     background: jsonData['config']['background'],
//     // firstTime: jsonData['config']['firstTime'],
//     fontColor: fontColor,
//   ),
//   backgrounds: jsonData['backgrounds'],
// );
}

Future<void> changeAvatar(String avatarName) async {
  try {
    if (avatarName.isEmpty) return;
    await pickAvatar(avatarName);
  } catch (err) {
    print(err);
  }
}

Future<bool> changeBackgroundImage(String image) async {
  try {
    await setBackgroundImage(image);
    return true;
  } on NewItemException {
    return false;
  } catch (err) {
    print(err);
    return true;
  }
}

Future<void> changeFontColor(Store<AppState> store, Color newColor) async {
  if (newColor == null) return;
  try {
    User user = store.state.userState.user.copyWith();
    user.config.fontColor = newColor;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({'config.fontColor': newColor.value})
        .then((snapshot) {})
        .catchError((err) => throw err);

    store.dispatch(SetUserState(UserState(user: user)));
  } catch (err) {
    print(err);
  }
}

Future<void> addNewBackgroundImage(File image) async {
  if (image == null) return;
  int imageId = Random().nextInt(1000);
  String imageName = 'backg' + imageId.toString() + '.png';
  User user = Redux.store.state.userState.user.copyWith();
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('${user.itemListId}')
        .child('${user.id}')
        .child('backgrounds/$imageName');

    await ref.putFile(image).onComplete;

    final url = await ref.getDownloadURL();
    user.backgrounds.add(url);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({'backgrounds': user.backgrounds});

    Redux.store.dispatch(SetUserState(UserState(user: user)));
  } catch (err) {
    print(err);
  }
}

Future<void> deleteBackImage(String imageUrl) async {
  try {
    if (imageUrl.isEmpty) return;
    if (deviceIsOffline()) return;
    User user = Redux.store.state.userState.user.copyWith();

    List<dynamic> currentBackgrounds = [...user.backgrounds];
    List<dynamic> updated =
        currentBackgrounds.where((back) => back != imageUrl).toList();

    user.backgrounds = updated;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({'backgrounds': updated});

    Redux.store.dispatch(SetUserState(UserState(user: user)));
  } catch (err) {
    print(err);
  }
}

Future<void> logout(Store<AppState> store) async {
  try {
    await logoutUser();
  } catch (err) {
    print(err);
  }
}
