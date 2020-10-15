import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/actions/cart/handle_add_remove_cart_item.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:myShoppingList/store/store.dart';

import '../cart_action.dart';

Future<void> removeItemsMarkedAsChecked() async {
  if (cartIsEmpty())
    return;
  else
    await updateCart();
}

bool cartIsEmpty() {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  if (cart.isEmpty)
    return true;
  else
    return false;
}

Future<void> updateCart() async {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  List<Cart> itemsInCartNotChecked = getNotCheckedItems(cart);
  List<String> listOfCheckedItemsId = getListOfCheckedItemsIds(cart);
  await updateDatabases(itemsInCartNotChecked);
  Redux.store.dispatch(SetCartState(CartState(cart: itemsInCartNotChecked)));
  await updateListOfItems(listOfCheckedItemsId);
}

List<Cart> getNotCheckedItems(List<Cart> cart) {
  return cart.where((item) => item.checked == false).toList();
}

List<String> getListOfCheckedItemsIds(List<Cart> cart) {
  List<String> ids = [];
  cart.forEach((item) {
    if (item.checked == true) {
      ids.add(item.id);
    }
  });
  return ids;
}

Future<void> updateDatabases(List<Cart> cart) async {
  updateFirestore(cart);
  updateLocalDB();
}

void updateFirestore(List<Cart> cart) {
  String cartId = Redux.store.state.userState.user.cartId;
  List<dynamic> formatedCart = cart.map((e) => e.toJson()).toList();

  FirebaseFirestore.instance
      .collection('cart')
      .doc(cartId)
      .update({'items': formatedCart});
}

Future<void> updateLocalDB() async {
  final db = await DBHelper.database();
  await db.delete(
    'cart',
    where: 'checked = ?',
    whereArgs: [1],
  );
}

Future<void> updateListOfItems(List<String> listOfCheckedItemsId) async {
  if (listOfIdsToUpdateExist(listOfCheckedItemsId)) {
    await updateItemsList(listOfCheckedItemsId);
  }
}

bool listOfIdsToUpdateExist(List<String> ids) {
  return ids.length > 0;
}

Future<void> updateItemsList(List<String> itemsId) async {
  updateListInFirebase(itemsId);
  await updateListInLocalDB(itemsId);
}

Future<void> updateListInFirebase(List<String> itemsId) async {
  List<Item> items = await getListOfItemsWithInCartUpdated(itemsId);
  List<dynamic> itemsFormat = getFirebaseItemsFormat(items);
  uploadListToFirestore(itemsFormat);
}

Future<List<Item>> getListOfItemsWithInCartUpdated(List<String> itemsId) async {
  List<Item> items = Redux.store.state.itemsState.getList();

  Future.forEach(itemsId, (itemInCartId) async {
    if (itemInCartExistInItemList(itemInCartId, items)) {
      await upadteItemInList(itemInCartId, items);
    }
  });
  return items;
}

List<dynamic> getFirebaseItemsFormat(List<Item> items) {
  return items.map((e) => e.toJson()).toList();
}

void uploadListToFirestore(List<dynamic> itemList) {
  String userListId = Redux.store.state.userState.user.itemListId;

  FirebaseFirestore.instance
      .collection('items')
      .doc(userListId)
      .update({'items': itemList});
}

bool itemInCartExistInItemList(String itemInCartId, List<Item> items) {
  Item findItem =
      items.firstWhere((item) => item.id == itemInCartId, orElse: () => null);
  if (findItem == null)
    return false;
  else
    return true;
}

Future<void> upadteItemInList(String itemId, List<Item> items) async {
  Item itemToUpdate = getItemToUpdate(itemId, items);
  changeInCartToFalse(itemToUpdate);
  updateItemInTheList(itemToUpdate, items);
}

Item getItemToUpdate(String itemId, List<Item> items) {
  return items.firstWhere((item) => item.id == itemId).copyWith();
}

void changeInCartToFalse(Item item) {
  item.inCart = false;
}

void updateItemInTheList(Item item, List<Item> items) {
  int itemIndexInList = getIndexOfSelectedItem(items, item.id);
  removeSelectedItemFromList(items, itemIndexInList);
  items.insert(itemIndexInList, item);
}

Future<void> updateListInLocalDB(List<String> itemsId) async {
  final db = await DBHelper.database();

  Future.forEach(itemsId, (itemId) async {
    await db.update(
      'items',
      {'inCart': 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  });
}
