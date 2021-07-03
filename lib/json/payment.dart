class Payment {
  String id;
  String name;
  String info;

  Payment.fromJson(Map<String, dynamic> map)
      : id = map['payment_method_id'],
        name = map['payment_method_name'],
        info = map['payment_method_info'];
}
