class OrderItem {
  String id;
  String product;
  int? category;
  int amount;
  int? _price;
  int? _bigPrice;
  String image;
  String description;
  int? discountedPrice;

  bool selected = false;
  bool deleting = false;
  int views;

  int quantity = 1;

  OrderItem.fromJson(Map<String, dynamic> json)
      : id = json['product_id'],
        product = json['product_name'],
        views = int.tryParse("${json['product_views']}") ?? 0,
        amount = int.tryParse(json['amount'] ?? "0") ?? 0,
        description = json['product_description'],
        _price = int.tryParse(json['product_price'] ?? "0.0") ?? 0,
        discountedPrice =
            int.tryParse(json['product_discount_price'] ?? "0.0") ?? 0,
        quantity = int.tryParse("${json['order_qty']}") ?? 0,
        image = json['product_image'];

  int get price => _price ?? 0;

  int get bigPrice => _bigPrice ?? 0;

  double get save => 100 - (price * 100 / (bigPrice == 0.0 ? 1 : bigPrice));

  Map<String, dynamic> toJson() => {
        "product_id": id,
        "product": product,
        "main_category": category,
        "price": "$_price",
        "list_price": "$_bigPrice",
        "main_pair": {
          "detailed": {"image_path": image}
        }
      };
}
