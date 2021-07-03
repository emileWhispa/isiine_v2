class Slide {
  String id;
  String name;
  String image;

  Slide.fromJson(Map<String, dynamic> map)
      : id = map['slide_id'],
        name = map['slide_name'],
        image = map['slide_url'];
}
