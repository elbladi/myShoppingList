import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/store/states/cart_state.dart';

import '../../store.dart';
import '../cart_action.dart';

Future<void> getFromDatabase(String userCartId) async {
  List<Cart> cart = [];

  if (isDeviceOffline())
    await getCartFromLocalDB(cart);
  else
    await getCartFromFirestore(cart, userCartId);

  Redux.store.dispatch(SetCartState(CartState(cart: cart)));
}

bool isDeviceOffline() {
  final connectivityResult = Redux.store.state.loginState.connection;
  return connectivityResult == ConnectivityResult.none;
}

Future<void> getCartFromLocalDB(List<Cart> cart) async {
  final cartFromDB = await DBHelper.getData('cart');
  cartFromDB.forEach((e) {
    cart.add(Cart(
      id: e['id'],
      name: e['name'],
      image: e['image'],
      checked: e['checked'] == 1,
    ));
  });
}

Future<void> getCartFromFirestore(List<Cart> cart, String cartId) async {
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('cart').doc(cartId).get();

  List<dynamic> itemsInCart = doc.data()['items'] as List<dynamic>;

  fillCartWithCartFromDB(itemsInCart, cart);
  updateLocalDBCart(cart);
}

void fillCartWithCartFromDB(List<dynamic> firestoreCart, List<Cart> cart) {
  firestoreCart.forEach((e) {
    cart.add(Cart(
      id: e['id'],
      name: e['name'],
      image: e['image'],
      checked: e['checked'],
    ));
  });
}

void updateLocalDBCart(List<Cart> cart) {
  deleteLocalDBCart();
  insertCartItemsToCartTable(cart);
}

void deleteLocalDBCart() async {
  await DBHelper.delete('cart');
}

void insertCartItemsToCartTable(List<Cart> cart) async {
  await Future.forEach(cart, (Cart item) async {
    await DBHelper.insert(
      'cart',
      item.toMap(),
    );
  });
}
