import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isiine/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';
import 'json/district.dart';
import 'json/user.dart';
import 'super_base.dart';

class EditProfile extends StatefulWidget {
  final User user;

  const EditProfile({Key? key, required this.user}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with Superbase {
  bool _sending = false;

  List<District> _districts = [];
  District? _district;

  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _addressTwoController = new TextEditingController();
  late TextEditingController _streetController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _phoneController = new TextEditingController(text: widget.user.phone);
    _firstNameController =
        new TextEditingController(text: widget.user.firstName);
    _lastNameController = new TextEditingController(text: widget.user.lastName);
    _emailController = new TextEditingController(text: widget.user.email);
    _addressController = new TextEditingController(text: widget.user.address);
    _addressTwoController =
        new TextEditingController(text: widget.user.address2);
    _streetController = new TextEditingController(text: widget.user.street);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      this.loadDistricts();
    });
  }

  var _formKey = new GlobalKey<FormState>();
  bool _obSecure = true;
  bool _obSecure2 = true;

  void loadDistricts() {
    this.ajax(
        url: "account/districts",
        onValue: (source, url) {
          setState(() {
            _districts = (source['data'] as Iterable?)
                    ?.map((e) => District.fromJson(e))
                    .toList() ??
                [];
            var where = _districts
                .where((element) => element.id == widget.user.districtId);
            _district = where.isNotEmpty ? where.first : null;
          });
        });
  }

  void register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _sending = true;
    });
    this.ajax(
        url:
            "account/update?token=${await findToken}&customer_id=${widget.user.id}&district_id=${_district?.id}&customer_phone=${_phoneController.text}&customer_fname=${Uri.encodeComponent(_firstNameController.text)}&customer_lname=${Uri.encodeComponent(_lastNameController.text)}&customer_email=${Uri.encodeComponent(_emailController.text)}&address_1=${Uri.encodeComponent(_addressController.text)}&address_2=${Uri.encodeComponent(_addressTwoController.text)}&street_number=${Uri.encodeComponent(_streetController.text)}",
        onEnd: () {
          setState(() {
            _sending = false;
          });
        },
        onValue: (value, string) async {
          print(value);
          if (value['code'] == 200) {
            var user = User.fromJson(value['customer']);
            (await prefs).setString(userKey, jsonEncode(value['customer']));
            Navigator.pop(context);
          }
          showSnack(value['message']);
        });
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
        ),
        backgroundColor: Colors.white,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                TextFormField(
                  controller: _firstNameController,
                  validator: (s) => s?.trim().isEmpty == true
                      ? "First name is required"
                      : null,
                  decoration: InputDecoration(
                      hintText: "First name",
                      filled: true,
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  validator: (s) => s?.trim().isEmpty == true
                      ? "Last name is required"
                      : null,
                  decoration: InputDecoration(
                      hintText: "Last name",
                      filled: true,
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  validator: (s) => s?.trim().isEmpty == true
                      ? "Phone number is required"
                      : null,
                  controller: _phoneController,
                  decoration: InputDecoration(
                      hintText: "Shop Phone Number",
                      filled: true,
                      prefixIcon: Icon(Icons.call),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (s) =>
                      s?.trim().isEmpty == true ? "Email is required" : null,
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "Email Address",
                      filled: true,
                      prefixIcon: Icon(Icons.email),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<District>(
                  items: _districts
                      .map((e) => DropdownMenuItem<District>(
                            child: Text(e.name),
                            value: e,
                          ))
                      .toList(),
                  validator: (s) => s == null ? "District is required" : null,
                  value: _district,
                  onChanged: (district) {
                    setState(() {
                      _district = district;
                    });
                  },
                  hint: Text("Select District"),
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (s) =>
                      s?.trim().isEmpty == true ? "Street is required" : null,
                  controller: _streetController,
                  decoration: InputDecoration(
                      hintText: "Street Number",
                      filled: true,
                      prefixIcon: Icon(Icons.add_location),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (s) =>
                      s?.trim().isEmpty == true ? "Address is required" : null,
                  controller: _addressController,
                  decoration: InputDecoration(
                      hintText: "Address One",
                      filled: true,
                      prefixIcon: Icon(Icons.add_location),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (s) =>
                      s?.trim().isEmpty == true ? "Address is required" : null,
                  controller: _addressTwoController,
                  decoration: InputDecoration(
                      hintText: "Address Two",
                      filled: true,
                      prefixIcon: Icon(Icons.add_location),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                _sending
                    ? Center(
                        child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ))
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xffe62e04)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40)))),
                            onPressed: register,
                            child: Text(
                              "EDIT PROFILE",
                              style: TextStyle(color: Colors.white),
                            ))),
              ],
            ),
          ),
        ));
  }
}
