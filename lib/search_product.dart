import 'package:isiine/json/product.dart';
import 'package:isiine/product_item.dart';
import 'package:isiine/super_base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchProduct extends StatefulWidget {
  final String? query;

  const SearchProduct({Key? key, this.query}) : super(key: key);

  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> with Superbase {
  @override
  void didUpdateWidget(covariant SearchProduct oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.query != null && widget.query != oldWidget.query) {
      loadProducts();
    }
  }

  List<Product> _list = [];

  bool _loading = true;

  List<CancelToken> _tokens = [];

  void loadProducts() {
    setState(() {
      _loading = true;
    });

    _tokens.forEach((element) {
      if (!element.isCancelled) {
        element.cancel("cancel");
      }
    });

    ajax(
        url: "products/search?query=${widget.query}",
        onCancelToken: (token) {
          _tokens.add(token);
        },
        error: (s, v) {
          if (s != "cancel") {
            setState(() {
              _loading = false;
            });
          }
        },
        onValue: (source, url) {
          setState(() {
            _loading = false;
          });
          setState(() {
            if (source['data'] != null)
              _list = (source['data'] as Iterable)
                  .map((e) => Product.fromJson(e))
                  .toList();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 2.7 / 4),
              itemBuilder: (context, index) =>
                  ProductItem(product: _list[index]),
              itemCount: _list.length,
            ),
    );
  }
}
