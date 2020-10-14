import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../items_action.dart';

void handleItemQuantity(String itemId, String action) async {
  Item item = getItemToEdit(itemId);
  if (action == 'add')
    addOneToItemQuantity(item);
  else
    removeOneToItemQuantity(item);

  List<Item> updatedItemList = updateList(item);
  Redux.store.dispatch(SetItemsState(ItemsState(itemList: updatedItemList)));
  await updateItemInDB(item, updatedItemList);
}

Item getItemToEdit(String itemId) {
  List<Item> itemList = Redux.store.state.itemsState.getList();
  return itemList.firstWhere((item) => item.id == itemId);
}

void addOneToItemQuantity(Item item) {
  item.quantity += 1;
}

void removeOneToItemQuantity(Item item) {
  if (canRemoveOne(item)) item.quantity -= 1;
}

bool canRemoveOne(Item item) {
  return item.quantity > 0;
}

Future<void> updateItemInDB(Item item, List<Item> updatedList) async {
  await updateInLocalDB(item);
  updateInFirebase(updatedList);
}

Future<void> updateInLocalDB(Item item) async {
  final db = await DBHelper.database();
  await db.update(
    'items',
    item.toMap(),
    where: 'id = ?',
    whereArgs: [item.id],
  );
}

void updateInFirebase(List<Item> updatedItemList) {
  List<dynamic> itemsInBFormat = getItemsInFirebaseFormat(updatedItemList);
  String userListId = Redux.store.state.userState.user.itemListId;

  FirebaseFirestore.instance
      .collection('items')
      .doc(userListId)
      .update({'items': itemsInBFormat}).catchError((onError) => throw onError);
}

List<Item> updateList(Item item) {
  List<Item> itemList = Redux.store.state.itemsState.getList();
  int index = getIndex(itemList, item);
  itemList.removeWhere((itm) => itm.id == item.id);
  itemList.insert(index, item);
  return itemList;
}

int getIndex(List<Item> list, Item item) {
  Item itemInOldList = list.firstWhere((itm) => itm.id == item.id);
  return list.indexOf(itemInOldList);
}

List<dynamic> getItemsInFirebaseFormat(List<Item> itemList) {
  return itemList.map((item) => item.toJson()).toList();
}
