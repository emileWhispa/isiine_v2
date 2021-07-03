import 'package:cached_network_image/cached_network_image.dart';
import 'package:isiine/json/order_item.dart';
import 'package:isiine/json/user.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'json/order.dart';
import 'json/order_history.dart';
import 'json/product.dart';

class OrderDetail extends StatefulWidget {
  final Order order;
  final User? user;

  const OrderDetail({Key? key, required this.order, required this.user})
      : super(key: key);
  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> with Superbase {
  Order get order => widget.order;
  List<OrderItem> productsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((timeStamp) => this.loadOrders());
  }

  bool _loading = false;

  void loadOrders() async {
    setState(() {
      _loading = true;
    });
    await ajax(
        url: "account/order_details?order_id=${order.id}",
        onValue: (obj, url) {
          print(obj);
          setState(() {
            if (obj is Map && obj['order_products'] != null) {
              productsList = (obj['order_products'] as Iterable)
                  .map((e) => OrderItem.fromJson(e))
                  .toList();
              _histories = (obj['order_history'] as Iterable)
                  .map((e) => OrderHistory.fromJson(e))
                  .toList();
            }
          });
        });
    setState(() {
      _loading = false;
    });
  }

  List<OrderHistory> _histories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: InkWell(
              onTap: () async {
                var usr = await findUser;
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => OrderDetail(
                              order: order,
                              user: usr,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Id : #${order.id}"),
                    SizedBox(
                      height: 3,
                    ),
                    Text("Order track Id : ${order.trackId}"),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "${fmtNbr(order.total)} RWF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text("${order.time ?? ""}"),
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
          ),
          Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: [
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: productsList.length,
                            itemBuilder: (context, index) {
                              var pro = productsList[index];
                              return Card(
                                  elevation: 0,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7))),
                                  child: InkWell(
                                      onTap: () {},
                                      child: Container(
                                        height: 70,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Image(
                                              image: CachedNetworkImageProvider(
                                                  "${pro.image}"),
                                              width: 70,
                                              errorBuilder: (c, x, v) =>
                                                  Container(
                                                width: 70,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 10),
                                                            child: Text(
                                                                "${pro.product}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(7),
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            4),
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xffFDE6E6),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(25))),
                                                                child: Text(
                                                                  "${fmtNbr(pro.price)} RWF",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12),
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
                                          ],
                                        ),
                                      )));
                            }),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Order History",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(fontSize: 25),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _histories.length,
                                itemBuilder: (context, index) {
                                  var history = _histories[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green),
                                            height: 24,
                                            width: 24,
                                            margin: EdgeInsets.only(right: 10),
                                            child: Center(
                                              child: Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "${history.historyTime}",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                "${history.historyEvent}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              )
                                            ],
                                          ))
                                        ],
                                      ),
                                      Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.green,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 0),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Shipping address",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(fontSize: 25),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("${widget.user?.district}"),
                                Text("${widget.user?.street}"),
                                Text("${widget.user?.address}"),
                                Text("${widget.user?.address2}"),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
        ],
      ),
    );
  }
}
