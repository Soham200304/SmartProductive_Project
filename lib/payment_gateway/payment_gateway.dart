import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RazorpayService {
  late Razorpay _razorpay;

  RazorpayService() {
    _razorpay = Razorpay();

    // Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  void dispose() {
    _razorpay.clear(); // Cleanup Razorpay event listeners
  }

  // ✅ Handle successful payment and reward coins
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("✅ Payment Successful: ${response.paymentId}");

    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Reward 30 coins after successful payment
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "coins": FieldValue.increment(30),
    });

    print("🎉 Coins added to user account!");
  }

  // ❌ Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Failed: ${response.message}");
  }

  // 💳 Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("💼 External Wallet Selected: ${response.walletName}");
  }

  // 🚀 Start payment process
  void startPayment({required String productName, required int amount}) {
    var options = {
      'key': 'rzp_test_EsaGO1AC9PRNbb', // 🔹 Replace with your actual API Key
      'amount': amount * 100, // Convert ₹ to Paisa (₹50 = 5000)
      'name': 'SmartProductive',
      'description': productName,
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com',
      },
      'theme': {'color': '#F37254'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("⚠️ Razorpay Error: $e");
    }
  }
}