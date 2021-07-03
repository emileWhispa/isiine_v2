import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:isiine/json/product.dart';
import 'package:isiine/product_details.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final bool isSpecial;
  final Notifier? cartCounter;

  const ProductItem(
      {Key? key,
      required this.product,
      this.isSpecial: false,
      this.cartCounter})
      : super(key: key);
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> with Superbase {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => ProductDetails(
                        pro: widget.product,
                        cartCounter: widget.cartCounter,
                      )));
        },
        child: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  "${widget.product.image}"),
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      child: widget.product.hasDiscount
                          ? Container(
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.all(3),
                              child: Text(
                                "${widget.product.discountPercent}",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : SizedBox.shrink(),
                      right: 10,
                      top: 10,
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  child: Text(
                    "${widget.product.product}",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: widget.isSpecial
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  "${fmtNbr(widget.product.price)} RWF",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  "${fmtNbr(widget.product.discountedPrice ?? 0)} RWF",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              "${fmtNbr(widget.product.price)} RWF",
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                  ),
                  Container(
                    height: 35,
                    width: 35,
                    child: RawMaterialButton(
                      shape: new CircleBorder(),
                      onPressed: () {
                        showAddCart(context, widget.product,
                            cartCounter: widget.cartCounter);
                      },
                      child: Icon(
                       MaterialCommunityIcons.cart_arrow_down,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
