import 'package:firebase_auth/firebase_auth.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/store/states/login_state.dart';
import 'package:myShoppingList/store/states/user_state.dart';

import '../../store.dart';
import '../login_action.dart';
import '../user_action.dart';

Future<void> logoutUser() async {
  Redux.store.dispatch(SetUserState(UserState(user: null)));
  Redux.store.dispatch(SetLoginState(LoginState(logged: false)));
  await deleteUserFromLocalDB();
  deleteUserSession();
}

Future<void> deleteUserFromLocalDB() async {
  final db = await DBHelper.database();
  await db.delete('user');
}

void deleteUserSession() {
  FirebaseAuth.instance.signOut();
}
