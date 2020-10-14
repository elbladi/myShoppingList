import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/store/states/cart_state.dart';

import '../../store.dart';
import '../cart_action.dart';

void updateCartWithNewTempItem(List<Cart> cart, String name) {
  Cart item = createTempItem(name);
  insertItemInCart(item, cart);

  updateDatabases(cart, item);

  Redux.store.dispatch(SetCartState(CartState(cart: cart)));
}

Cart createTempItem(String name) {
  return Cart(
    checked: false,
    id: name,
    image: tempImage,
    name: name,
  );
}

void insertItemInCart(Cart item, List<Cart> cart) {
  cart.insert(0, item);
}

void updateDatabases(List<Cart> cart, Cart item) {
  updateFirestore(cart);
  insertInLocalDB(item);
}

void updateFirestore(List<Cart> cart) {
  String userCartId = Redux.store.state.userState.user.cartId;

  List<dynamic> updatedCart = cart.map((item) => item.toJson()).toList();

  FirebaseFirestore.instance
      .collection('cart')
      .doc(userCartId)
      .update({'items': updatedCart}).catchError((onError) => throw onError);
}

void insertInLocalDB(Cart item) async {
  await DBHelper.insert('cart', item.toMap());
}
