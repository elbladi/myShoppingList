import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/screens/add_item_screen.dart';
import 'package:myShoppingList/screens/cart_screen.dart';
import 'package:myShoppingList/screens/config_options_screen.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/store/actions/user_action.dart';
import 'package:myShoppingList/store/store.dart';
import '../widgets/layout_content.dart';

class SideDrawer extends StatelessWidget {
  final List<String> avatars = const [
    '1.png',
    '2.png',
    '3.png',
    '4.png',
    '5.png',
    '6.png',
    '7.png',
    '8.png',
    '9.png',
    '10.png',
    '11.png',
    '12.png',
    '13.png',
    '14.png',
    '15.png',
    '16.png',
    '17.png',
    '18.png',
    '19.png',
    '20.png',
    '21.png',
    '22.png',
    '23.png',
    '24.png',
    '25.png',
    '26.png',
    '27.png',
    '28.png',
    '29.png',
    '30.png',
  ];

  void _pickAvatar(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child: Text('Cambiar Avatar')),
        content: Container(
          height: height - (height * 0.4),
          width: width - (width * 0.4),
          child: GridView.count(
            crossAxisCount: 2,
            children: avatars
                .map(
                  (name) => InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      changeAvatar(name);
                    },
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/avatars/$name'),
                      backgroundColor: Colors.blueGrey[100],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _addNewItem(BuildContext context) {
    if (deviceIsOffline()) {
      Navigator.of(context).pop();
      _showSnackbar(context, 'Conectate a internet 📡');
    } else {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddNewItem()))
          .then((_) {
        Redux.store.dispatch(cleanAddNewItem);
      });
    }
  }

  void _openCart(BuildContext context) {
    String cartId = Redux.store.state.userState.user.cartId;

    Navigator.of(context).pop();

    getCartFromDB(cartId).then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CartScreen()));
    });
  }

  void _logout() {
    Redux.store.dispatch(logout);
  }

  void _settings(BuildContext context) {
    if (deviceIsOffline()) {
      Navigator.of(context).pop();
      _showSnackbar(context, 'Conectate a internet 📡');
    } else {
      Navigator.of(context).pop();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ConfigOptionsScreen()));
    }
  }

  void _mainPage(BuildContext context) {
    Navigator.of(context).pop();
    User user = Redux.store.state.userState.user;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScaffold(user),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
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
    double width = MediaQuery.of(context).size.width;
    Color color = Redux.store.state.userState.user.config.fontColor;
    return Container(
      width: width - (width * 0.5),
      child: Drawer(
        elevation: 5,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.only(bottom: 30),
              child: Center(
                child: Stack(
                  children: [
                    StoreConnector<AppState, String>(
                      distinct: true,
                      converter: (store) => store.state.userState.user.avatar,
                      builder: (ctx, avatar) => CircleAvatar(
                        minRadius: 45,
                        backgroundImage: AssetImage('assets/avatars/$avatar'),
                        backgroundColor: Colors.blueGrey[100],
                      ),
                    ),
                    Positioned(
                      right: -15,
                      child: IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.edit),
                        onPressed: () => _pickAvatar(context),
                      ),
                    ),
                  ],
                  overflow: Overflow.visible,
                ),
              ),
              decoration: BoxDecoration(color: color),
            ),
            ListTile(
                leading: Icon(Icons.list),
                title: Text('Todos los Articulos'),
                onTap: () => _mainPage(context)),
            ListTile(
                leading: Icon(Icons.add_circle),
                title: Text('Nuevo Articulo'),
                onTap: () => _addNewItem(context)),
            ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Lista de Compras'),
                onTap: () => _openCart(context)),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configurar'),
                onTap: () => _settings(context)),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Salir'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
