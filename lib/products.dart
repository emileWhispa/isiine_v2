import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:isiine/json/slide.dart';
import 'package:isiine/list_products.dart';
import 'package:isiine/product_details.dart';
import 'package:isiine/product_item.dart';
import 'package:isiine/search_delegate.dart';
import 'package:isiine/search_product.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'json/category.dart';
import 'json/product.dart';
import 'super_base.dart';

typedef Notifier = Function(int count, {bool increment});

class Products extends StatefulWidget {
  final Notifier cartCounter;

  const Products({Key? key, required this.cartCounter}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> with Superbase {
  bool loadingProducts = false;
  bool loadingSpecialProducts = false;
  bool loadingBestSellingProducts = false;
  bool loadingNewArrivals = false;
  List<Product> productsList = [];
  List<Product> specialProductsList = [];
  List<Product> bestSellingList = [];
  List<Product> newArrivalsList = [];

  bool loadingCategories = true;
  List<Category> categoriesList = [];
  List<Slide> slides = [];

  String? _token;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getProducts();
      getSlide();
      getCategories();
    });

    super.initState();
  }

  void getSlide() {
    this.ajax(
        url: "slides",
        server: false,
        onValue: (object, url) {
          setState(() {
            slides = (object['data'] as Iterable)
                .map((e) => Slide.fromJson(e))
                .toList();
          });
        },
        onEnd: () {
          setState(() {
            loadingCategories = false;
          });
        });
  }

  void goToMore(String url, String title) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ListProduct(
                  url: url,
                  title: title,
                )));
  }

  getCategories() async {
    setState(() {
      loadingCategories = true;
    });

    this.ajax(
        url: "categories",
        onValue: (object, url) {
          setState(() {
            loadingCategories = false;
            categoriesList = (object['data'] as Iterable)
                .map((e) => Category.fromJson(e))
                .toList();
          });
        },
        onEnd: () {
          setState(() {
            loadingCategories = false;
          });
        });
  }

////////////////////
  getProducts() async {
    setState(() {
      loadingProducts = true;
      loadingNewArrivals = true;
      loadingSpecialProducts = true;
      loadingBestSellingProducts = true;
    });

    this.ajax(
        url: "products/featured?limit=12",
        server: false,
        onValue: (object, url) {
          setState(() {
            loadingProducts = false;
            productsList = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
          });
        },
        onEnd: () {
          setState(() {
            loadingProducts = false;
          });
        });

    this.ajax(
        url: "products/newarrivals?limit=12",
        server: false,
        onValue: (object, url) {
          setState(() {
            loadingNewArrivals = false;
            newArrivalsList = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
          });
        },
        onEnd: () {
          setState(() {
            loadingNewArrivals = false;
          });
        });

    this.ajax(
        url: "products/specials?limit=12",
        server: false,
        onValue: (object, url) {
          setState(() {
            loadingSpecialProducts = false;
            specialProductsList = (object['data'] as Iterable?)
                ?.map((e) => Product.fromJson(e))
                .toList() ?? [];
          });
        },
        onEnd: () {
          setState(() {
            loadingSpecialProducts = false;
          });
        });

    this.ajax(
        url: "products/bestseller?limit=12",
        server: false,
        onValue: (object, url) {
          setState(() {
            loadingBestSellingProducts = false;
            bestSellingList = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
          });
        },
        onEnd: () {
          setState(() {
            loadingBestSellingProducts = false;
          });
        });
  }

  void cartCounter(int count, {bool? increment}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Container(height: 47, child: Image.asset("assets/logo.jpg")),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        actions: [
//            IconButton(
//                icon: Icon(Icons.notifications_rounded), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.search_rounded),
              color: color,
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SearchDemoSearchDelegate((query) {
                      return SearchProduct(
                        query: query,
                      );
                    }));
              }),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            child: slides.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    child: Text("Please wait...",
                        style: TextStyle(color: Colors.grey)),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 10),
                    child: CarouselSlider.builder(
                        itemCount: slides.length,
                        itemBuilder: (context, index, i) {
                          return Container(
                            child: Image(
                                image: CachedNetworkImageProvider(
                                    slides[index].image)),
                          );
                        },
                        options: CarouselOptions(autoPlay: true)),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                child: Text(
                  "New arrivals",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 28.0,
                  color: color,
                ),
                onPressed: () =>
                    goToMore("products/newarrivals?limit=50", "New Arrivals"),
              )
            ],
          ),
          loadingNewArrivals
              ? Container(
                  height: 230,
                  alignment: Alignment.center,
                  child: Text("Loading products...",
                      style: TextStyle(color: Colors.grey)),
                )
              : !loadingNewArrivals && newArrivalsList.length == 0
                  ? Container(
                      height: 230,
                      alignment: Alignment.center,
                      child: Text(
                        "Error loading products, try again later",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
            height: 180,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 5.7 / 4),
                          itemCount: newArrivalsList.length,
                          itemBuilder: (context, index) {
                            return ProductItem(
                              product: newArrivalsList[index],
                              cartCounter: widget.cartCounter,
                            );
                          }),
                    ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                child: Text(
                  "Special Products",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 28.0,
                  color: color,
                ),
                onPressed: () =>
                    goToMore("products/specials?limit=50", "Special Products"),
              )
            ],
          ),
          loadingSpecialProducts
              ? Container(
                  height: 230,
                  alignment: Alignment.center,
                  child: Text("Loading products...",
                      style: TextStyle(color: Colors.grey)),
                )
              : !loadingSpecialProducts && specialProductsList.length == 0
                  ? Container(
                      height: 230,
                      alignment: Alignment.center,
                      child: Text(
                        "Error loading products, try again later",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
            height: 180,
                    child: GridView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5.7 / 4),
                        itemBuilder: (context, index) {
                          return ProductItem(
                            product: specialProductsList[index],
                            isSpecial: true,
                            cartCounter: widget.cartCounter,
                          );
                        },
                        itemCount: specialProductsList.length),
                  ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                child: Text(
                  "Featured Products",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 28.0,
                  color: color,
                ),
                onPressed: () =>
                    goToMore("products/featured?limit=50", "Featured Products"),
              )
            ],
          ),
          loadingProducts
              ? Container(
                  height: 230,
                  alignment: Alignment.center,
                  child: Text("Loading products...",
                      style: TextStyle(color: Colors.grey)),
                )
              : !loadingProducts && productsList.length == 0
                  ? Container(
                      height: 230,
                      alignment: Alignment.center,
                      child: Text(
                        "Error loading products, try again later",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
            height: 180,
                    child: GridView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5.7 / 4),
                        itemBuilder: (context, index) {
                          return ProductItem(
                            product: productsList[index],
                            cartCounter: widget.cartCounter,
                          );
                        },
                        itemCount: productsList.length),
                  ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
                child: Text(
                  "Best Selling Products",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 28.0,
                  color: color,
                ),
                onPressed: () => goToMore(
                    "products/bestseller?limit=50", "Best Selling Products"),
              )
            ],
          ),
          loadingBestSellingProducts
              ? Container(
                  height: 230,
                  alignment: Alignment.center,
                  child: Text("Loading products...",
                      style: TextStyle(color: Colors.grey)),
                )
              : !loadingBestSellingProducts && bestSellingList.length == 0
                  ? Container(
                      height: 230,
                      alignment: Alignment.center,
                      child: Text(
                        "Error loading products, try again later",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
            height: 180,
                    child: GridView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5.7 / 4),
                        itemBuilder: (context, index) {
                          return ProductItem(
                            product: bestSellingList[index],
                            cartCounter: widget.cartCounter,
                          );
                        },
                        itemCount: bestSellingList.length),
                  )
        ],
      ),
    );
  }
}
