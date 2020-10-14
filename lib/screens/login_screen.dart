import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:myShoppingList/models/Login.dart';
import 'package:myShoppingList/store/actions/login_action.dart';
import 'dart:math' as math;

import 'package:myShoppingList/store/store.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
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
          child: Container(
            width: double.infinity,
            child: Center(
              child: ListView(
                children: [
                  SizedBox(height: 50),
                  CircleAvatar(
                    minRadius: 66.5,
                    maxRadius: 66.5,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                      size: 80,
                    ),
                  ),
                  SizedBox(height: 50),
                  Stack(
                    children: [
                      MyForm(),
                      Transform.rotate(
                        angle: -math.pi / 7,
                        child: Text(
                          'Only Friends',
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 27,
                              ),
                        ),
                      ),
                    ],
                    overflow: Overflow.visible,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyForm extends StatelessWidget {
  final TextEditingController _userController = TextEditingController(text: '');
  final TextEditingController _passController = TextEditingController(text: '');

  void submit(BuildContext context) async {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      _showSnackBar(context, 'Los campos no pueden estar vacios');
      return;
    }

    Login credentials = Login(user: user, password: pass);
    
    bool isValid = await login(credentials);
    if (!isValid) _showSnackBar(context, 'I said, Only friends!');
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: SizedBox(
        width: width - (width * 0.3),
        height: height - (height * 0.5),
        child: Card(
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InputField(text: 'Usuario', controller: _userController),
              InputField(text: 'Contraseña', controller: _passController),
              StoreConnector<AppState, bool>(
                distinct: true,
                converter: (store) => store.state.userState.isLoading,
                builder: (ctx, loading) {
                  if (loading)
                    return Center(child: CircularProgressIndicator());
                  return RaisedButton(
                    onPressed: () => submit(context),
                    child: Text('Entrar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    Key key,
    String text,
    TextEditingController controller,
  })  : _text = text,
        _controller = controller,
        super(key: key);

  final String _text;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = width - (width * 0.3);
    bool fromUser = _text == 'Usuario';
    return SizedBox(
      width: cardWidth - (cardWidth * 0.3),
      child: TextFormField(
        controller: _controller,
        autocorrect: false,
        enableSuggestions: fromUser,
        obscureText: !fromUser,
        keyboardType: fromUser
            ? TextInputType.emailAddress
            : TextInputType.visiblePassword,
        decoration: InputDecoration(
          labelText: _text,
          labelStyle: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: 20,
              ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
