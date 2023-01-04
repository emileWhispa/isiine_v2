import 'package:isiine/json/category.dart';
import 'package:isiine/product_item.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/material.dart';

import 'json/product.dart';

class ProductCategory extends StatefulWidget {
  final Category category;

  const ProductCategory({Key? key, required this.category}) : super(key: key);
  @override
  _ProductCategoryState createState() => _ProductCategoryState();
}

class _ProductCategoryState extends State<ProductCategory> with Superbase {
  List<Product> _list = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => this.loadProducts());
  }

  bool _loading = false;

  void loadProducts() async {
    setState(() {
      _loading = true;
    });
    await ajax(
        url: "categories/products?category_id=${widget.category.id}",
        onValue: (source, url) {
          print(source);
          setState(() {
            if (source is Map && source['data'] != null) {
              _list = (source['data'] as Iterable)
                  .map((e) => Product.fromJson(e))
                  .toList();
            }
          });
        });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category.category}",
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, childAspectRatio: 2.7 / 4),
              itemBuilder: (context, index) {
                return ProductItem(
                  product: _list[index],
                );
              },
              itemCount: _list.length),
    );
  }
}
