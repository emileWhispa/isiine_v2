class Vendor {
  String id;
  String name;
  String image;
  String? email;

  Vendor.fromJson(Map<String, dynamic> map)
      : id = map['vendor_id'],
        name = map['vendor_name'],
        image = map['vendor_image'],
        email = map['vendor_email'];


  Map<String, dynamic> toJson()=>{
    "vendor_id":id,
    "vendor_name":name,
    "vendor_image":image,
    "vendor_email":email
  };
}
