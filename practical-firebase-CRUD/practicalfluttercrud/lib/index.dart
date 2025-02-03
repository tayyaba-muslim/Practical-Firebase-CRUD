import 'package:cloud_firestore/cloud_firestore.dart';
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
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.medical_services, size: 40),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  doc["desc"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '₹${doc["price"]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Actions for editing and deleting
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