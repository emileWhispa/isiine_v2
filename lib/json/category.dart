class Category {
  String id;
  String category;
  String image;
  String? description;
  String? status;
  int? level;

  List<Category> subCategories = [];

  Category.fromJson(Map<String, dynamic> json)
      : id = json['category_id'],
        category = json['category_name'],
        image = json['category_image'],
        subCategories = (json['sub_categories'] as Iterable?)
                ?.map((e) => Category.fromJson(e))
                .toList() ??
            [],
        description = json['description'];
}
