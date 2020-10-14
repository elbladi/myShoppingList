import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../items_action.dart';

Future<void> removeItemFromList(String itemId) async {
  List<Item> listWithoutItem = getListWithoutItem(itemId);
  await updateDatabases(listWithoutItem, itemId);
  Redux.store.dispatch(SetItemsState(ItemsState(itemList: listWithoutItem)));
  removeImage(itemId);
}

List<Item> getListWithoutItem(String itemId) {
  List<Item> itemList = Redux.store.state.itemsState.getList();
  return itemList.where((item) => item.id != itemId).toList();
}

Future<void> updateDatabases(List<Item> items, String itemId) async {
  deleteItemInFirestore(items);
  await updateItemInLocalDB(itemId);
}

void deleteItemInFirestore(List<Item> items) {
  String listId = Redux.store.state.userState.user.itemListId;
  List<dynamic> itemsFormat = getFirebaseFormat(items);
  FirebaseFirestore.instance
      .collection('items')
      .doc(listId)
      .update({'items': itemsFormat});
}

List<dynamic> getFirebaseFormat(List<Item> items) {
  return items.map((e) => e.toJson()).toList();
}

Future<void> updateItemInLocalDB(String itemId) async {
  final db = await DBHelper.database();
  await db.delete(
    'items',
    where: 'id = ?',
    whereArgs: [itemId],
  );
}

void removeImage(String itemName) {
  removeImageFromStorage(itemName);
  removeImageFromLocalDevice(itemName);
}

void removeImageFromStorage(String itemName) {
  String userList = Redux.store.state.userState.user.itemListId;
  FirebaseStorage.instance
      .ref()
      .child(userList)
      .child(itemName + '.png')
      .delete();
}

void removeImageFromLocalDevice(String itemName) {
  Directory appDocDir = Redux.store.state.loginState.imageDir;
  File imageFile = File('${appDocDir.path}/$itemName.png');
  if (imageFile.existsSync()) imageFile.deleteSync();
}
