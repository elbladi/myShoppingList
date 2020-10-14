import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/user_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/background_example.dart';
import 'package:myShoppingList/widgets/side_drawer.dart';
import '../widgets/layout_content.dart';

const addImage =
    "https://firebasestorage.googleapis.com/v0/b/myshoppinglist-90365.appspot.com/o/add.png?alt=media&token=7449a38f-eaf9-4ec5-aa29-4e5235b1d689";

class ConfigOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 3;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      drawer: SideDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: Header(),
      ),
      body: StoreConnector<AppState, User>(
        distinct: true,
        converter: (store) => store.state.userState.user,
        builder: (ctx, user) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(user.config.background),
                fit: BoxFit.cover,
              ),
            ),
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                initialPage: 0,
              ),
              items: [
                BackgroundContainer(itemWidth, itemHeight, user),
                SelectColor(itemWidth, itemHeight, user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BackgroundContainer extends StatefulWidget {
  final double itemWidth;
  final double itemHeight;
  final User user;

  BackgroundContainer(this.itemWidth, this.itemHeight, this.user);

  @override
  _BackgroundContainerState createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  void changeBack(image, BuildContext context) async {
    final success = await changeBackgroundImage(image);
    if (!success) _showSnackbar(context);
  }

  void _showSnackbar(BuildContext context) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[900],
        content: Text(
          'Conectate a internet 📡',
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addBackgroundImageToList(_, BuildContext context) async {
    if (deviceIsOffline()) {
      _showSnackbar(context);
    } else {
      final picker = ImagePicker();
      try {
        final image = await picker.getImage(
          imageQuality: 50,
          source: ImageSource.gallery,
        );
        if (image == null) return;

        File imageFile = File(image.path);
        Redux.store.dispatch(addNewBackgroundImage(imageFile));
        setState(() {});
      } catch (err) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<dynamic>>(
      distinct: true,
      converter: (store) => store.state.userState.user.backgrounds,
      builder: (ctx, backs) {
        return Column(
          children: [
            SizedBox(height: 60),
            Container(
              width: double.infinity,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: (widget.itemWidth / widget.itemHeight),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                children: [
                  ...backs
                      .map((image) => BackgroundExample(
                            imageUrl: image,
                            currentImage: widget.user.config.background,
                            selectedBackImage: changeBack,
                            minHeight: widget.itemHeight,
                            minWidth: widget.itemWidth,
                          ))
                      .toList(),
                  BackgroundExample(
                    imageUrl: addImage,
                    currentImage: "",
                    selectedBackImage: addBackgroundImageToList,
                    minHeight: widget.itemHeight,
                    minWidth: widget.itemWidth,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SelectColor extends StatelessWidget {
  final double itemWidth;
  final double itemHeight;
  final User user;

  SelectColor(this.itemWidth, this.itemHeight, this.user);

  void onChangeColor(Color color) {
    if (color == null) return;
    Redux.store.dispatch(changeFontColor(Redux.store, color));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: MaterialPicker(
        pickerColor: user.config.fontColor,
        onColorChanged: onChangeColor,
      ),
    );
  }
}
