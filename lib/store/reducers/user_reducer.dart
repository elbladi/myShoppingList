import 'package:myShoppingList/store/states/user_state.dart';

import '../actions/user_action.dart';

userReducer(UserState prevState, SetUserState action) {
  final payload = action.userState;

  return prevState.copyWith(
    error: payload.error,
    isLoading: payload.isLoading,
    user: payload.user,
  );
}
