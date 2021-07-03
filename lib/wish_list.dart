import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'json/product.dart';

class Wishlist extends StatefulWidget {
  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> with Superbase {
  List<Product> productsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((timeStamp) => this.loadWishlist());
  }

  bool _loading = false;

  void loadWishlist() async {
    setState(() {
      _loading = true;
    });
    await ajax(
        url: "wishlist/?token=${await findToken}",
        onValue: (obj, url) {
          setState(() {
            if (obj is Map && obj['data'] != null)
              productsList = (obj['data'] as Iterable)
                  .map((e) => Product.fromJson(e))
                  .toList();
          });
        });
    setState(() {
      _loading = false;
    });
  }

  showLoading(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                kIsWeb
                    ? CircularProgressIndicator()
                    : Platform.isAndroid
                        ? CircularProgressIndicator()
                        : CupertinoActivityIndicator(),
                SizedBox(
                  width: 10,
                ),
                Text("$msg"),
              ],
            ),
          );
        });
  }

  void removeCart(Product pro) async {
    setState(() {
      pro.deleting = true;
    });
    await this.ajax(
        url: "wishlist/delete?token=${await findToken}&product_id=${pro.id}",
        onValue: (source, url) {
          Get.snackbar("Success", source['message']);
          setState(() {
            productsList.removeWhere((element) => element.id == pro.id);
          });
        });

    setState(() {
      pro.deleting = false;
    });
  }

  void addThemToCart() async {
    showLoading("Adding items to cart ...");
    await this.ajax(
        url: "wishlist/addtocart?token=${await findToken}",
        onValue: (source, url) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Get.snackbar("Success", source['message']);
        },
        error: (s, v) => print(s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
      ),
      floatingActionButton: productsList.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: addThemToCart, label: Text("Add To Cart"))
          : null,
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                var pro = productsList[index];
                return Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7))),
                    child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 70,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image(
                                image:
                                    CachedNetworkImageProvider("${pro.image}"),
                                width: 70,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Expanded(
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10, top: 10),
                                              child: Text("${pro.product}",
                                                  textAlign: TextAlign.start,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(7),
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffFDE6E6),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25))),
                                                  child: Text(
                                                    "${fmtNbr(pro.price)} RWF",
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              pro.deleting
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () => this.removeCart(pro),
                                      icon: Icon(Icons.close_rounded,
                                          color: color),
                                    ),
                            ],
                          ),
                        )));
              }),
    );
  }
}
