import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isiine/json/product.dart';
import 'package:isiine/json/vendor.dart';
import 'package:isiine/product_item.dart';
import 'package:isiine/super_base.dart';

class VendorProduct extends StatefulWidget {
  final Vendor vendor;

  const VendorProduct({Key? key, required this.vendor}) : super(key: key);

  @override
  _VendorProductState createState() => _VendorProductState();
}

class _VendorProductState extends State<VendorProduct> with Superbase {
  List<Product> _list = [];

  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => this.loadProducts());
  }

  void loadProducts() {
    ajax(
        url: "vendors/products?vendor_id=${widget.vendor.id}",
        onValue: (object, url) {
          setState(() {
            _list = (object['data'] as Iterable?)
                    ?.map((e) => Product.fromJson(e))
                    .toList() ??
                [];
            _loading = false;
          });
        },
        error: (s, b) {
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.vendor.name}"),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              itemCount: _list.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 2.7/4),
              itemBuilder: (context, index) {
                return ProductItem(product: _list[index]);
              }),
    );
  }
}
