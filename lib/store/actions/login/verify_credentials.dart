import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Login.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/store/actions/cart/get_cart_from_db.dart';
import 'package:myShoppingList/store/states/login_state.dart';
import 'package:myShoppingList/store/states/user_state.dart';

import '../../store.dart';
import '../cart_action.dart';
import '../items_action.dart';
import '../login_action.dart';
import '../user_action.dart';

Future<void> verifyUserIsLoggedIn() async {
  await verifyUserExistInLocalDB();

  User loggedUser = await loadLocalUser();
  if (!isDeviceOffline()) {
    String email = loggedUser.email;
    String passw = loggedUser.password;
    await logUserToFirestore(email, passw);

    loggedUser = await getUserFromFirestore(email, passw);
    await updateUserInLocalDB(loggedUser);
  }

  await getListOfItems(loggedUser);
  await getListOfCart(loggedUser);
  dispatchLoggedUser(loggedUser);
  Redux.store.dispatch(SetLoginState(LoginState(logged: true)));
}

Future<void> verifyUserExistInLocalDB() async {
  final userFromLocalDB = await DBHelper.getData('user');

  if (userFromLocalDB.length <= 0) {
    throw new Exception('User List dont exist. Log in');
  }
}

Future<User> loadLocalUser() async {
  var storedUser = await DBHelper.getData('user');

  User loggedUser;

  storedUser.forEach((user) {
    final config = jsonDecode(user['config']);
    int color = config['fontColor'];
    String background = config['background'];
    String id = user['id'];
    String cartId = user['cartId'];
    String itemListId = user['itemListId'];
    String name = user['name'];
    List<dynamic> temp = jsonDecode(user['backgrounds']);
    List<String> backgrounds = temp.map((e) => e.toString()).toList();
    String avatar = user['avatar'];
    Color fontColor = Color(color);
    String password = user['pw'];
    String email = user['email'];

    loggedUser = User(
      id: id,
      cartId: cartId,
      itemListId: itemListId,
      name: name,
      config: Config(
        background: background,
        fontColor: fontColor,
      ),
      backgrounds: backgrounds,
      avatar: avatar,
      email: email,
      password: password,
    );

    Redux.store.dispatch(SetUserState(UserState(user: loggedUser)));
  });

  return loggedUser;
}

Future<void> getListOfItems(User loggedUser) async {
  await readyItemsFromDB(loggedUser.itemListId);
}

Future<void> getListOfCart(User loggedUser) async {
  await getCartFromDB(loggedUser.cartId);
}

Future<void> logUserToFirestore(String email, String password) async {
  print('trying');
  try {
    await fb.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } on fb.FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
    throw Exception();
  }
}

void dispatchLoggedUser(User user) {
  Redux.store.dispatch(SetUserState(UserState(user: user)));
}

Future<User> getUserFromFirestore(String email, String password) async {
  User loggedUser;
  await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email.trim().toLowerCase())
      .limit(1)
      .get()
      .then((QuerySnapshot snapshot) {
    final doc = snapshot.docs[0].data();
    int color = doc['config']['fontColor'];
    String id = snapshot.docs[0].id;
    String cartId = doc['cartId'];
    String itemListId = doc['itemListId'];
    String name = doc['name'];
    String background = doc['config']['background'];
    List<dynamic> temp = doc['backgrounds'];
    List<String> backgrounds = temp.map((e) => e.toString()).toList();
    String avatar = doc['avatar'];
    Color fontColor = Color(color);

    loggedUser = User(
      id: id,
      cartId: cartId,
      itemListId: itemListId,
      name: name,
      config: Config(
        background: background,
        fontColor: fontColor,
      ),
      backgrounds: backgrounds,
      avatar: avatar,
      email: email.trim(),
      password: password.trim(),
    );
  });
  print(loggedUser.name);
  return loggedUser;
}

Future<void> updateUserInLocalDB(User user) async {
  await deletePreviousUser();
  await insertNewUser(user);
}

Future<void> deletePreviousUser() async {
  final db = await DBHelper.database();
  await db.delete('user');
}

Future<void> insertNewUser(User user) async {
  Color color = user.config.fontColor;
  int fontColor = color.value;

  await DBHelper.insert('user', {
    'id': user.id,
    'email': user.email,
    'avatar': user.avatar,
    'backgrounds': jsonEncode(user.backgrounds),
    'cartId': user.cartId,
    'config': jsonEncode({
      'background': user.config.background,
      'fontColor': fontColor,
    }),
    'itemListId': user.itemListId,
    'name': user.name,
    'pw': user.password,
  });
}

Future<void> handleLogin(Login credentials) async {
  try {
    if (isDeviceOffline())
      await tryLogginOffline();
    else
      await tryLogginOnline(credentials);
  } on LoginFailException catch (err) {
    print(err);
    throw new Exception('fail mensaje 2');
  } catch (err) {
    throw err;
  }
}

Future<void> tryLogginOffline() async {
  try {
    await verifyUserExistInLocalDB();
    await verifyUserIsLoggedIn();
  } catch (err) {
    throw new Exception('Conectatate a internet');
  }
}

Future<void> tryLogginOnline(Login credentials) async {
  String email = credentials.user.trim();
  String pass = credentials.password.trim();

  try {
    await logUserToFirestore(email, pass);
    User loggedUser = await getUserFromFirestore(email, pass);

    await updateUserInLocalDB(loggedUser);
    await getListOfItems(loggedUser);
    await getListOfCart(loggedUser);
    dispatchLoggedUser(loggedUser);
    Redux.store.dispatch(SetLoginState(LoginState(logged: true)));
  } catch (err) {
    throw new Exception('Login fail');
  }
}

class LoginFailException implements Exception {
  String message;

  LoginFailException(this.message);
}
