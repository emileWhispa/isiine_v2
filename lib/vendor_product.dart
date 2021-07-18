import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isiine/json/product.dart';
import 'package:isiine/super_base.dart';

import 'json/vendor.dart';

class VendorProduct extends StatefulWidget{
  final Vendor vendor;

  const VendorProduct({Key? key,required this.vendor}) : super(key: key);
  @override
  _VendorProductState createState() => _VendorProductState();
}

class _VendorProductState extends State<VendorProduct> with Superbase {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) =>this.loadProducts());
  }

  List<Product> _list = [];

  void loadProducts(){
    ajax(url: "vendor/products/?vendor_id=${widget.vendor.id}",onValue: (source,url){
      _list = (source['data'] as Iterable?)?.map((e) => Product.fromJson(e)).toList() ?? [];
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Products"),
      ),
      backgroundColor: Theme.of(context).cardColor,
      body: ListView.builder(itemCount: _list.length,itemBuilder: (context,index){
        var pro = _list[index];
        return Card(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10),child: Image(image: CachedNetworkImageProvider(pro.image),width: 90,height: 90,)),
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("${pro.product}",style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),),
                      SizedBox(height: 10),
                      Text("${fmtNbr(pro.price)} RWF",style: TextStyle(
                        fontSize: 17.5
                      ),),
                    ],
                  ),
                ))
              ],
            ),
          ),
        );
      }),
    );
  }
}