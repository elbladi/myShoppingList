import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../cart_action.dart';
import '../items_action.dart';

// LIST SECTION //

void changeCartIconFromItemInList(Item itemSelected) {
  List<Item> listOfItems = [...Redux.store.state.itemsState.itemList];

  final indexOfSelectedItemInList =
      getIndexOfSelectedItem(listOfItems, itemSelected.id);

  removeSelectedItemFromList(listOfItems, indexOfSelectedItemInList);
  Item editedItem = getNewItemWithNewCartValue(itemSelected);

  listOfItems.insert(indexOfSelectedItemInList, editedItem);

  Redux.store.dispatch(SetItemsState(ItemsState(itemList: listOfItems)));
  updateListToFirestore(listOfItems);
}

Item getNewItemWithNewCartValue(Item itemSelected) {
  Item editedItem = itemSelected.copyWith();
  editedItem.inCart = !editedItem.inCart;
  return editedItem;
}

void removeSelectedItemFromList(List<Item> listOfItems, int index) {
  listOfItems.removeAt(index);
}

int getIndexOfSelectedItem(List<Item> listOfItems, String itemId) {
  Item copyOfItem = listOfItems.firstWhere((item) => item.id == itemId);
  return listOfItems.indexOf(copyOfItem);
}

void updateListToFirestore(List<Item> items) {
  String userListId = Redux.store.state.userState.user.itemListId;
  List<dynamic> updatedList = items.map((e) => e.toJson()).toList();

  FirebaseFirestore.instance
      .collection('items')
      .doc(userListId)
      .update({'items': updatedList});
}

// CART SECTION //

void addOrRemoveItemFromCart(Item itemSelected) {
  List<Cart> listCart = getCart();
  Cart newItem = newCart(itemSelected);

  if (isCartEmpty())
    addItemToCart(listCart, newItem);
  else
    handleItemInCart(listCart, newItem);

  Redux.store.dispatch(SetCartState(CartState(cart: listCart)));
  updateCartToFirestore(listCart);
}

List<Cart> getCart() {
  return [...Redux.store.state.cartState.cart];
}

Cart newCart(Item selectedItem) {
  return Cart(
    id: selectedItem.id,
    checked: false,
    image: selectedItem.image,
    name: selectedItem.name.trim(),
  );
}

bool isCartEmpty() {
  List<Cart> listCart = [...Redux.store.state.cartState.cart];
  return listCart.isEmpty;
}

void addItemToCart(List<Cart> cart, Cart newItem) async {
  cart.add(newItem);
  await DBHelper.insert('cart', newItem.toMap());
}

void handleItemInCart(List<Cart> cart, Cart item) {
  if (itemAlreadyInCart(cart, item.id))
    removeItemToCart(cart, item);
  else
    addItemToCart(cart, item);
}

bool itemAlreadyInCart(List<Cart> cart, String itemId) {
  Cart itemExistInCart =
      cart.firstWhere((item) => item.id == itemId, orElse: () => null);

  if (itemExistInCart == null)
    return false;
  else
    return true;
}

void removeItemToCart(List<Cart> cart, Cart newItem) async {
  cart.removeWhere((item) => item.id == newItem.id);
  final db = await DBHelper.database();
  await db.delete('cart', where: 'id = ?', whereArgs: [newItem.id]);
}

void updateCartToFirestore(List<Cart> cart) {
  String cartId = Redux.store.state.userState.user.cartId;
  List<dynamic> updatedCart = cart.map((e) => e.toJson()).toList();

  FirebaseFirestore.instance
      .collection('cart')
      .doc(cartId)
      .update({'items': updatedCart});
}
