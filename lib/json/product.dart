class Product {
  String id;
  String product;
  int? category;
  int amount;
  int? _price;
  int? _bigPrice;
  String image;
  String description;
  int? discountedPrice;
  String? discountPercent;
  List<String>? images;

  bool selected = false;
  bool deleting = false;
  int views;

  int quantity = 1;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['product_id'],
        product = json['product_name'],
        views = int.tryParse("${json['product_views']}") ?? 0,
        amount = int.tryParse(json['amount'] ?? "0") ?? 0,
        description = json['product_description'],
        _price = int.tryParse(json['product_price'] ?? "0.0") ?? 0,
        discountedPrice =
            int.tryParse(json['product_discount_price'] ?? "0.0") ?? 0,
        discountPercent = json['product_discount'],
  images = (json['product_images'] as Iterable?)?.map((e) => e.toString()).toList() ??[],
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

  bool get hasDiscount => discountPercent?.trim().isNotEmpty == true;
}

class CartItem {
  String cartId;
  ProductCart productCart;

  CartItem({required this.cartId, required this.productCart});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
      cartId: json['cart_id'], productCart: ProductCart.fromJson(json));
}

class ProductCart {
  String? productId;
  String? thumb;
  String? name;
  String? model;
  String quantity;
  bool? stock;
  int? price;
  int total;
  int views;

  ProductCart({
    this.productId,
    this.model,
    required this.quantity,
    this.stock,
    this.name,
    required this.total,
    this.thumb,
    this.price,
    this.views: 0,
  });
  factory ProductCart.fromJson(Map<String, dynamic> json) => ProductCart(
      price: int.tryParse("${json['product_price']}") ?? 0,
      productId: json['product_id'],
      thumb: json['product_image'],
      name: json['product_name'],
      model: json['model'],
      quantity: json['cart_qty'],
      stock: json['stock'],
      views: int.tryParse("${json['product_views']}") ?? 0,
      total: int.tryParse("${json['cart_total']}") ?? 0);

  int get totalQuantity => int.tryParse(quantity) ?? 0;
}
