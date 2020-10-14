import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/Item.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/item_image_picker.dart';
import 'package:myShoppingList/widgets/item_name_and_quantity.dart';

class ItemConfigScreen extends StatefulWidget {
  final Item item;

  ItemConfigScreen(this.item);
  @override
  _ItemConfigScreenState createState() => _ItemConfigScreenState();
}

class _ItemConfigScreenState extends State<ItemConfigScreen> {
  File _imagePicked;

  void onImagePicked(File image) {
    _imagePicked = image;
    setState(() {});
  }

  void _validateForm(BuildContext context) {
    Item oldItem = widget.item.copyWith();

    Redux.store.dispatch(updateItem(oldItem, _imagePicked).then((message) {
      if (message != 'Success!') {
        _showSnackBar(context, message);
      } else
        Navigator.of(context).pop();
    }));
  }

  void _showSnackBar(BuildContext context, String message) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[900],
        content: Text(
          message,
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> deleteItem(BuildContext ctx) async {
    Color _color = Redux.store.state.userState.user.config.fontColor;
    final Item item = widget.item;
    final TextStyle textTheme =
        Theme.of(ctx).textTheme.headline6.copyWith(color: _color);
    return showDialog<void>(
      context: ctx,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quieres eliminar ${item.name}?', style: textTheme),
          content: Image.network(
            item.image,
            height: 100,
            fit: BoxFit.contain,
          ),
          actions: [
            FlatButton(
              child: Text('Si', style: textTheme),
              onPressed: () {
                Redux.store.dispatch(deleteOneItem(item.id).then((_) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }));
              },
            ),
            FlatButton(
              child: Text('No', style: textTheme),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String backgroundImage = Redux.store.state.userState.user.config.background;
    Item item = widget.item.copyWith();
    bool hasInternet =
        Redux.store.state.loginState.connection != ConnectivityResult.none;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: hasInternet
                  ? NetworkImage(backgroundImage)
                  : AssetImage('assets/icons/cool2.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                Card(
                  elevation: 5,
                  child: Container(
                    width: 250,
                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ItemImagePicker(onImagePicked, item.image, item.name),
                        NameAndQuantity(true, item),
                        Buttons(_validateForm),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -10,
                  child: CircleAvatar(
                    backgroundColor: Colors.red[900],
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () => deleteItem(context),
                    ),
                  ),
                ),
              ],
              overflow: Overflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  final Function validateForm;
  Buttons(this.validateForm);

  @override
  Widget build(BuildContext context) {
    Color color = Redux.store.state.userState.user.config.fontColor;
    return StoreConnector<AppState, bool>(
      distinct: true,
      converter: (store) => store.state.itemsState.loading,
      builder: (ctx, loading) {
        if (loading) return Center(child: CircularProgressIndicator());
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              color: Colors.white,
              onPressed: () => validateForm(context),
              elevation: 5,
              child: Text(
                'Guardar',
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: color,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
