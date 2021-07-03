import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'json/product.dart';
import 'product_item.dart';
import 'super_base.dart';

class ProductDetails extends StatefulWidget {
  final Product pro;
  final Notifier? cartCounter;

  ProductDetails({
    required this.pro,
    this.cartCounter,
  });

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> with Superbase {
  String? _token;

  List feedbacks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      this.loadRelated();
    });
  }

  List<Product> _related = [];
  List<String> images = [];

  void loadRelated() {
    this.ajax(
        url: "product/details?product_id=${widget.pro.id}",
        error: (s,v)=>print(s),
        server: false,
        onValue: (source, url) {
          setState(() {
            _related = (source['data']['related_products'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
            images = (source['data']['product_images'] as Iterable?)
                ?.map((e) => '$e')
                .toList() ?? [];
          });
        });
  }

  bool _processingWishList = false;

  bool _favorite = false;

  void addToWishList() async {
    setState(() {
      _processingWishList = true;
    });
    await ajax(
        url:
            "wishlist/${_favorite ? "delete" : "add"}?token=${await findToken}&product_id=${widget.pro.id}&customer_id=${(await findUser)?.id}",
        onValue: (s, v) {
          print(s);
          Get.snackbar("Success", s['message']);
        });
    setState(() {
      _processingWishList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.pro.product}",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ],
        ),
      ),
      body: Material(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: SizedBox(
                      height: 10,
                    )),
                    SliverToBoxAdapter(
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 180.0,
                        ),
                        items: ( images.isNotEmpty ? images : [widget.pro.image]).map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                  ),
                                  child: Image(
                                    image: CachedNetworkImageProvider(i),
                                    fit: BoxFit.cover,
                                  ));
                            },
                          );
                        }).toList(),
                      ),
                    ),
//          SliverToBoxAdapter(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                Padding(
//                  padding:
//                      EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
//                  child: Text(
//                    "Categories",
//                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                  ),
//                ),
//                IconButton(
//                  splashColor: Config.secondaryColor,
//                  icon: Icon(
//                    Icons.chevron_right,
//                    size: 28.0,
//                    color: Config.primaryColor,
//                  ),
//                  onPressed: () {},
//                )
//              ],
//            ),
//          ),
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10, left: 10, right: 10, bottom: 5),
                            child: Text(
                              "${widget.pro.price} RWF",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          IconButton(
                            splashColor: Theme.of(context).accentColor,
                            icon: _processingWishList
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ))
                                : Icon(
                                    Icons.favorite_outline_rounded,
                                    size: 28.0,
                                    color: color,
                                  ),
                            onPressed:
                                _processingWishList ? null : addToWishList,
                          )
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 5),
                              child: Text(
                                "${widget.pro.description == ".." ? "There is no description for this product" : widget.pro.description}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10, bottom: 5),
                                  child: Text(
                                    "${++widget.pro.views} Views",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 2),
                              child: Text(
                                "Related products",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          childAspectRatio: 2.7 / 4),
                                  itemCount: _related.length,
                                  itemBuilder: (context, index) {
                                    return ProductItem(
                                      product: _related[index],
                                      cartCounter: widget.cartCounter,
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Container(
              //         height: 45,
              //         child: RaisedButton.icon(
              //           color: Theme.of(context).accentColor,
              //           elevation: 0,
              //           onPressed: () {
              //             showAddCart(context, widget.pro);
              //           },
              //           textColor: Colors.white,
              //           icon: Icon(Icons.add_shopping_cart_rounded),
              //           label: Text("Add to cart"),
              //         ),
              //       ),
              //     ),
              //     // Container(
              //     //   height: 45,
              //     //   child: RaisedButton.icon(
              //     //     shape: RoundedRectangleBorder(),
              //     //     elevation: 0,
              //     //     onPressed: () {},
              //     //     textColor: Colors.white,
              //     //     icon: Icon(Icons.share_rounded),
              //     //     label: Text("Share"),
              //     //   ),
              //     // ),
              //   ],
              // )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddCart(context, widget.pro, cartCounter: widget.cartCounter);
        },
        label: Text("Add To Cart"),
        icon: Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
