import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/store/states/cart_state.dart';

import '../../store.dart';
import '../cart_action.dart';

void handleCheckItem(String itemName) {
  final List<Cart> cart = Redux.store.state.cartState.getCart();

  if (!itemExistInCart(cart, itemName)) return;

  Cart item = getItemFromCart(cart, itemName);
  item.checked = !item.checked;

  updateItemInCart(cart, item);
  Redux.store.dispatch(SetCartState(CartState(cart: cart)));
}

bool itemExistInCart(List<Cart> cart, String itemName) {
  final Cart item =
      cart.firstWhere((item) => item.name == itemName, orElse: () => null);
  if (item == null)
    return false;
  else
    return true;
}

Cart getItemFromCart(List<Cart> cart, itemName) {
  return cart.firstWhere((item) => item.name == itemName).copyWith();
}

void updateItemInCart(List<Cart> cart, Cart updatedItem) {
  int index = getIndexOfItemFromCart(cart, updatedItem.name);
  deleteOldItemFromCart(cart, index);
  addUpdatedItemToCart(cart, updatedItem, index);
}

int getIndexOfItemFromCart(List<Cart> cart, String itemName) {
  final Cart oldItem = cart.firstWhere((item) => item.name == itemName);
  return cart.indexOf(oldItem);
}

void deleteOldItemFromCart(List<Cart> cart, int index) {
  cart.removeAt(index);
}

void addUpdatedItemToCart(List<Cart> cart, Cart item, int index) {
  cart.insert(index, item);
  updateDatabase(cart, item);
}

void updateDatabase(List<Cart> cart, Cart item) {
  updateInFirestore(cart);
  updateInLocalDB(item);
}

void updateInFirestore(List<Cart> cart) {
  String userCartId = Redux.store.state.userState.user.cartId;
  List<dynamic> updatedList = cart.map((item) => item.toJson()).toList();
  FirebaseFirestore.instance
      .collection('cart')
      .doc(userCartId)
      .update({'items': updatedList});
}

void updateInLocalDB(Cart item) async {
  final db = await DBHelper.database();
  db.update(
    'cart',
    item.toMap(),
    where: 'id = ?',
    whereArgs: [item.id],
  );
}
