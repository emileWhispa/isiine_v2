import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:isiine/product_category.dart';
import 'package:isiine/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'json/category.dart';

class Categories extends StatefulWidget {
  final void Function(int count, {bool increment}) cartCounter;

  const Categories({Key? key, required this.cartCounter}) : super(key: key);
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with Superbase {
  bool loadingCategories = true;
  List<Category> categoriesList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCategories();
    });
  }

  getCategories() async {
    setState(() {
      loadingCategories = true;
    });

    this.ajax(
        url: "categories",
        server: false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            "Categories",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: loadingCategories
            ? Container(
                alignment: Alignment.center,
                child: Text("Loading categories...",
                    style: TextStyle(color: Colors.grey)),
              )
            : !loadingCategories && categoriesList.length == 0
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Unable to load categories, try again later",
                      style: TextStyle(color: Colors.grey),
                    ))
                : Container(
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: categoriesList.length,
                        itemBuilder: (context, index) {
                          return Container(
                              child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => ProductCategory(
                                              category:
                                                  categoriesList[index])));
                                },
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      "${categoriesList[index].image}"),
                                  backgroundColor: Colors.white,
                                ),
                                title:
                                    Text("${categoriesList[index].category}"),
                                trailing: Icon(Icons.chevron_right_rounded),
                              ),
                              Wrap(
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: 7,
                                children: categoriesList[index]
                                    .subCategories
                                    ?.map((e) => FilterChip(
                                          label: Text("${e.category}"),
                                          avatar: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    "${e.image}"),
                                          ),
                                          selected: false,
                                          onSelected: (s) {},
                                        ))
                                    .toList() ?? [],
                              )
                            ],
                          ));
                        }),
                  ));
  }
}
