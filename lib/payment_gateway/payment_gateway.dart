import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RazorpayService {
  late Razorpay _razorpay;

  // 🔁 Callback handlers
  Function()? onSuccess;
  Function()? onFailure;

  RazorpayService() {
    _razorpay = Razorpay();

    // 🎧 Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // 🧼 Dispose Razorpay when done
  void dispose() {
    _razorpay.clear();
  }

  // ✅ Payment Success: Trigger onSuccess() if set
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("✅ Payment Successful: ${response.paymentId}");

    if (onSuccess != null) {
      onSuccess!();
    }

    // Optional: Give coins as a bonus on payment
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "coins": FieldValue.increment(30), // 🎉 30 bonus coins
    });

    print("🎉 30 Coins added to user account!");
  }

  // ❌ Payment Failed: Trigger onFailure() if set
  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Failed: ${response.message}");

    if (onFailure != null) {
      onFailure!();
    }
  }

  // 💳 External Wallet Selected (Optional)
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("💼 External Wallet Selected: ${response.walletName}");
  }

  // 🚀 Start Payment
  void startPayment({
    required String productName,
    required int amount,
  }) {
    var options = {
      'key': 'rzp_test_EsaGO1AC9PRNbb', // 🔐 Replace with your real key in production
      'amount': amount * 100, // ₹ to paise
      'name': 'SmartProductive',
      'description': productName,
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com',
      },
      'theme': {'color': '#F37254'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("⚠️ Razorpay Error: $e");
    }
  }
}
