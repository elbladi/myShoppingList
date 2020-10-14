import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/Item_exception.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/store/actions/user_action.dart';
import 'package:myShoppingList/store/states/user_state.dart';

import '../../store.dart';
import '../cart_action.dart';

Future<void> setBackgroundImage(String image) async {
  if (!deviceIsOffline()) {
    setBackgroundImageToUser(image);
    updateUserInFirebase(image);
  } else {
    throw new NewItemException('Sin internet');
  }
}

Future<void> setBackgroundImageToUser(String image) async {
  User user = Redux.store.state.userState.user.copyWith();
  user.config.background = image;
  Redux.store.dispatch(SetUserState(UserState(user: user)));
}

void updateUserInFirebase(String image) {
  User user = Redux.store.state.userState.user.copyWith();
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .update({'config.background': image})
      .then((snapshot) {})
      .catchError((err) => throw err);
}
