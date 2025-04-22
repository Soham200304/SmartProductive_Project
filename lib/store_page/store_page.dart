import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
    {
      "title": "Deep Flow Beats",
      "price": 3,
      "gradient": [Colors.blue, Colors.purple],
      "url":"https://res.cloudinary.com/djhtg9chy/video/upload/v1745073936/Deep_Flow_Beats_wxvdp1.m4a",
    },
    {
      "title": "Zen Harmony Waves",
      "price": 40,
      "gradient": [Colors.green, Colors.teal],
      "url":"https://res.cloudinary.com/djhtg9chy/video/upload/v1744991089/Zen_Harmony_Waves_wcikpe.m4a"
    },
    {
      "title": "Echoes of Focus",
      "price": 50,
      "gradient": [Colors.orange, Colors.red],
      "url":"https://res.cloudinary.com/djhtg9chy/video/upload/v1745073999/Echoes_of_Focus_uxxofe.m4a"
    },
    {
      "title": "Serene Mind Tones",
      "price": 60,
      "gradient": [Colors.pink, Colors.deepPurple],
      "url":"https://res.cloudinary.com/djhtg9chy/video/upload/v1745074098/Serene_Mind_Tones_dbfx2f.m4a"
    },
    {
      "title": "Neural Sync Rhythms",
      "price": 70,
      "gradient": [Colors.cyan, Colors.blue],
      "url":"https://res.cloudinary.com/djhtg9chy/video/upload/v1745074064/Neural_Sync_Rythms_wytr5v.m4a"
    },
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
          backgroundColor: Color(0xFFB9E7FB),
          title: Text("How will you get this item?"),
          content: Text("Choose your purchase method."),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _buyWithCoins(item),
                  child: Text("Coins",style: TextStyle(color: Colors.blueAccent),),
                ),
                SizedBox(width: 30,),
                ElevatedButton(
                  onPressed: () => _buyWithMoney(item),
                  child: Text("Buy for ₹20",style: TextStyle(color: Colors.blueAccent),),
                ),
              ],
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
            "coins": currentCoins - item["price"],
            "purchasedItems": FieldValue.arrayUnion([item["title"]]),
            "unlockedMusic": FieldValue.arrayUnion([item["url"]]),
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

    // Assign callbacks BEFORE payment
    razorpayService.onSuccess = () => _onPaymentSuccess(item);
    razorpayService.onFailure = () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed. Please try again.")),
      );
    };

    razorpayService.startPayment(
      productName: item["title"],
      amount: 20, // ₹20
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Redirecting to payment gateway... 💳")),
    );
  }

  void _onPaymentSuccess(Map<String, dynamic> item) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "purchasedItems": FieldValue.arrayUnion([item["title"]]),
      "unlockedMusic": FieldValue.arrayUnion([item["url"]])
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
        title: Text("Store",
        style: GoogleFonts.alike(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4FC3F7),
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
          color: Color(0xFFFFF9F2),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                    style: GoogleFonts.alike(fontSize: 18, color: Colors.white,),
                  ),
                  subtitle: Text(
                    isPurchased ? "Unlocked ✅" : "${item["price"]} Coins",
                    style: GoogleFonts.alike(fontSize: 12, color: Colors.white70,),
                  ),
                  trailing: isPurchased
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                      onPressed: () => _showPurchaseDialog(context, item),
                      child: Text("Get", style: GoogleFonts.alike(fontSize: 15, color: Colors.black,fontWeight:FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        )
      ),
    );
  }
}
