import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isiine/super_base.dart';
import 'package:isiine/vendor_product.dart';

import 'json/order.dart';
import 'json/vendor.dart';
import 'order_details.dart';

class VendorScreen extends StatefulWidget{
  final Vendor vendor;

  const VendorScreen({Key? key,required this.vendor}) : super(key: key);
  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> with Superbase{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)=>this.getSummary());

    _timer = Timer.periodic(Duration(seconds: 60), (timer)=>this.getSummary());
  }

  int? products;
  int? sales;
  int? orders;
  double? wallet;

  List<Order> _orders = [];
  String? _message;

  bool _loading = true;

  Timer? _timer;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  void getOrders(){
    this.ajax(url: "vendor/orders/?vendor_id=${widget.vendor.id}",onValue: (source,url){
      _orders = (source['data'] as Iterable?)?.map((e) => Order.fromJson(e)).toList() ?? [];
      _message = source['message'];
      setState(() {
        _loading =false;
      });
    },error: (s,v)=>setState(()=>_loading = false));
  }

  void getSummary(){
    getOrders();
    ajax(url: "vendor/summary?vendor_id=${widget.vendor.id}",onValue: (source,url){
      print(source);
      setState(() {
        products = source['data']['vendor_products'];
        sales = source['data']['vendor_sales'];
        orders = source['data']['vendor_orders'];
        wallet = double.tryParse(source['data']['vendor_wallet']);
      });
    });
  }

  Widget get summary=>
      Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Card(
                  color: Color(0xffffe1e3),
                  child: Container(
                    height: 110,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Orders",style: Theme.of(context).textTheme.headline6,),
                          ),
                          Text("${orders ?? 0}",style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontSize: 24
                          ),)
                        ],
                      ),
                    ),
                  ),
                )),
                Expanded(child: Card(
                  color: Color(0xffd9f3da),
                  child: Container(
                    height: 110,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Wallet",style: Theme.of(context).textTheme.headline6,),
                          ),
                          Text("${fmtNbr((wallet ?? 0.0).toInt())} Rwf",style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 24
                          ),)
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
            Row(
              children: [
                Expanded(child: Card(
                  color: Color(0xffd7eaf9),
                  child: Container(
                    height: 110,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context, CupertinoPageRoute(builder: (context)=>VendorProduct(vendor: widget.vendor)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("Products",style: Theme.of(context).textTheme.headline6,),
                            ),
                            Text("${fmtNbr(products ?? 0)}",style: Theme.of(context).textTheme.headline4!.copyWith(
                                fontSize: 24
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                Expanded(child: Card(
                  color: Color(0xfffcf8db),
                  child: Container(
                    height: 110,
                    child: InkWell(
                      onTap: (){
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("Sales",style: Theme.of(context).textTheme.headline6,),
                            ),
                            Text("${fmtNbr(sales ?? 0)}",style: Theme.of(context).textTheme.headline4!.copyWith(
                                fontSize: 24
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    print( widget.vendor.image);
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        leading: CachedNetworkImage(imageUrl: widget.vendor.image,),
        title: Text("${widget.vendor.name}"),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.lock_open))
        ],
      ),
      body: ListView.builder(itemCount: _orders.length + 1,itemBuilder: (context,index){

        index = index -1;

        if( index < 0){

          if(_orders.isEmpty){
            return Column(
              children: [
                summary,
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: _loading ? CircularProgressIndicator() : Column(
                    children: [
                      Icon(Icons.info_outlined,size: 40,color: Theme.of(context).textTheme.headline5!.color,),
                      Text("${_message??""}",style: Theme.of(context).textTheme.headline5,),
                    ],
                  ),
                )
              ],
            );
          }

          return summary;
        }

        var order = _orders[index];

        return Container(
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: () async {
                var usr = await findUser;
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            OrderDetail(order: order, user: usr)));
              },
              child: Row(
                children: [
                  Image(
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      image:
                      CachedNetworkImageProvider(order.image ?? "")),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${order.name}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "${fmtNbr(order.total)} RWF",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Text("${order.time ?? ""}"),
                            ],
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text("Order track Id : ${order.trackId}"),
                          // order.notes?.trim().isNotEmpty == true
                          //     ? Padding(
                          //         padding: const EdgeInsets.only(top: 3),
                          //         child: Text("${order.notes}"),
                          //       )
                          //     : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      })
    );
  }
}