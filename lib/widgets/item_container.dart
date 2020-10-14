import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/screens/item_config.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';
import '../models/Item.dart';

class ItemContainer extends StatelessWidget {
  final Item item;
  final Color fontColor;

  ItemContainer({
    @required this.item,
    @required this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(item.id),
      width: 180,
      height: 180,
      child: StoreConnector<AppState, Color>(
          distinct: true,
          converter: (store) => store.state.userState.user.config.fontColor,
          builder: (ctx, fontColor) {
            return Card(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                splashColor: Colors.white,
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    ItemImage(item: item),
                    BottomOptions(item: item, fontColor: fontColor),
                    Counter(quantity: item.quantity, fontColor: fontColor),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class ItemImage extends StatelessWidget {
  final Item item;

  ItemImage({this.item});

  @override
  Widget build(BuildContext context) {
    bool connected =
        Redux.store.state.loginState.connection != ConnectivityResult.none;

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          connected
              ? Image.network(
                  item.image,
                  height: 100,
                  fit: BoxFit.contain,
                )
              : ImageOffline(item),
        ],
      ),
    );
  }
}

class ImageOffline extends StatelessWidget {
  ImageOffline(this.item);

  final Item item;

  @override
  Widget build(BuildContext context) {
    Directory dir = Redux.store.state.loginState.imageDir;
    File fileImage = File('${dir.path}/${item.name}.png');
    bool fileExist = fileImage.existsSync();

    return fileExist
        ? Image.file(
            fileImage,
            fit: BoxFit.contain,
            height: 100,
          )
        : Image.asset(
            'assets/icons/sidebar.png',
            fit: BoxFit.contain,
            height: 100,
          );
  }
}

class BottomOptions extends StatelessWidget {
  final Item item;
  final Color fontColor;

  BottomOptions({
    @required this.item,
    @required this.fontColor,
  });

  void handleQuantity(Action action) {
    Redux.store.dispatch(handleItemCount(
      item.id,
      action == Action.Add ? "add" : "del",
    ));
  }

  void handleItemToCar() {
    Redux.store.dispatch(handleCartItem(item));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.25),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: handleItemToCar,
              child: Icon(
                item.inCart
                    ? Icons.remove_shopping_cart
                    : Icons.add_shopping_cart,
                color: fontColor,
              ),
            ),
            InkWell(
              onTap: () => handleQuantity(Action.Add),
              child: Icon(
                Icons.add_circle,
                color: fontColor,
              ),
            ),
            InkWell(
              onTap: () => handleQuantity(Action.Delete),
              child: Icon(
                Icons.remove_circle,
                color: fontColor,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemConfigScreen(item),
                  )).then((_) => Redux.store.dispatch(cleanFilters)),
              child: Icon(
                Icons.settings,
                color: fontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Counter extends StatelessWidget {
  final int quantity;
  final Color fontColor;

  Counter({
    @required this.quantity,
    @required this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -10,
      right: -5,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.transparent,
        child: Text(
          quantity.toString(),
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: fontColor, fontSize: 30),
        ),
      ),
    );
  }
}

enum Action { Add, Delete }
