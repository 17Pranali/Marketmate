import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumPage extends StatefulWidget {
  final String language;
  const PremiumPage({Key? key, required this.language}) : super(key: key);

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final String upiId = 'ipranalikshirsagar@okaxis';
  final String payeeName = 'MarketMate';

  List<ApplicationMeta>? _apps;
  String? _paymentStatusMessage;

  late List<Map<String, dynamic>> plans;

  final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'premium_title': 'Premium Plans',
      'select_upi_app': 'Select UPI App',
      'subscribe': 'Subscribe',
      'payment_cancelled': 'Payment cancelled.',
      'no_upi_apps': 'No UPI apps found on device.',
      'payment_success': 'Payment Successful for',
      'payment_failed': 'Payment Failed. Please try again.',
      'payment_submitted': 'Payment Submitted. Waiting for confirmation.',
      'payment_status': 'Payment Status',
      'basic_plan': 'Basic',
      'standard_plan': 'Standard',
      'premium_plan': 'Premium',
      'duration_1_month': 'Duration: 1 month',
      'duration_6_months': 'Duration: 6 months',
      'duration_12_months': 'Duration: 12 months/1 year',
      'unlimited_messaging': 'Unlimited Messaging',
      'unlimited_post_upload': 'Unlimited Post Upload',
      'explore_waste_management': 'Explore Waste Management',
    },
    'hi': {
      'premium_title': 'प्रीमियम प्लान्स',
      'select_upi_app': 'UPI ऐप चुनें',
      'subscribe': 'सब्सक्राइब करें',
      'payment_cancelled': 'भुगतान रद्द कर दिया गया।',
      'no_upi_apps': 'डिवाइस पर कोई UPI ऐप नहीं मिला।',
      'payment_success': 'भुगतान सफल हुआ',
      'payment_failed': 'भुगतान विफल। कृपया पुनः प्रयास करें।',
      'payment_submitted': 'भुगतान सबमिट हुआ। पुष्टि की प्रतीक्षा करें।',
      'payment_status': 'भुगतान स्थिति',
      'basic_plan': 'बेसिक',
      'standard_plan': 'स्टैंडर्ड',
      'premium_plan': 'प्रीमियम',
      'duration_1_month': 'अवधि: 1 माह',
      'duration_6_months': 'अवधि: 6 माह',
      'duration_12_months': 'अवधि: 12 माह/1 वर्ष',
      'unlimited_messaging': 'असीमित मैसेजिंग',
      'unlimited_post_upload': 'असीमित पोस्ट अपलोड',
      'explore_waste_management': 'वेस्ट मैनेजमेंट एक्सप्लोर करें',
    },
    'mr': {
      'premium_title': 'प्रीमियम योजना',
      'select_upi_app': 'UPI अ‍ॅप निवडा',
      'subscribe': 'सदस्य व्हा',
      'payment_cancelled': 'पेमेंट रद्द केले.',
      'no_upi_apps': 'डिव्हाइसवर कोणतेही UPI अ‍ॅप सापडले नाही.',
      'payment_success': 'पेमेंट यशस्वी झाले',
      'payment_failed': 'पेमेंट अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
      'payment_submitted': 'पेमेंट सबमिट केले. पुष्टीची वाट पाहत आहे.',
      'payment_status': 'पेमेंट स्थिती',
      'basic_plan': 'बेसिक',
      'standard_plan': 'स्टँडर्ड',
      'premium_plan': 'प्रीमियम',
      'duration_1_month': 'कालावधी: १ महिना',
      'duration_6_months': 'कालावधी: ६ महिने',
      'duration_12_months': 'कालावधी: १२ महिने/१ वर्ष',
      'unlimited_messaging': 'अमर्यादित मेसेजिंग',
      'unlimited_post_upload': 'अमर्यादित पोस्ट अपलोड',
      'explore_waste_management': 'वेस्ट मॅनेजमेंट एक्सप्लोर करा',
    }
  };

 @override
  void initState() {
    super.initState();
    _fetchUpiApps();

    plans = [
      {
        'title': localizedStrings[widget.language]!['basic_plan'],
        'price': '99',
        'features': [
          localizedStrings[widget.language]!['duration_1_month'],
          localizedStrings[widget.language]!['unlimited_messaging'],
          localizedStrings[widget.language]!['unlimited_post_upload'],
          localizedStrings[widget.language]!['explore_waste_management'],
        ],
        'color': Colors.blue[100],
      },
      {
        'title': localizedStrings[widget.language]!['standard_plan'],
        'price': '499',
        'features': [
          localizedStrings[widget.language]!['duration_6_months'],
          localizedStrings[widget.language]!['unlimited_messaging'],
          localizedStrings[widget.language]!['unlimited_post_upload'],
          localizedStrings[widget.language]!['explore_waste_management'],
        ],
        'color': Colors.orange[100],
      },
      {
        'title': localizedStrings[widget.language]!['premium_plan'],
        'price': '999',
        'features': [
          localizedStrings[widget.language]!['duration_12_months'],
          localizedStrings[widget.language]!['unlimited_messaging'],
          localizedStrings[widget.language]!['unlimited_post_upload'],
          localizedStrings[widget.language]!['explore_waste_management'],
        ],
        'color': Colors.green[100],
      },
    ];
  }

  Future<void> _fetchUpiApps() async {
    if (Platform.isAndroid) {
      final apps = await UpiPay.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all);
      setState(() {
        _apps = apps;
      });
    }
  }

  Future<void> _startTransaction(String amount, String plan) async {
    if (_apps == null || _apps!.isEmpty) {
      setState(() {
        _paymentStatusMessage =
            localizedStrings[widget.language]!['no_upi_apps'];
      });
      return;
    }

    final selectedApp = await showModalBottomSheet<ApplicationMeta>(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(12),
          height: 250,
          child: Column(
            children: [
              Text(
                localizedStrings[widget.language]!['select_upi_app']!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  children: _apps!
                      .map((app) => InkWell(
                            onTap: () => Navigator.pop(context, app),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                app.iconImage(48),
                                SizedBox(height: 6),
                                Text(
                                  app.upiApplication.getAppName(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedApp == null) {
      setState(() {
        _paymentStatusMessage =
            localizedStrings[widget.language]!['payment_cancelled'];
      });
      return;
    }

    final transactionRef = 'TID${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await UpiPay.initiateTransaction(
        amount: amount,
        app: selectedApp.upiApplication,
        receiverName: payeeName,
        receiverUpiAddress: upiId,
        transactionRef: transactionRef,
        transactionNote: '$plan Plan Subscription',
      );

      setState(() async {
        if (response.status == 'SUCCESS') {
          _paymentStatusMessage =
              '${localizedStrings[widget.language]!['payment_success']} $plan!';

          // ✅ Update Firestore with isPremium = true
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'isPremium': true,
              'premiumPlan': plan,
              'premiumSince': FieldValue.serverTimestamp()
            });
          }
        } else if (response.status == 'FAILURE') {
          _paymentStatusMessage =
              localizedStrings[widget.language]!['payment_failed'];
        } else if (response.status == 'SUBMITTED') {
          _paymentStatusMessage =
              localizedStrings[widget.language]!['payment_submitted'];
        } else {
          _paymentStatusMessage =
              '${localizedStrings[widget.language]!['payment_status']}: ${response.status}';
        }
      });
    } catch (e) {
      setState(() {
        _paymentStatusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizedStrings[widget.language]!['premium_title']!),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (plan['color'] as Color?)!.withOpacity(0.6),
                          Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.deepPurple, size: 28),
                              SizedBox(width: 10),
                              Text(
                                plan['title'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '₹${plan['price']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...List.generate(
                            (plan['features'] as List).length,
                            (fIndex) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (plan['features'] as List)[fIndex],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _startTransaction(
                                plan['price'] as String,
                                plan['title'] as String,
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: Colors.deepPurple,
                                elevation: 6,
                              ),
                              child: Text(
                                localizedStrings[widget.language]!['subscribe']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_paymentStatusMessage != null) ...[
              SizedBox(height: 16),
              Text(
                _paymentStatusMessage!,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}