import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart' as gt;
import 'package:shared_preferences/shared_preferences.dart';

import 'json/product.dart';
import 'json/user.dart';

typedef Notifier = Function(int count, {bool increment});

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}

class Superbase {
  String get bigBase => "https://isiine.rw/api/";

  String token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBjcGFpLnRlY2giLCJleHAiOjE2MDEyMTIzODF9.Lw8Acj_ldP4AakcucN3zKM7I1kTEqKTQc70VdfTga827oz1afKP9Gv54veYBVE0a4PEwN7jPt0xqefV_VsIMyg";

  String get server => "$bigBase";

//  String server = "https://licensing.rura.rw/api/v1/";

  String userKey = "user-key-val";

  Color color = Color(0xffef3829);

  List<MaterialColor> get colors =>
      Colors.primaries.where((element) => element != Colors.yellow).toList();

  String url(String url) => "$server$url";

  Future<void> save(String key, dynamic val) {
    return saveVal(key, jsonEncode(val));
  }

  var platform = MethodChannel('app.channel.shared.data');

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  Future<void> saveVal(String key, String value) async {
    (await prefs).setString(key, value);
    return Future.value();
  }

  String fmt(String test) {
    return test.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  String fmtNbr(num test) {
    return fmt(test.toString());
  }

  showAddCart(BuildContext context, Product pro, {Notifier? cartCounter}) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) {
          Product p = pro;
          var price = pro.price;

          bool adding = false;

          return StatefulBuilder(builder: (context, newState) {
            addToCart() async {
              print("Adding.....");
              newState(() {
                adding = true;
              });
              await ajax(
                  url:
                      "cart/add?token=${await findToken}&product_id=${pro.id}&quantity=${pro.quantity}",
                  onValue: (source, url) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    cartCounter?.call(pro.quantity, increment: true);
                    gt.Get.snackbar("Success", source['message'],
                        icon: Icon(Icons.check_circle_rounded));
                  });
              newState(() {
                adding = false;
              });
            }

            return Container(
                height: 160,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image(
                      image: CachedNetworkImageProvider("${p.image}"),
                      width: 100,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 110,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: Text("${p.product}",
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                              // Container(
                              //   height: 30,
                              //   width: 30,
                              //   child: RawMaterialButton(
                              //     elevation: 0,
                              //     shape: new CircleBorder(),
                              //     onPressed: () {
                              //       Navigator.of(context).pop();
                              //     },
                              //     child: Icon(
                              //       Icons.close_rounded,
                              //       color: Colors.redAccent,
                              //       size: 15,
                              //     ),
                              //   ),
                              // ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                          ),
                          // Padding(
                          //     padding:
                          //         EdgeInsets.only(left: 10, right: 10, top: 5),
                          //     child: Text(
                          //       "Minimum: 1",
                          //       overflow: TextOverflow.ellipsis,
                          //       textAlign: TextAlign.start,
                          //       maxLines: 1,
                          //       style: TextStyle(color: Colors.grey),
                          //     )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                child: Text(
                                  "${fmtNbr(p.price)} RWF",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    child: RawMaterialButton(
                                      elevation: 0,
                                      shape: new CircleBorder(),
                                      fillColor: Theme.of(context).accentColor,
                                      onPressed: () {
                                        p.quantity--;
                                        newState(() => p = p);
                                      },
                                      child: Icon(
                                        Icons.remove,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${p.quantity}"),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    margin: EdgeInsets.only(right: 7),
                                    child: RawMaterialButton(
                                      elevation: 0,
                                      shape: new CircleBorder(),
                                      fillColor: Theme.of(context).accentColor,
                                      onPressed: () {
                                        p.quantity++;
                                        newState(() => p = p);
                                      },
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 10),
                            child: RaisedButton.icon(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7)),
                              onPressed: adding
                                  ? null
                                  : () {
                                      addToCart();
                                      // Navigator.of(context).pop();
                                    },
                              icon: adding
                                  ? Icon(
                                      Icons.close_rounded,
                                      color: Colors.transparent,
                                    )
                                  : Icon(MaterialCommunityIcons.cart_arrow_down),
                              label: adding
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text("Add  to cart"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ));
          });
        });
  }

  Future<String?> get findToken async => (await prefs).getString("token");
  Future<User?> get findUser async {
    var string = (await prefs).getString(userKey);
    if (string != null) {
      return User.fromJson(jsonDecode(string));
    }
    return null;
  }

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  bool canDecode(String jsonString) {
    var decodeSucceeded = false;
    try {
      json.decode(jsonString);
      decodeSucceeded = true;
    } on FormatException {}
    return decodeSucceeded;
  }

  Future<void> ajax(
      {required String url,
      String method: "GET",
      FormData? data,
      Map<String, dynamic>? map,
      bool server: true,
      bool auth: true,
      bool local: false,
      bool base2: false,
      String? authKey,
      bool json: true,
      void Function(CancelToken token)? onCancelToken,
      bool absolutePath: false,
      ResponseType responseType: ResponseType.json,
      bool localSave: false,
      String? jsonData,
      void Function(dynamic response, String url)? onValue,
      void Function()? onEnd,
      void Function(dynamic response, String url)? error}) async {
    url = absolutePath ? url : this.url(url);

    Map<String, String> headers = new Map<String, String>();

    var prf = await prefs;
    if (auth && authKey != null) {
      headers['token'] = '$authKey';
    }

    Options opt = Options(
        responseType: responseType,
        headers: headers,
        receiveDataWhenStatusError: true,
        sendTimeout: 30000,
        receiveTimeout: 30000);

    if (!server) {
      String? val = prf.getString(url);
      bool t = onValue != null && val != null;
      local = local && t;
      localSave = localSave && t;
      var c = (t && json && canDecode(val)) || !json;
      t = t && c;
      if (t) onValue(json ? jsonDecode(val) : val, url);
    }

    if (local) {
      if (onEnd != null) onEnd();
      return Future.value();
    }

    CancelToken token = CancelToken();

    if (onCancelToken != null) {
      onCancelToken(token);
    }

    Future<Response> future = method.toUpperCase() == "POST"
        ? Dio().post(url,
            data: jsonData ?? map ?? data, options: opt, cancelToken: token)
        : method.toUpperCase() == "PUT"
            ? Dio().put(url,
                data: jsonData ?? map ?? data, options: opt, cancelToken: token)
            : method.toUpperCase() == "DELETE"
                ? Dio().delete(url,
                    data: jsonData ?? map ?? data,
                    options: opt,
                    cancelToken: token)
                : Dio().get(url, options: opt, cancelToken: token);

    try {
      Response response = await future;
      dynamic data = response.data;
      if (response.statusCode == 200) {
        //var cond = (data is String && json && canDecode(data)) || !json;
        if (!server) this.saveVal(url, jsonEncode(data));

        if (onValue != null && !localSave)
          onValue(data, url);
        else if (error != null) error(data, url);
      } else if (error != null) {
        error(data, url);
      }
    } on DioError catch (e) {
      //if (e.response != null) {
      var resp = e.response != null ? e.response!.data : e.message;
      if (error != null) error(resp, url);
      //}
    }

    if (onEnd != null) onEnd();
    return Future.value();
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
