import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:myShoppingList/helper/Item_exception.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/actions/items/delete_item_from_list.dart';
import 'package:myShoppingList/store/actions/items/get_from_db.dart';
import 'package:myShoppingList/store/actions/items/item_count_logic.dart';
import 'package:myShoppingList/store/actions/items/update_item.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';

import 'package:myShoppingList/store/states/items_state.dart';
import '../store.dart';
import 'items/add_new_item.dart';

@immutable
class SetItemsState {
  final ItemsState itemsState;

  SetItemsState(this.itemsState);
}

Future<void> readyItemsFromDB(String userList) async {
  initLoading();

  try {
    await getItemsAndImages(userList);
  } catch (error) {
    print('items_action error!');
    print(error);
    stopLoading();
  }
}

Future<void> setSearchInput(String input) async {
  String currentString = Redux.store.state.itemsState.trigerFilterUpd;
  if (input.isEmpty) {
    bool filterNumber = Redux.store.state.itemsState.filterNumber >= 0;
    Redux.store.dispatch(SetItemsState(ItemsState(
      filterName: '',
      filterApplied: filterNumber,
      trigerFilterUpd: currentString + 't',
    )));
    return;
  }

  Redux.store.dispatch(SetItemsState(ItemsState(
    filterName: input,
    filterApplied: true,
    trigerFilterUpd: currentString + 't',
  )));
}

Future<void> setFilterNumber(int number) async {
  String currentString = Redux.store.state.itemsState.trigerFilterUpd;
  try {
    Redux.store.dispatch(SetItemsState(ItemsState(
      filterNumber: number,
      filterApplied: true,
      trigerFilterUpd: currentString + 'x',
    )));
  } catch (err) {
    print(err);
  }
}

Future<void> handleItemCount(String itemId, String action) async {
  try {
    handleItemQuantity(itemId, action);
  } catch (error) {
    print(error);
  }
}

Future<void> reorderItemScreen(int prevIndex, int newIndex) async {
  try {
    List<Item> itemList = [...Redux.store.state.itemsState.itemList];
    itemList.insert(newIndex, itemList.removeAt(prevIndex));
    Redux.store.dispatch(SetItemsState(ItemsState(itemList: itemList)));

    List<dynamic> updatedList = itemList.map((e) => e.toJson()).toList();
    String itemListId = Redux.store.state.userState.user.itemListId;
    FirebaseFirestore.instance
        .collection('items')
        .doc(itemListId)
        .update({'items': updatedList}).catchError((onError) => throw onError);
  } catch (error) {
    print(error);
  }
}

Future<void> setNewItemQuantity(int quantity) async {
  try {
    Redux.store.dispatch(SetItemsState(ItemsState(newItemQuantity: quantity)));
  } catch (err) {
    print(err);
  }
}

Future<void> cleanAddNewItem() async {
  try {
    Redux.store.dispatch(SetItemsState(ItemsState(
      newItemQuantity: 0,
      newItemName: '',
      filterName: '',
      filterNumber: -1,
      filterApplied: false,
      trigerFilterUpd: '',
    )));
  } catch (err) {
    print(err);
  }
}

Future<void> saveNewItemName(String name) async {
  try {
    Redux.store.dispatch(SetItemsState(ItemsState(newItemName: name)));
  } catch (err) {
    print(err);
  }
}

Future<void> saveImagePicked(File image) async {
  if (image == null) return;
  Redux.store.dispatch(SetItemsState(ItemsState(pickedImage: image)));
}

Future<void> cleanInputs() async {
  Redux.store
      .dispatch(SetItemsState(ItemsState(pickedImage: null, newItemName: '')));
}

Future<String> addNewItemToList() async {
  try {
    initLoading();
    await handleAddingNewItemToList();
    stopLoading();
    return 'Success!';
  } on NewItemException catch (err) {
    stopLoading();
    return err.message;
  } catch (err) {
    stopLoading();
    return '😨 Algo salio mal, contacta al Blad 🥴';
  }
}

void stopLoading() {
  Redux.store.dispatch(SetItemsState(ItemsState(loading: false)));
}

void initLoading() {
  Redux.store.dispatch(SetItemsState(ItemsState(loading: true)));
}

Future<void> setNewItemToCart(bool current) async {
  try {
    print(current);
    Redux.store.dispatch(SetItemsState(ItemsState(newItemToCart: current)));
  } catch (err) {
    print(err);
  }
}

Future<void> deleteOneItem(String itemId) async {
  try {
    initLoading();
    await removeItemFromList(itemId);
    stopLoading();
  } catch (err) {
    print(err);
    stopLoading();
  }
}

Future<String> updateItem(Item item, File pickedImage) async {
  try {
    initLoading();
    updateItemInList(item, pickedImage);
    stopLoading();
    return 'Success!';
  } catch (err) {
    print(err);
    stopLoading();
    return 'Algo salio mal  Contacta al Blad 😥';
  }
}

Future<void> updateLocalList(List<Item> itemList) async {
  try {
    if (itemList.length > 0) {
      Redux.store.dispatch(SetItemsState(ItemsState(itemList: itemList)));
    }
  } catch (err) {
    print(err);
  }
}

Future<void> testAddItem(Store<AppState> store) async {
  try {
  } catch (err) {
    print('not working bro');
    print(err);
  }
}

Future<void> cleanFilters(Store<AppState> store) async {
  print('clean');
  store.dispatch(SetItemsState(ItemsState(
    filterName: '',
    filterNumber: -1,
    filterApplied: false,
    trigerFilterUpd: '',
  )));
}
