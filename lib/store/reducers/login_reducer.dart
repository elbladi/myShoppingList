import '../actions/login_action.dart';
import '../states/login_state.dart';

loginReducer(LoginState prevState, SetLoginState action) {
  final payload = action.loginState;

  return prevState.copyWith(
    logged: payload.logged,
    connection: payload.connection,
    imageDir: payload.imageDir,
  );
}
