import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Mymedicine extends StatefulWidget {
  const Mymedicine({super.key});

  @override
  State<Mymedicine> createState() => _MymedicineState();
}

class _MymedicineState extends State<Mymedicine> {
  var medicine = FirebaseFirestore.instance.collection("medicine");
  User? user = FirebaseAuth.instance.currentUser; // Get current user

  @override
  void initState() {
    super.initState();
    _loadUser(); 
  }


  void _loadUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  // Show Profile 
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
                Text('Name: ${userData['name'] ?? 'N/A'}'),
                SizedBox(height: 10),
                Text('Email: ${userData['email'] ?? 'N/A'}'),
            
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

  // Delete Product
  void _deleteProduct(String medId) async {
    await medicine.doc(medId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Product deleted successfully!")),
    );
  }

  // Info Product 
  void _infoProduct(String medId, String currentTitle, String currentDesc, double currentPrice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentTitle),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: $currentDesc'),
              SizedBox(height: 10),
              Text('Price: Rs. $currentPrice'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Edit Product
  void _editProduct(String medId, String currentTitle, String currentDesc, double currentPrice) {
    TextEditingController titleController = TextEditingController(text: currentTitle);
    TextEditingController descController = TextEditingController(text: currentDesc);
    TextEditingController priceController = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await medicine.doc(medId).update({
                  "title": titleController.text,
                  "desc": descController.text,
                  "price": double.parse(priceController.text),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Product Updated Successfully!")),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Medicine"),
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
                Navigator.pushReplacementNamed(context, '/login');
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
      body: StreamBuilder(
        stream: medicine.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var medId = doc.id;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.medical_services, size: 45, color: Colors.blue),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  doc["desc"],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Rs:${doc["price"]}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.red),
                                onPressed: () {
                                  _infoProduct(medId, doc["title"], doc["desc"], doc["price"]);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editProduct(medId, doc["title"], doc["desc"], doc["price"]);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteProduct(medId);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text("No data available"));
            }
          } else {
            return Center(child: Text("Data not accessible"));
          }
        },
      ),
    );
  }
}
