import 'dart:convert';

import 'package:isiine/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';
import 'json/district.dart';
import 'json/user.dart';
import 'super_base.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> with Superbase {
  bool _sending = false;

  List<District> _districts = [];
  District? _district;

  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  TextEditingController _addressTwoController = new TextEditingController();
  TextEditingController _streetController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
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
            "account/registration?token=${await findToken}&district_id=${_district?.id}&customer_phone=${_phoneController.text}&customer_password=${Uri.encodeComponent(_passwordController.text)}&customer_fname=${Uri.encodeComponent(_firstNameController.text)}&customer_lname=${Uri.encodeComponent(_lastNameController.text)}&customer_email=${Uri.encodeComponent(_emailController.text)}&address_1=${Uri.encodeComponent(_addressController.text)}&address_2=${Uri.encodeComponent(_addressTwoController.text)}&street_number=${Uri.encodeComponent(_streetController.text)}",
        onEnd: () {
          setState(() {
            _sending = false;
          });
        },
        onValue: (value, string) async {
          if (value['code'] == 200) {
            var user = User.fromJson(value['customer']);
            (await prefs).setString(userKey, jsonEncode(value['customer']));
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) => MyHomePage(
                          user: user,
                          title: "China Kigali",
                        )));
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
        backgroundColor: Colors.white,
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20),
              shrinkWrap: true,
              children: <Widget>[
                Image.asset(
                  "assets/logo.jpg",
                  height: 150,
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        validator: (s) => s?.trim().isEmpty == true
                            ? "First name is required"
                            : null,
                        decoration: InputDecoration(
                            hintText: "First name",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        validator: (s) => s?.trim().isEmpty == true
                            ? "Last name is required"
                            : null,
                        decoration: InputDecoration(
                            hintText: "Last name",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                  ],
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (s) => s?.trim().isEmpty == true
                            ? "Email is required"
                            : null,
                        controller: _emailController,
                        decoration: InputDecoration(
                            hintText: "Email Address",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        validator: (s) => s?.trim().isEmpty == true
                            ? "Street is required"
                            : null,
                        controller: _streetController,
                        decoration: InputDecoration(
                            hintText: "Street Number",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (s) => s?.trim().isEmpty == true
                            ? "Address is required"
                            : null,
                        controller: _addressController,
                        decoration: InputDecoration(
                            hintText: "Address One",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        validator: (s) => s?.trim().isEmpty == true
                            ? "Address is required"
                            : null,
                        controller: _addressTwoController,
                        decoration: InputDecoration(
                            hintText: "Address Two",
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(40)),
                            fillColor: Color(0xffFDE6E6)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obSecure,
                  validator: (s) =>
                      s?.trim().isEmpty == true ? "Password is required" : null,
                  decoration: InputDecoration(
                      hintText: "Customer Password",
                      filled: true,
                      suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obSecure = !_obSecure;
                            });
                          },
                          child: Icon(Icons.remove_red_eye_rounded)),
                      prefixIcon: Icon(Icons.lock),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40)),
                      fillColor: Color(0xffFDE6E6)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obSecure2,
                  validator: (s) => s?.trim().isEmpty == true
                      ? "Confirm Password is required"
                      : s != _passwordController.text
                          ? "Password has to be the same"
                          : null,
                  decoration: InputDecoration(
                      hintText: "Confirm Password",
                      filled: true,
                      suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obSecure2 = !_obSecure2;
                            });
                          },
                          child: Icon(Icons.remove_red_eye_rounded)),
                      prefixIcon: Icon(Icons.lock),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 0),
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
                              "SIGN UP",
                              style: TextStyle(color: Colors.white),
                            ))),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Authentication()));
                  },
                  child: Text(
                    "Already have an Account ? Sign In",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xffe62e04)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 2,
                      color: Colors.grey.shade200,
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "OR",
                        style: TextStyle(
                            color: Color(0xffe62e04),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      height: 2,
                      color: Colors.grey.shade200,
                    )),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(1),
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xff02a1e2)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)))),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MyHomePage(
                                        user: null,
                                        title: "China Kigali",
                                      )));
                        },
                        child: Text(
                          "Continue as Guest",
                          style: TextStyle(color: Colors.white),
                        ))),
              ],
            ),
          ),
        ));
  }
}
