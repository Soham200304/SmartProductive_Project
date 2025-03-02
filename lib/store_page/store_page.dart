import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';
import 'package:smartproductive_app/payment_gateway/payment_gateway.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int userCoins = 0;
  List<String> purchasedItems = []; // Store purchased items
  RazorpayService razorpayService = RazorpayService();

  List<Map<String, dynamic>> storeItems = [
    {"title": "Deep Flow Beats", "price": 3, "gradient": [Colors.blue, Colors.purple]},
    {"title": "Zen Harmony Waves", "price": 40, "gradient": [Colors.green, Colors.teal]},
    {"title": "Echoes of Focus", "price": 50, "gradient": [Colors.orange, Colors.red]},
    {"title": "Serene Mind Tones", "price": 60, "gradient": [Colors.pink, Colors.deepPurple]},
    {"title": "Neural Sync Rhythms", "price": 70, "gradient": [Colors.cyan, Colors.blue]},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserCoins();
  }

  // Fetch user's coin balance & purchased items from Firestore
  void _fetchUserCoins() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots()
          .listen((DocumentSnapshot userDoc) {
        if (userDoc.exists && userDoc.data() != null) {
          var data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userCoins = data["coins"] ?? 0;
            purchasedItems = List<String>.from(data["purchasedItems"] ?? []);
          });
        }
      });
    } catch (e) {
      print("Error fetching coins: $e");
    }
  }


  // Show the purchase dialog
  void _showPurchaseDialog(BuildContext context, Map<String, dynamic> item) {
    if (purchasedItems.contains(item["title"])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item["title"]} is already purchased! 🎵")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("How will you get this item?"),
          content: Text("Choose your purchase method."),
          actions: [
            TextButton(
              onPressed: () => _buyWithCoins(item),
              child: Text("Pay by Coins"),
            ),
            TextButton(
              onPressed: () => _buyWithMoney(item),
              child: Text("Buy for ₹20"),
            ),
          ],
        );
      },
    );
  }

  // Handle purchasing with coins
  void _buyWithCoins(Map<String, dynamic> item) async {
    Navigator.pop(context); // Close the dialog
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (userCoins >= item["price"]) {
      DocumentReference userRef = FirebaseFirestore.instance.collection("users").doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        int currentCoins = userDoc["coins"] ?? 0;
        List<dynamic> purchased = userDoc["purchasedItems"] ?? [];

        if (currentCoins >= item["price"] && !purchased.contains(item["title"])) {
          transaction.update(userRef, {
            "coins": currentCoins - item["price"], // Firestore handles the update
            "purchasedItems": FieldValue.arrayUnion([item["title"]]), // Store purchased item
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item["title"]} unlocked! 🎶")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough coins! Earn more to unlock.")),
      );
    }
  }


  // Handle purchasing with money
  void _buyWithMoney(Map<String, dynamic> item) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Redirecting to payment gateway... 💳")),
    );

    razorpayService.startPayment(
      productName: item["title"],
      amount: 20,
    );

    // Simulating successful payment (normally done in _handlePaymentSuccess)
    Future.delayed(Duration(seconds: 3), () => _onPaymentSuccess(item));
  }

  // Handle successful Razorpay payment
  void _onPaymentSuccess(Map<String, dynamic> item) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Store purchased item in Firestore
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "purchasedItems": FieldValue.arrayUnion([item["title"]])
    });

    setState(() {
      purchasedItems.add(item["title"]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment successful! ${item["title"]} unlocked! 🎶")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Store"),
        backgroundColor: Color(0xFFB2F5B2), // Soft Green
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.coins, color: Colors.amber, size: 30),
                SizedBox(width: 8),
                Text("$userCoins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD0FFD0), Color(0xFF90EE90)],
          ),
        ),
        child: ListView.builder(
          itemCount: storeItems.length,
          itemBuilder: (context, index) {
            var item = storeItems[index];
            bool isPurchased = purchasedItems.contains(item["title"]);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item["gradient"],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  item["title"],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isPurchased ? "Unlocked ✅" : "${item["price"]} Coins",
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: isPurchased
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                    onPressed: () => _showPurchaseDialog(context, item),
                    child: Text("Get"),
                ),
              ),
            );
          },
        )
      ),
    );
  }
}
