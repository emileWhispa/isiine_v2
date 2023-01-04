import 'package:isiine/json/payment.dart';
import 'package:isiine/super_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutForm extends StatefulWidget {
  @override
  _CheckoutFormState createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> with Superbase {
  bool _loading = false;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadPayments();
    });
  }

  void loadPayments() async {
    setState(() {
      _loading = true;
    });
    await this.ajax(
        url: "checkout/payment_methods",
        onValue: (source, url) {
          setState(() {
            _payments = (source['data'] as Iterable)
                .map((e) => Payment.fromJson(e))
                .toList();
          });
        });
    setState(() {
      _loading = false;
    });
  }

  bool _sending = false;

  void checkOut() async {
    if (_id == null) {
      Get.snackbar("Error", "Select payment method",
          icon: Icon(Icons.warning_amber_outlined));
      return;
    }

    setState(() {
      _sending = true;
    });
    await this.ajax(
        url:
            "checkout?token=${await findToken}&customer_id=${(await findUser)?.id}&payment_method_id=$_id&order_notes=${Uri.encodeComponent(_controller.text)}",
        onValue: (source, url) async {
          (await prefs).remove("token");
          await loadToken();

          setState(() {
            _sending = false;
          });
          Navigator.pop(context);
          Get.snackbar("Success", source['message'],
              icon: Icon(Icons.check_circle_rounded));
        },
        error: (s, v) {
          setState(() {
            _sending = false;
          });
        });
  }

  Future<void> loadToken() async {
    var _token = await findToken;
    return this.ajax(
        url:
            "token?username=isiine&key=04dfe1f6e2d25c8073dc7237150f9fb67541186b&token=${_token ?? ""}",
        server: true,
        onValue: (source, url) async {
          _token = source['token'];
          (await prefs).setString("token", _token!);
        });
  }

  String? _id;

  List<Payment> _payments = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Select Payment Method",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              child: _loading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: _payments
                          .map((e) => RadioListTile<String?>(
                                title: Text(e.name),
                                subtitle: Text(e.info),
                                onChanged: (value) {
                                  setState(() {
                                    _id = value;
                                  });
                                },
                                groupValue: _id,
                                value: e.id,
                              ))
                          .toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0).copyWith(bottom: 0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    labelText: "Order note",
                    hintText: "Order note",
                    border: OutlineInputBorder()),
                maxLines: null,
                minLines: 3,
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _sending
                      ? SizedBox(
                          height: 35,
                          width: 35,
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: checkOut, child: Text("Checkout")),
                ))
          ],
        ));
  }
}
