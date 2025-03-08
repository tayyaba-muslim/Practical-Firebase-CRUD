import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductAPI extends StatefulWidget {
  const ProductAPI({super.key});
  @override
  State<ProductAPI> createState() => _ProductAPIState();
}

class _ProductAPIState extends State<ProductAPI> {
      var medicine = FirebaseFirestore.instance.collection("medicine");
  User? user = FirebaseAuth.instance.currentUser; // Get current user

  @override
  void initState() {
    super.initState();
    _loadUser(); 
  }
getProducts()async{
  var url=Uri.parse('https://dummyjson.com/products');
  var response=await http.get(url);
  // print(response.body);
  return jsonDecode(response.body);
}

  void _loadUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }
 void _showProfileInfo() async {
 
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    
    if (userDoc.exists) {
      var userData = userDoc.data()!;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Profile Info"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User ID: ${user?.uid ?? 'N/A'}'), 
                SizedBox(height: 10),
                Text('Name: ${userData['name'] ?? 'N/A'}'),
                SizedBox(height: 10),
                Text('Email: ${userData['email'] ?? 'N/A'}'),
                 SizedBox(height: 10),
                Text('Phone: ${userData['phone'] ?? 'N/A'}'),
            
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User data not found")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar:   AppBar(
        title: Text("Products from API"),
        actions: [
          GestureDetector(
            child: Icon(Icons.add),
            onTap: () {
              Navigator.pushNamed(context, "/addmedicine");
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } else if (value == 'myProfile') {
                _showProfileInfo(); // Show profile info in a modal
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'logout', child: Text("Logout")),
              PopupMenuItem(value: 'myProfile', child: Text("myProfile")),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.account_circle, size: 28),
                  SizedBox(width: 8),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading...");
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text("No name found");
                      }
                      String userName = snapshot.data!.get('name') ?? "Unknown";
                      return Text(userName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
   body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
          future: getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // Ensuring the data is correctly cast to a Map<String, dynamic>
              var data = snapshot.data as Map<String, dynamic>;
              var products = data['products'] as List<dynamic>;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  return ListTile(
                    title: Text(product['title'].toString()),
                    subtitle: Text(product['price'].toString()),
                    leading: Image.network(product['images'][0]),
                  );
                },
              );
            } else {
              return Center(child: Text("No data available"));
            }
          },
        ),
      ),

    );
  }
}