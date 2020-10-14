import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/store/actions/login_action.dart';

import './store/store.dart';

import 'package:myShoppingList/widgets/layout_content.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity/connectivity.dart';

void main() async {
  await Redux.init();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var subscription;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      setState(() {});
      Redux.store.dispatch(setDeviceConnection(result));
    });
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  void initializeFlutterFire() {
    try {
      print('INITIALIZANDO FIREBASE');
      Firebase.initializeApp();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: Redux.store,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mis Articulos',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'Merienda',
                    fontSize: 25,
                  ),
                ),
          ),
          home: FutureBuilder(
            future: verifyCredentials(),
            builder: (ctx, findedUser) =>
                findedUser.connectionState == ConnectionState.waiting
                    ? NoConnection()
                    : LayoutContent(),
          )),
    );
  }
}

class NoConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color.fromRGBO(0, 117, 255, 1),
              const Color.fromRGBO(75, 158, 255, 0.95),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }
}
