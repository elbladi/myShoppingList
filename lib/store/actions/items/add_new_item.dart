import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myShoppingList/helper/Item_exception.dart';
import 'package:myShoppingList/helper/db_helper.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/states/cart_state.dart';
import 'package:myShoppingList/store/states/items_state.dart';

import '../../store.dart';
import '../cart_action.dart';
import '../items_action.dart';

Future<void> handleAddingNewItemToList() async {
  doValidationsBeforeUpload();

  String imageUrl = await uploadImageAndGetUrl();
  saveImageInLocalDevice();
  await updateNewItem(imageUrl);
  cleanNewQuantity();
}

void doValidationsBeforeUpload() {
  verifyNameIsNotEmpty();
  verifyImageWasSelected();
  verifyItemIsNotInListAlready();
}

void verifyNameIsNotEmpty() {
  String itemName = Redux.store.state.itemsState.newItemName.trim();
  if (itemName.isEmpty)
    throw new NewItemException('El nombre no puede estar vacio');
}

void verifyImageWasSelected() {
  File image = Redux.store.state.itemsState.pickedImage;
  if (image == null) throw new NewItemException('Selecciona una imagen');
}

void verifyItemIsNotInListAlready() {
  String itemName = Redux.store.state.itemsState.newItemName.trim();

  List<Item> itemList = Redux.store.state.itemsState.getList();

  Item itemExist = itemList.firstWhere((item) => item.name.trim() == itemName,
      orElse: () => null);

  if (itemExist != null)
    throw new NewItemException('$itemName ya existe en la lista 🤦🏻‍♂️');
}

Future<String> uploadImageAndGetUrl() async {
  try {
    String userList = Redux.store.state.userState.user.itemListId;
    String itemName = Redux.store.state.itemsState.newItemName.trim();
    File image = Redux.store.state.itemsState.pickedImage;

    final ref =
        FirebaseStorage.instance.ref().child(userList).child(itemName + '.png');

    await ref.putFile(image).onComplete;

    return await ref.getDownloadURL();
  } catch (err) {
    print(err);
    throw new NewItemException(
        'No se pudo subir la imagen 🤷🏼‍♂️ Intenta con otra');
  }
}

Future<void> updateNewItem(String image) async {
  List<Item> items = Redux.store.state.itemsState.getList();
  Item newItem = getNewItem(image);

  addNewItemToItemList(items, newItem);
  Redux.store.dispatch(SetItemsState(ItemsState(
    itemList: items,
  )));

  await addItemToCart(newItem);

  await updateItemListToDatabases(items, newItem);
}

void cleanNewQuantity() {
  Redux.store
      .dispatch(SetItemsState(ItemsState(newItemName: '', newItemQuantity: 0)));
}

Item getNewItem(String image) {
  String itemName = Redux.store.state.itemsState.newItemName.trim();
  bool addToCart = Redux.store.state.itemsState.newItemToCart;
  int quantity = Redux.store.state.itemsState.newItemQuantity;

  return Item(
      id: itemName,
      image: image,
      inCart: addToCart,
      name: itemName,
      quantity: quantity);
}

void addNewItemToItemList(List<Item> items, Item newItem) {
  items.insert(0, newItem);
}

Future<void> addItemToCart(Item item) async {
  if (isSelectedToAddToCart(item)) {
    await updateCart(item);
  }
}

bool isSelectedToAddToCart(Item item) {
  return item.inCart;
}

Future<void> updateCart(Item item) async {
  Cart itemInCart = getItemForCart(item);
  List<Cart> cart = getCart();

  cart.insert(0, itemInCart);
  Redux.store.dispatch(SetCartState(CartState(cart: cart)));
  await updateCartInDatabases(cart, itemInCart);
}

Cart getItemForCart(Item item) {
  return Cart(
    id: item.name,
    checked: false,
    image: item.image,
    name: item.name,
  );
}

List<Cart> getCart() {
  return Redux.store.state.cartState.getCart();
}

Future<void> updateCartInDatabases(List<Cart> cart, Cart item) async {
  updateCartInFirebase(cart);
  await updateCartInLocalDB(item);
}

void updateCartInFirebase(List<Cart> cart) {
  String cartId = Redux.store.state.userState.user.cartId;
  List<dynamic> cartFormated = getFirebaseCartFormat(cart);

  FirebaseFirestore.instance
      .collection('cart')
      .doc(cartId)
      .update({'items': cartFormated});
}

List<dynamic> getFirebaseCartFormat(List<Cart> cart) {
  return cart.map((e) => e.toJson()).toList();
}

Future<void> updateCartInLocalDB(Cart item) async {
  await DBHelper.insert('cart', item.toMap());
}

Future<void> updateItemListToDatabases(List<Item> items, Item item) async {
  updateListInFirebase(items);
  await updateListInLocalDB(item);
}

void updateListInFirebase(List<Item> items) {
  String userList = Redux.store.state.userState.user.itemListId;
  List<dynamic> itemsFormated = getFirebaseItemsFormat(items);
  FirebaseFirestore.instance
      .collection('items')
      .doc(userList)
      .update({'items': itemsFormated});
}

List<dynamic> getFirebaseItemsFormat(List<Item> items) {
  return items.map((e) => e.toJson()).toList();
}

Future<void> updateListInLocalDB(Item item) async {
  await DBHelper.insert('items', item.toMap());
}

void saveImageInLocalDevice() async {
  Directory appDocDir = Redux.store.state.loginState.imageDir;
  String itemName = Redux.store.state.itemsState.newItemName.trim();
  File imageFile = File('${appDocDir.path}/$itemName.png');
  if (imageFile.existsSync()) {
    await imageFile.delete();
  }
  await imageFile.create();
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
