import 'package:myShoppingList/store/actions/cart_action.dart';

import '../states/cart_state.dart';

cartReducer(CartState prevState, SetCartState action) {
  final payload = action.cartState;
  return prevState.copyWith(
    cart: payload.cart,
  );
}
