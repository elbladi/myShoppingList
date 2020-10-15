import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../items_action.dart';

Future<void> getItemsAndImages(String userList) async {
  List<Item> listOfItems = [];

  if (isDeviceOffline()) {
    listOfItems = await getItemsFromLocalDB();
    listOfItemsReadyToDispatch(listOfItems);
  } else {
    listOfItems = await getItemsFromFirestore(userList);
    listOfItemsReadyToDispatch(listOfItems);

    await downloadImages(listOfItems);
    await updateDatabase(listOfItems);
  }
}

void listOfItemsReadyToDispatch(List<Item> listOfItems) {
  Redux.store.dispatch(
      SetItemsState(ItemsState(loading: false, itemList: listOfItems)));
}

bool isDeviceOffline() {
  final connectivityResult = Redux.store.state.loginState.connection;
  return connectivityResult == ConnectivityResult.none;
}

Future<List<Item>> getItemsFromLocalDB() async {
  final items = await DBHelper.getData('items');

  return List.generate(items.length, (i) {
    return Item(
      id: items[i]['id'],
      image: items[i]['image'],
      name: items[i]['name'],
      quantity: items[i]['quantity'],
      inCart: items[i]['inCart'] == 1,
    );
  });
}

Future<List<Item>> getItemsFromFirestore(String userList) async {
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('items').doc(userList).get();

  List<dynamic> itemsInDatabase = doc.data()['items'];

  return List.generate(itemsInDatabase.length, (i) {
    return Item(
      id: itemsInDatabase[i]['id'],
      image: itemsInDatabase[i]['image'],
      name: itemsInDatabase[i]['name'],
      quantity: itemsInDatabase[i]['quantity'],
      inCart: itemsInDatabase[i]['inCart'],
    );
  });
}

Future<void> downloadImages(List<Item> items) async {
  if (connectedByWifi())
    await downloadUsingWifi(items);
  else
    return;
}

bool connectedByWifi() {
  final connectivityResult = Redux.store.state.loginState.connection;
  return connectivityResult == ConnectivityResult.wifi;
}

Future<void> downloadUsingWifi(List<Item> items) async {
  bool localDBisEmpty = await isLocalDatabaseEmpty();
  if (localDBisEmpty)
    await downloadAllImagesToDevice(items);
  else
    await donwloadSomeImages(items);
}

Future<bool> isLocalDatabaseEmpty() async {
  final itemsInDatabase = await DBHelper.getData('items');
  return itemsInDatabase.isEmpty;
}

Future<void> downloadAllImagesToDevice(List<Item> items) async {
  Directory appDocDir = Redux.store.state.loginState.imageDir;

  await Future.forEach(items, (Item item) async {
    final String itemName = item.name.trim();
    File imageFile = File('${appDocDir.path}/$itemName.png');

    deleteImageIfExist(imageFile);
    createImageFile(imageFile);
    getImageFromDB(imageFile, itemName);
  });
}

Future<void> donwloadSomeImages(List<Item> itemsInFirestore) async {
  List<Item> itemsInLocalDB = await getItemsFromLocalDB();
  Directory appDocDir = Redux.store.state.loginState.imageDir;

  itemsInFirestore.forEach((itemInFirestore) {
    final String itemName = itemInFirestore.name.trim();
    File imageFile = File('${appDocDir.path}/$itemName.png');

    if (firebaseItemExistInLocal(itemsInLocalDB, itemInFirestore))
      verifyIfNeedToDownload(imageFile, itemsInLocalDB, itemInFirestore);
    else
      downloadOneImageToDevice(imageFile, itemName);
  });
}

bool firebaseItemExistInLocal(List<Item> itemsInLocalDB, Item firestoreItem) {
  Item itemExist = itemsInLocalDB.firstWhere(
      (itemInLocal) => itemInLocal.id == firestoreItem.id,
      orElse: () => null);
  if (itemExist == null)
    return false;
  else
    return true;
}

void verifyIfNeedToDownload(
    File image, List<Item> itemsInLocalDB, Item firestoreItem) {
  Item itemLocal = getItemLocal(itemsInLocalDB, firestoreItem);

  if (!imagesAreTheSame(itemLocal, firestoreItem))
    downloadOneImageToDevice(image, itemLocal.name);
}

bool imagesAreTheSame(Item localItem, Item firestoreItem) {
  return localItem.image == firestoreItem.image;
}

Item getItemLocal(List<Item> itemsInLocalDB, Item firestoreItem) {
  return itemsInLocalDB.firstWhere((item) => firestoreItem.id == item.id);
}

void downloadOneImageToDevice(File image, String itemName) {
  deleteImageIfExist(image);
  createImageFile(image);
  getImageFromDB(image, itemName);
}

Future<void> updateDatabase(List<Item> items) async {
  await deleleteItemsInLocalNotInFirebase(items);
  await addFirebaseItemsNotInLocal(items);
}

Future<void> deleleteItemsInLocalNotInFirebase(List<Item> firebaseItems) async {
  List<Item> itemsInLocalDB = await getItemsFromLocalDB();

  itemsInLocalDB.forEach((item) {
    bool existInBothDB = localItemExistInFirebase(item, firebaseItems);
    if (!existInBothDB) deleteLocalItem(item);
  });
}

bool localItemExistInFirebase(Item localItem, List<Item> firebaseItems) {
  return firebaseItems.contains(localItem);
}

Future<void> deleteLocalItem(Item item) async {
  final db = await DBHelper.database();
  await db.delete(
    'items',
    where: 'id = ?',
    whereArgs: [item.id],
  );
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

Future<void> addFirebaseItemsNotInLocal(List<Item> firebaseItems) async {
  List<Item> itemsInLocalDB = await getItemsFromLocalDB();

  firebaseItems.forEach((firestoreItem) {
    if (!firebaseItemExistInLocal(itemsInLocalDB, firestoreItem)) {
      insertFirebaseItemToLocalDB(firestoreItem);
    }
  });
}

Future<void> deleteImageIfExist(File image) async {
  if (image.existsSync()) await image.delete();
}

Future<void> createImageFile(File image) async {
  await image.create();
}

Future<void> insertFirebaseItemToLocalDB(Item item) async {
  await DBHelper.insert(
    'items',
    item.toMap(),
  );
}
