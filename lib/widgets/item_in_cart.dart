import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/store/store.dart';

class ItemInCart extends StatelessWidget {
  final String image;
  final String name;
  final bool checked;

  ItemInCart({this.image, this.name, this.checked});

  @override
  Widget build(BuildContext context) {
    final Color fontColor = Redux.store.state.userState.user.config.fontColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: StoreConnector<AppState, ConnectivityResult>(
          distinct: true,
          converter: (store) => store.state.loginState.connection,
          builder: (ctx, connection) {
            if (connection == ConnectivityResult.none)
              return Container(
                child: ImageFromDevice(checked, name),
              );
            else
              return Container(
                child: ImageFromInternet(image, checked),
              );
          },
        ),
        title: Text(
          name.capitalize(),
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: checked ? Colors.grey : fontColor,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
        ),
      ),
    );
  }
}

class ImageFromInternet extends StatelessWidget {
  final String image;
  final bool checked;

  ImageFromInternet(this.image, this.checked);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      image,
      height: 100,
      width: 100,
      fit: BoxFit.contain,
      color: checked ? Colors.grey : null,
    );
  }
}

class ImageFromDevice extends StatelessWidget {
  final bool checked;
  final String name;

  ImageFromDevice(this.checked, this.name);

  @override
  Widget build(BuildContext context) {
    Directory dir = Redux.store.state.loginState.imageDir;
    File fileImage = File('${dir.path}/$name.png');
    bool fileExist = fileImage.existsSync();

    if (fileExist)
      return Image.file(
        fileImage,
        height: 100,
        width: 100,
        fit: BoxFit.contain,
        color: checked ? Colors.grey : null,
      );
    else
      return Image.asset(
        'assets/icons/sidebar.png',
        fit: BoxFit.contain,
        height: 100,
        width: 100,
        color: checked ? Colors.grey : null,
      );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
