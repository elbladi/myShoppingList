import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../cart_action.dart';
import '../items_action.dart';

Future<void> updateItemInList(Item item, File pickedImage) async {
  String oldId = item.id;
  updateItemName(item);
  updateItemQuantity(item);

  if (userSelectNewImage(pickedImage)) {
    item.image = await uploadImageAndGetUrl(pickedImage, item);
    updateLocalImage(item.name);
  }

  updateModifiedItemInList(item, oldId);

  if (itemExistInCart(oldId)) {
    await updateCartWithUpdatedItem(item, oldId);
  }
}

void updateItemName(Item item) {
  String newItemName = Redux.store.state.itemsState.newItemName;
  if (newItemName.isNotEmpty) {
    item.name = newItemName;
  }
}

void updateItemQuantity(Item item) {
  int selectedQuantity = Redux.store.state.itemsState.newItemQuantity;
  if (item.quantity != selectedQuantity) {
    item.quantity = selectedQuantity;
  }
}

bool userSelectNewImage(File pickedImage) {
  return pickedImage != null;
}

Future<String> uploadImageAndGetUrl(File pickedImage, Item item) async {
  String listId = Redux.store.state.userState.user.itemListId;

  final ref =
      FirebaseStorage.instance.ref().child(listId).child(item.name + '.png');

  await ref.putFile(pickedImage).onComplete;

  return await ref.getDownloadURL();
}

void updateLocalImage(String itemName) {
  Directory appDocDir = Redux.store.state.loginState.imageDir;
  File imageFile = File('${appDocDir.path}/$itemName.png');
  if (imageFile.existsSync()) {
    imageFile.deleteSync();
  }
  imageFile.create();
  getImageFromDB(imageFile, itemName);
}

void getImageFromDB(File imageFile, String itemName) {
  String userListId = Redux.store.state.userState.user.itemListId;
  try {
    FirebaseStorage.instance
        .ref()
        .child(userListId)
        .child('$itemName.png')
        .writeToFile(imageFile);
  } on FirebaseException catch (e) {
    print('Exception!');
    print(e);
  }
}

void updateModifiedItemInList(Item item, String oldId) {
  List<Item> itemList = Redux.store.state.itemsState.getList();
  int index = getItemIndex(itemList, item);
  removeUpdatedItemFromList(itemList, item);
  insertItemInList(itemList, index, item);
  dispatchItemList(itemList);
  updateDatabases(itemList, item, oldId);
}

int getItemIndex(List<Item> list, Item item) {
  Item itemInList = list.firstWhere((itm) => itm.id == item.id);
  return list.indexOf(itemInList);
}

void removeUpdatedItemFromList(List<Item> list, Item item) {
  list.removeWhere((i) => item.id == i.id);
}

void insertItemInList(List<Item> list, int index, Item item) {
  item.id = item.name;
  list.insert(index, item);
}

void dispatchItemList(List<Item> itemList) {
  Redux.store.dispatch(SetItemsState(ItemsState(
    itemList: itemList,
    newItemName: '',
    newItemQuantity: 0,
  )));
}

void updateDatabases(List<Item> list, Item item, String oldId) async {
  updateItemInFirebase(list);
  await updateItemInLocalDB(item, oldId);
}

void updateItemInFirebase(List<Item> list) {
  String listId = Redux.store.state.userState.user.itemListId;
  List<dynamic> listFormat = getListInFirebaseFormat(list);

  FirebaseFirestore.instance
      .collection('items')
      .doc(listId)
      .update({'items': listFormat});
}

List<dynamic> getListInFirebaseFormat(List<Item> list) {
  return list.map((e) => e.toJson()).toList();
}

Future<void> updateItemInLocalDB(Item item, String oldId) async {
  final db = await DBHelper.database();
  await db.update(
    'items',
    item.toMap(),
    where: 'id = ?',
    whereArgs: [oldId],
  );
}

bool itemExistInCart(String oldId) {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  Cart exist = cart.firstWhere((item) => item.id == oldId, orElse: () => null);

  if (exist == null)
    return false;
  else
    return true;
}

Future<void> updateCartWithUpdatedItem(Item item, String oldId) async {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  Cart itemInCart = getItemInCart(oldId);
  int itemInCartIndex = getItemInCartIndex(oldId);
  deleteItemFromCart(itemInCartIndex, cart);
  insertUpdatedItemIntoCart(item, itemInCartIndex, cart, itemInCart);
  dispatchCart(cart);
  await updateItemInCartInDatabases(cart, itemInCart, oldId);
}

Cart getItemInCart(String oldId) {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  return cart.firstWhere((item) => item.id == oldId);
}

int getItemInCartIndex(String oldId) {
  List<Cart> cart = Redux.store.state.cartState.getCart();
  Cart itemInCart = cart.firstWhere((item) => item.id == oldId);
  return cart.indexOf(itemInCart);
}

void deleteItemFromCart(int index, List<Cart> cart) {
  cart.removeAt(index);
}

void insertUpdatedItemIntoCart(
    Item item, int index, List<Cart> cart, Cart itemInCart) {
  Cart updatedItemInCart = Cart(
    checked: itemInCart.checked,
    id: item.id,
    image: item.image,
    name: item.name,
  );
  cart.insert(index, updatedItemInCart);
}

void dispatchCart(List<Cart> cart) {
  Redux.store.dispatch(SetCartState(CartState(cart: cart)));
}

Future<void> updateItemInCartInDatabases(
    List<Cart> cart, Cart item, String oldId) async {
  updateCartInFirebase(cart);
  await updateCartLocal(item, oldId);
}

void updateCartInFirebase(List<Cart> cart) {
  String cartId = Redux.store.state.userState.user.cartId;
  List<dynamic> firebaseFormat = getFirestoreFormat(cart);
  FirebaseFirestore.instance
      .collection('cart')
      .doc(cartId)
      .update({'items': firebaseFormat});
}

List<dynamic> getFirestoreFormat(List<Cart> cart) {
  return cart.map((e) => e.toJson()).toList();
}

Future<void> updateCartLocal(Cart item, String oldId) async {
  final db = await DBHelper.database();
  await db.update(
    'cart',
    item.toMap(),
    where: 'id = ?',
    whereArgs: [oldId],
  );
}
