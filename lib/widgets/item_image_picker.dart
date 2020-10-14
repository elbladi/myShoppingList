import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:myShoppingList/store/store.dart';

class ItemImagePicker extends StatefulWidget {
  ItemImagePicker(this.imagePickFn, this.itemImage, this.itemName);
  final Function(File pickedImage) imagePickFn;
  final String itemImage;
  final String itemName;

  @override
  _ItemImagePickerState createState() => _ItemImagePickerState();
}

const imageUrl =
    'https://pbs.twimg.com/profile_images/1187814172307800064/MhnwJbxw_400x400.jpg';

class _ItemImagePickerState extends State<ItemImagePicker> {
  File _pickedImage;

  void _selectImage(BuildContext context, bool hasInternet) async {
    if (!hasInternet) {
      _showSnackBar(context, 'No puedes cambiar la imagen sin internet 📡');
      return;
    }
    final picker = ImagePicker();
    try {
      final image = await picker.getImage(
        imageQuality: 50,
        maxWidth: 150,
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        _pickedImage = File(image.path);
      });
      widget.imagePickFn(_pickedImage);
    } catch (err) {
      print(err);
    }
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

  ImageProvider getImage() {
    String itemName = widget.itemName;

    Directory dir = Redux.store.state.loginState.imageDir;
    File fileImage = File('${dir.path}/$itemName.png');
    bool fileExist = fileImage.existsSync();
    if (fileExist)
      return FileImage(fileImage);
    else
      return AssetImage('assets/icons/sidebar.png');
  }

  @override
  Widget build(BuildContext context) {
    bool hasInternet =
        Redux.store.state.loginState.connection != ConnectivityResult.none;
    return InkWell(
      onTap: () => _selectImage(context, hasInternet),
      child: Container(
        height: 130,
        width: 130,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _pickedImage == null
                ? widget.itemImage.isNotEmpty && hasInternet
                    ? NetworkImage(widget.itemImage)
                    : getImage()
                : FileImage(_pickedImage),
            fit: BoxFit.cover,
          ),
          border: Border.all(width: 2.0),
        ),
      ),
    );
  }
}
