import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Mymedicine extends StatefulWidget {
  Mymedicine({super.key});

  @override
  State<Mymedicine> createState() => _MymedicineState();
}

class _MymedicineState extends State<Mymedicine> {
  var medicine = FirebaseFirestore.instance.collection("medicine");
  //delete
void _deleteProduct(String medId) async{
  await medicine.doc(medId).delete();
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Product deleted successfully!")),
  );
}
//edit
void _editProduct(String medId, String currentTitle, String currentDesc,  double currentPrice){
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
          onPressed: ()async {
         await medicine.doc(medId).update({
          "title": titleController.text,
          "desc": descController.text,
          "price": double.parse(priceController.text),
         });
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product Updated Sucessfully!")),
         );
          },
          child: Text('Save'),
          )
      ],
    );
    }
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
        
        // Logout icon
          GestureDetector(
            child: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/Login');
            },
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