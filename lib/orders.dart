import 'package:cached_network_image/cached_network_image.dart';
import 'package:isiine/json/order.dart';
import 'package:isiine/json/order_history.dart';
import 'package:isiine/order_details.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with Superbase {
  List<Order> _orders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => this.loadItems());
  }

  bool _loading = false;

  void loadItems() async {
    setState(() {
      _loading = true;
    });
    await ajax(
        url: "account/orders?customer_id=${(await findUser)?.id}",
        onValue: (source, url) {
          print(source);
          setState(() {
            if (source is Map && source['data'] != null)
              _orders = (source['data'] as Iterable)
                  .map((e) => Order.fromJson(e))
                  .toList();
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
        title: Text("My orders"),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                var order = _orders[index];
                return Card(
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
                );
              }),
    );
  }
}
