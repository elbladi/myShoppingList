import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/Cart.dart';
import 'package:myShoppingList/models/User.dart';
import 'package:myShoppingList/screens/add_item_screen.dart';
import 'package:myShoppingList/screens/cart_screen.dart';
import 'package:myShoppingList/screens/login_screen.dart';
import 'package:myShoppingList/store/actions/cart_action.dart';
import 'package:myShoppingList/store/actions/items_action.dart';
import 'package:myShoppingList/widgets/side_drawer.dart';
import 'package:myShoppingList/widgets/type_bar.dart';
import '../store/store.dart';
import '../screens/items_screen.dart';

class LayoutContent extends StatefulWidget {
  @override
  _LayoutContentState createState() => _LayoutContentState();
}

class _LayoutContentState extends State<LayoutContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
        distinct: true,
        converter: (store) => store.state.loginState.logged,
        builder: (ctx, logged) {
          if (!logged)
            return LoginScreen();
          else
            return StoreConnector<AppState, User>(
              distinct: true,
              converter: (store) => store.state.userState.user,
              builder: (ctx, user) {
                if (user == null) return SplashScreen();
                return MainScaffold(user);
              },
            );
        });
  }
}

// ignore: must_be_immutable
class MainScaffold extends StatelessWidget {
  MainScaffold(this._user);

  final User _user;

  @override
  Widget build(BuildContext context) {
    bool connected =
        Redux.store.state.loginState.connection != ConnectivityResult.none;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        // drawer: SideDrawer(),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Scaffold(
              drawer: SideDrawer(),
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              extendBodyBehindAppBar: true,
              appBar: PreferredSize(
                preferredSize: Size(double.infinity, 60),
                child: Header(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: connected
                              ? NetworkImage(_user.config.background)
                              : AssetImage('assets/icons/cool2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 80),
                          TypeBar(),
                          ItemScreen(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: AddNewItemButton(),
      ),
    );
  }
}

class FloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AddNewItemButton extends StatelessWidget {
  AddNewItemButton();

  void _goToAddNewScreen(BuildContext context) {
    final connected = Redux.store.state.loginState.connection;
    if (connected == ConnectivityResult.none) {
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
    } else {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddNewItem()))
          .then((_) {
        Redux.store.dispatch(cleanAddNewItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Color>(
      distinct: true,
      converter: (store) => store.state.userState.user.config.fontColor,
      builder: (ctx, fontColor) {
        return FloatingActionButton(
          onPressed: () => _goToAddNewScreen(context),
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add,
            color: fontColor,
            size: 50,
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  void _openCart(BuildContext context) {
    String cartId = Redux.store.state.userState.user.cartId;
    Redux.store.dispatch(getCartFromDB(cartId).then((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CartScreen()));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Color>(
        distinct: true,
        converter: (store) => store.state.userState.user.config.fontColor,
        builder: (ctx, _fontColor) {
          return AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: InkWell(
              onTap: () async {
                // await DBHelper.delete('items');
                final List<Cart> cart = Redux.store.state.cartState.cart;
                print(cart[0].checked);
              },
              child: Text(
                'MIS ARTICULOS',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: _fontColor),
                textAlign: TextAlign.center,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: _fontColor,
                size: 35,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            actions: [
              IconButton(
                tooltip: 'Lista a comprar',
                icon: Icon(
                  Icons.shopping_cart,
                  color: _fontColor,
                  size: 35,
                ),
                onPressed: () => _openCart(context),
              ),
            ],
            centerTitle: true,
          );
        });
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset('assets/icons/main.png'),
      ),
    );
  }
}
