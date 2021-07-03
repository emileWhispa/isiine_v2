class District {
  String id;
  String name;

  District.fromJson(Map<String, dynamic> map)
      : id = map['district_id'],
        name = map['district_name'];
}
