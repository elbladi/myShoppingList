import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/item_name_and_quantity.dart';
import '../widgets/item_image_picker.dart';

class AddNewItem extends StatefulWidget {
  @override
  _AddNewItemState createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  File _imagePicked;

  void onImagePicked(File image) {
    _imagePicked = image;
    Redux.store.dispatch(saveImagePicked(image));
    setState(() {});
  }

  @override
  void initState() {
    Redux.store.dispatch(cleanInputs);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String backgroundImage = Redux.store.state.userState.user.config.background;
    Color color = Redux.store.state.userState.user.config.fontColor;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Card(
              elevation: 5,
              child: Container(
                width: 250,
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Nuevo Articulo',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: color,
                          ),
                    ),
                    ItemImagePicker(onImagePicked, '', ''),
                    NameAndQuantity(false, null),
                    AddItemButtons(_imagePicked != null),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemButtons extends StatelessWidget {
  final bool imageSelected;
  AddItemButtons(this.imageSelected);

  void _validateForm(BuildContext context, bool close) {
    String name = Redux.store.state.itemsState.newItemName;

    if (!imageSelected) {
      _showSnackBar(context, 'Selecciona una imagen');
      return;
    }

    if (name.isEmpty) {
      _showSnackBar(context, 'Ingresa un nombre');
      return;
    }

    Redux.store.dispatch(addNewItemToList().then((message) {
      if (message == 'Success!')
        Navigator.of(context).pop();
      else
        _showSnackBar(context, message);
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
              onPressed: () => _validateForm(context, true),
              elevation: 5,
              child: Text(
                'Agregar',
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
