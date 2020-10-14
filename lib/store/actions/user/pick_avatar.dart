import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/store/states/user_state.dart';

import '../../store.dart';
import '../user_action.dart';

Future<void> pickAvatar(String avatarName) async {
  await asignNewAvatarToUser(avatarName);
  await updateInDB(avatarName);
}

Future<void> asignNewAvatarToUser(String avatarName) async {
  User user = Redux.store.state.userState.user.copyWith();
  user.avatar = avatarName;
  Redux.store.dispatch(SetUserState(UserState(user: user)));
}

Future<void> updateInDB(String avatarName) async {
  await updateUserInLocalDB(avatarName);
  updateUserInFirebase(avatarName);
}

Future<void> updateUserInLocalDB(String avatarName) async {
  final db = await DBHelper.database();
  await db.update(
    'user',
    {'avatar': avatarName},
  );
}

void updateUserInFirebase(String avatarName) {
  String userId = Redux.store.state.userState.user.id;
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'avatar': avatarName});
}
