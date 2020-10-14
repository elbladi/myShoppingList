import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import '../../models/Cart.dart';
import '../store.dart';
import 'cart/add_temp_item_to_cart.dart';
import 'cart/get_cart_from_db.dart';
import 'cart/handle_add_remove_cart_item.dart';
import 'cart/check_cart_item_logic.dart';
import 'cart/items_marked_as_done.dart';

const tempImage =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Noun_Project_question_mark_icon_1101884_cc.svg/1024px-Noun_Project_question_mark_icon_1101884_cc.svg.png';

@immutable
class SetCartState {
  final CartState cartState;

  SetCartState(this.cartState);
}

bool deviceIsOffline() {
  final connectivity = Redux.store.state.loginState.connection;
  return connectivity == ConnectivityResult.none;
}

Future<void> handleCartItem(Item itemSelected) async {
  try {
    changeCartIconFromItemInList(itemSelected);
    addOrRemoveItemFromCart(itemSelected);
  } catch (error) {
    print(error);
  }
}

// Future<void> openCart(Store<AppState> store) async {
//   try {
//     store.dispatch(SetCartState(CartState(cartOpen: true)));
//   } catch (error) {}
// }

// Future<void> closeCart(Store<AppState> store) async {
//   try {
//     store.dispatch(SetCartState(CartState(cartOpen: false)));
//   } catch (error) {}
// }

Future<void> checkItem(String itemName) async {
  try {
    handleCheckItem(itemName);
  } catch (err) {
    print('FAIL checkItem');
    print(err);
  }
}

Future<void> reorderCart(int prevIndex, int newIndex) async {
  try {
    List<Cart> cart = getNewOrderInCart(prevIndex, newIndex);

    updateReorderInDatabase(cart);

    Redux.store.dispatch(SetCartState(CartState(cart: cart)));
  } catch (err) {
    print(err);
  }
}

List<Cart> getNewOrderInCart(int prevIndex, int newIndex) {
  if (newIndex > prevIndex) newIndex -= 1;
  List<Cart> cartItems = [...Redux.store.state.cartState.cart];
  cartItems.insert(newIndex, cartItems.removeAt(prevIndex));
  return cartItems;
}

void updateReorderInDatabase(List<Cart> cart) {
  List<dynamic> updatedList = cart.map((item) => item.toJson()).toList();

  String cartId = Redux.store.state.userState.user.cartId;
  FirebaseFirestore.instance
      .collection('cart')
      .doc(cartId)
      .update({'items': updatedList}).catchError((onError) => throw onError);
}

Future<bool> addTempItemToCart(String name) async {
  try {
    List<Cart> cart = [...Redux.store.state.cartState.cart];

    bool itemAlreadyExist = itemExistInCart(cart, name);
    if (itemAlreadyExist)
      return false;
    else {
      updateCartWithNewTempItem(cart, name);
      return true;
    }
  } catch (err) {
    print(err);
    return false;
  }
}

Future<void> getCartFromDB(String cartId) async {
  try {
    getFromDatabase(cartId);
  } catch (err) {
    print('El horror!');
    print(err);
  }
}

Future<void> cleanCart(Store<AppState> store) async {
  try {
    removeItemsMarkedAsChecked();
  } catch (err) {
    print(err);
  }
}
