import 'dart:async';
import 'dart:io';

import 'package:myShoppingList/store/actions/login/verify_credentials.dart';
import 'package:myShoppingList/store/actions/user_action.dart';
import 'package:myShoppingList/store/states/login_state.dart';
import 'package:meta/meta.dart';
import 'package:myShoppingList/store/states/user_state.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/Login.dart';
import 'package:connectivity/connectivity.dart';

@immutable
class SetLoginState {
  final LoginState loginState;

  SetLoginState(this.loginState);
}

Future<void> setDeviceConnection(ConnectivityResult status) async {
  try {
    Redux.store.dispatch(SetLoginState(LoginState(connection: status)));
  } catch (err) {
    print(err);
  }
}

Future<void> initializeDirectory() async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Redux.store.dispatch(SetLoginState(LoginState(imageDir: appDocDir)));
  } catch (err) {
    print(err);
  }
}

Future<bool> verifyCredentials() async {
  try {
    print('Trying to login in');
    await initializeDirectory();
    await verifyUserIsLoggedIn();

    return true;
  } catch (err) {
    print('Error in LOGIN action');
    print(err);
    return false;
  }
}

Future<bool> login(Login credentials) async {
  try {
    Redux.store.dispatch(SetUserState(UserState(isLoading: true)));
    await initializeDirectory();
    await handleLogin(credentials);
    Redux.store.dispatch(SetUserState(UserState(isLoading: false)));
    return true;
  } on LoginFailException catch (err) {
    Redux.store.dispatch(SetUserState(UserState(isLoading: false)));
    Redux.store.dispatch(SetLoginState(LoginState(logged: false)));
    print(err);
    print('tercero');
    return false;
  } catch (e) {
    Redux.store.dispatch(SetLoginState(LoginState(logged: false)));
    Redux.store.dispatch(SetUserState(UserState(isLoading: false)));
    print(e);
    return false;
  }
}
