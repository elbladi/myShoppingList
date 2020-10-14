import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';

@immutable
class LoginState {
  final bool logged;
  final ConnectivityResult connection;
  final Directory imageDir;

  LoginState({
    this.logged,
    this.connection,
    this.imageDir,
  });

  factory LoginState.initial() => LoginState(
        logged: false,
        connection: ConnectivityResult.none,
        imageDir: null,
      );

  LoginState copyWith({
    @required bool logged,
    @required ConnectivityResult connection,
    @required Directory imageDir,
  }) {
    return LoginState(
      logged: logged ?? this.logged,
      connection: connection ?? this.connection,
      imageDir: imageDir ?? this.imageDir,
    );
  }
}
