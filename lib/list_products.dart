import 'package:isiine/json/product.dart';
import 'package:isiine/product_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'super_base.dart';

class ListProduct extends StatefulWidget {
  final String url;
  final String title;

  const ListProduct({Key? key, required this.url, required this.title})
      : super(key: key);
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> with Superbase {
  var _key = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((timeStamp) => _key.currentState?.show());
  }

  List<Product> _list = [];

  Future<void> loadProducts() {
    return ajax(
        url: widget.url,
        onValue: (object, url) {
          setState(() {
            _list = (object['data'] as Iterable)
                .map((e) => Product.fromJson(e))
                .toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      body: RefreshIndicator(
        key: _key,
        onRefresh: loadProducts,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 2.7 / 4),
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return ProductItem(product: _list[index]);
            }),
      ),
    );
  }
}
