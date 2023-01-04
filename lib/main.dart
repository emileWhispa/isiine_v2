import 'dart:convert';

import 'package:isiine/authentication.dart';
import 'package:isiine/cart.dart';
import 'package:isiine/categories.dart';
import 'package:isiine/products.dart';
import 'package:isiine/profile.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as b2;
import 'package:get/get.dart';

import 'json/user.dart';
import 'json/vendor.dart';
import 'vendor_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.grey.shade200,
          appBarTheme: AppBarTheme(
              actionsIconTheme: IconThemeData(color: Colors.red),
              elevation: 2.2,
              textTheme: TextTheme(
                  headline6: Theme.of(context)
                      .primaryTextTheme
                      .headline6
                      ?.copyWith(color: Colors.black)),
              iconTheme: IconThemeData(color: Colors.red),
              backgroundColor: Colors.white)),
      home: MyHomePage(title: 'China kigali'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final User? user;
  MyHomePage({Key? key, required this.title, this.user}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with Superbase {
  int _counter = 0;
  int cartCount = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int selected = 0;

  String? _token;


  void cartCounter(int d, {bool? increment}) {
    setState(() {
      cartCount = increment == true ? d + cartCount : d;
    });
  }

  bool _loading = false;

  @override
  void initState() {
    _user = widget.user;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      this.loadToken();
      var string = (await prefs).getString(userKey);
      if (string != null) {
        _user = User.fromJson(jsonDecode(string));
        setState(() {
          _loading = false;
        });
      }else {
        string = (await prefs).getString(vendorKey);
        if( string != null) {
          var vendor = Vendor.fromJson(jsonDecode(string));
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      VendorScreen(vendor: vendor,)));
        }else{
          setState(() {
            _loading = false;
          });
        }
      }


    });
  }

  void loadToken() async {
    _token = await findToken;
    this.ajax(
        url:
            "token?username=isiine&key=04dfe1f6e2d25c8073dc7237150f9fb67541186b&token=${_token ?? ""}",
        server: true,
        onValue: (source, url) async {
          _token = source['token'];
          (await prefs).setString("token", _token!);
        });
  }

  var _cartKey = new GlobalKey<CartState>();

  User? _user;

  @override
  Widget build(BuildContext context) {
    return _loading ? Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ) : Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          IndexedStack(
            index: selected,
            children: [
              Products(cartCounter: cartCounter),
              Cart(
                key: _cartKey,
                cartCounter: cartCounter,
              ),
              Categories(cartCounter: cartCounter),
              Profile(
                user: _user,
                refreshUser: () async {
                  _user = await findUser;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 3 && _user == null) {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => Authentication()));
            return;
          }
          setState(() {
            selected = i;
            if (i == 1) {
              _cartKey.currentState?.reLoad();
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 2,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: b2.Badge(
                  elevation: 0,
                  showBadge: cartCount != 0,
                  badgeContent: Text(
                    "$cartCount",
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Icon(Icons.shopping_cart_rounded)),
              label: "Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded), label: "Categories"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Me"),
        ],
      ),
    );
  }
}
