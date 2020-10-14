import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/store.dart';
import 'package:myShoppingList/widgets/item_in_cart.dart';
import 'package:myShoppingList/widgets/side_drawer.dart';
import '../widgets/layout_content.dart';
import '../store/actions/cart_action.dart';

class CartScreen extends StatelessWidget {
  void _cleanDone() {
    Redux.store.dispatch(cleanCart);
  }

  @override
  Widget build(BuildContext context) {
    Color fontColor = Redux.store.state.userState.user.config.fontColor;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: Header(),
      ),
      drawer: SideDrawer(),
      body: LimitedBox(
        maxHeight: double.infinity,
        child: Column(
          children: [
            NewTempItem(fontColor),
            SizedBox(height: 20),
            StoreConnector<AppState, List<Cart>>(
              distinct: true,
              converter: (store) => store.state.cartState.cart,
              builder: (ctx, cart) => CartItems(cart),
            ),
            RaisedButton(
              onPressed: _cleanDone,
              color: Colors.white,
              elevation: 5,
              child: Text(
                'Limpiar marcados',
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontSize: 12,
                      color: Redux.store.state.userState.user.config.fontColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewTempItem extends StatelessWidget {
  final Color fontColor;
  final TextEditingController _controller = TextEditingController();

  NewTempItem(this.fontColor);

  void addTempItem(String name, BuildContext context) {
    if (name.isNotEmpty)
      Redux.store.dispatch(addTempItemToCart(name).then((valid) {
        if (!valid) _showSnackBar(context, '$name ya esta en la lista');
      }));
    _controller.clear();
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
    return LimitedBox(
      maxWidth: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            child: TextField(
              controller: _controller,
              autocorrect: true,
              style: TextStyle(color: fontColor),
              keyboardType: TextInputType.text,
              enableSuggestions: true,
              decoration: InputDecoration(
                labelText: 'Nuevo',
                labelStyle: Theme.of(context).textTheme.headline6.copyWith(
                      fontSize: 20,
                      color: fontColor,
                    ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]),
                ),
              ),
              onSubmitted: (String val) => addTempItem(val, context),
            ),
          ),
          IconButton(
            alignment: Alignment.bottomLeft,
            color: fontColor,
            onPressed: () {
              if (_controller.text.isEmpty) return;
              addTempItem(_controller.text, context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class CartItems extends StatelessWidget {
  final List<Cart> cart;
  CartItems(this.cart);

  void itemClicked(String name) {
    Redux.store.dispatch(checkItem(name));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          Redux.store.dispatch(reorderCart(oldIndex, newIndex));
        },
        children: cart
            .map((item) => InkWell(
                  key: ValueKey(item.name),
                  onTap: () => itemClicked(item.name),
                  child: ItemInCart(
                    checked: item.checked,
                    image: item.image,
                    name: item.name,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
