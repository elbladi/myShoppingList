import 'package:meta/meta.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/actions/login_action.dart';
import 'package:myShoppingList/store/reducers/cart_reducer.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:myShoppingList/store/states/items_state.dart';
import 'package:myShoppingList/store/states/login_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import './actions/user_action.dart';
import './reducers/user_reducer.dart';
import './reducers/items_reducer.dart';
import './reducers/login_reducer.dart';
import 'states/user_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserState) {
    final newUserState = userReducer(state.userState, action);

    return state.copyWith(userState: newUserState);
  }
  if (action is SetItemsState) {
    final newItemState = itemReducer(state.itemsState, action);
    return state.copyWith(itemsState: newItemState);
  }
  if (action is SetCartState) {
    final newCartState = cartReducer(state.cartState, action);
    return state.copyWith(cartState: newCartState);
  }
  if (action is SetLoginState) {
    final newLoginState = loginReducer(state.loginState, action);
    return state.copyWith(loginState: newLoginState);
  }

  return state;
}

@immutable
class AppState {
  final UserState userState;
  final ItemsState itemsState;
  final CartState cartState;
  final LoginState loginState;

  AppState({
    @required this.userState,
    @required this.itemsState,
    @required this.cartState,
    @required this.loginState,
  });

  AppState copyWith({
    UserState userState,
    ItemsState itemsState,
    CartState cartState,
    LoginState loginState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
      itemsState: itemsState ?? this.itemsState,
      cartState: cartState ?? this.cartState,
      loginState: loginState ?? this.loginState,
    );
  }
}

class Redux {
  static Store<AppState> _store;

  static Store<AppState> get store {
    if (_store == null) throw Exception('Store is not initialized');
    return _store;
  }

  static Future<void> init() async {
    final userStateInitial = UserState.initial();
    final itemsStateInitial = ItemsState.initial();
    final cartStateInitial = CartState.initial();
    final loginStateInitial = LoginState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        userState: userStateInitial,
        itemsState: itemsStateInitial,
        cartState: cartStateInitial,
        loginState: loginStateInitial,
      ),
    );
  }
}
