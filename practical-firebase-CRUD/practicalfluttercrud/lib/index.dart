import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Mymedicine extends StatefulWidget {
  Mymedicine({super.key});

  @override
  State<Mymedicine> createState() => _MymedicineState();
}

class _MymedicineState extends State<Mymedicine> {
  var medicine = FirebaseFirestore.instance.collection("medicine").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Medicine"),
         actions:[
          GestureDetector(child:Icon(Icons.add),
          onTap:(){
            Navigator.pushNamed(context,"/addmedicine");
          })
        ]
      ),
      body: StreamBuilder(
        stream: medicine,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemBuilder: (context, index) {
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
                                  snapshot.data!.docs[index]["title"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  snapshot.data!.docs[index]["desc"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '\RS:${snapshot.data!.docs[index]["price"].toString()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.docs.length,
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
