import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:serveapp/shared/homeScreen.dart';
import 'package:vibe_loader/loaders/neon_grid_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPaymentScreen extends StatefulWidget {
  const PaypalPaymentScreen({
    super.key,
  });

  @override
  _PaypalPaymentScreenState createState() => _PaypalPaymentScreenState();
}

class _PaypalPaymentScreenState extends State<PaypalPaymentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;

  // Sandbox Keys
  final String domain = "https://api.sandbox.paypal.com";
  final String clientId =
      'AWUAsvaO8uG1VUjJTn3wvfBOL70c07zfOWTFjPoxJ8GI5mjzUMD7KyJh9GIt3w6rChBWplh7_axlXnT_';
  final String secret =
      'ED4SSD-JSCRvWNHUlpB-zmD4vmYopxozkKKrYRG3tvB_KbLposrFXLL9eAzrDR3_s-wl-Hib9n229TG0';
  final String returnURL =
      'https://mohanbright.github.io/QuickMROPayment/handlePaymentReturn.html';
  final String cancelURL =
      'https://mohanbright.github.io/QuickMROPayment/handlePaymentCancel.html';

  // ----------------------------------------------------------------------

  //Live Keys
  // final String domain = "https://api.paypal.com";
  // final String clientId = 'AX0pRo50BLPiP4l0EQQLpsusqbnhAwCeB9yuhuF1W0ESDT5YczOyGupsmglXOJZ2ClyRl7zuIIR4m6fq';
  // final String secret = 'EP5alWZc4hFgtpQZr74wgXCDn7R38El1SfYIQfVLSMqAP6nu9Zo5eK-l9lxZjOWc202LGJCP7_aq6s1_';
  // final String returnURL = 'https://mohanbright.github.io/QuickMROPayment/handlePaymentReturn.html';
  // final String cancelURL = 'https://mohanbright.github.io/QuickMROPayment/handlePaymentCancel.html';

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    try {
      accessToken = await _getAccessToken();

      if (accessToken != null) {
        final transactions = _getOrderParams();
        final res = await _createPaypalPayment(transactions, accessToken!);

        if (res != null && mounted) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Map<String, dynamic> _getOrderParams() {
    return {
      "intent": "sale",
      "payer": {
        "payment_method": "paypal",
      },
      "transactions": [
        {
          "amount": {
            "total": "10.00", // Fixed amount
            "currency": "USD", // Currency code
          },
          "description": "Payment for services rendered."
        }
      ],
      "redirect_urls": {
        "return_url": returnURL,
        "cancel_url": cancelURL,
      },
    };
  }

  Future<String?> _getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'),
        headers: {
          'Authorization':
          'Basic ' + base64Encode(utf8.encode('$clientId:$secret')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>?> _createPaypalPayment(
      Map<String, dynamic> transactions, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse("$domain/v1/payments/payment"),
        body: jsonEncode(transactions),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].isNotEmpty) {
          List links = body["links"];
          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _executePayment(
      String url, String payerId, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({"payer_id": payerId}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Payment done successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        print('Payment successful!');

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeScreen()));
        return body["id"];
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return WebViewPayPal(
        url: checkoutUrl!,
        heading: 'PayPal Payment',
        navigationDelegate: (NavigationRequest request) {
          if (request.url.contains(returnURL)) {
            final uri = Uri.parse(request.url);
            final payerID = uri.queryParameters['PayerID'];
            if (payerID != null) {
              _executePayment(executeUrl!, payerID, accessToken!).then((id) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            } else {
              if (mounted) {
                Navigator.of(context).pop();
              }
            }
          }
          if (request.url.contains(cancelURL)) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
          return NavigationDecision.navigate;
        },
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: const Center(child: NeonGridLoader(neonColor: Colors.amber,)),
      );
    }
  }
}
class WebViewPayPal extends StatefulWidget {
  final String url;
  final String heading;
  final NavigationDecision Function(NavigationRequest request) navigationDelegate;

  const WebViewPayPal({
    Key? key,
    required this.url,
    required this.heading,
    required this.navigationDelegate,
  }) : super(key: key);

  @override
  State<WebViewPayPal> createState() => _WebViewPayPalState();
}

class _WebViewPayPalState extends State<WebViewPayPal> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: widget.navigationDelegate,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.heading,
          style:GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,

          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}