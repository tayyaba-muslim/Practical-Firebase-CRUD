import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}


class _AddMedicineState extends State<AddMedicine> {
   final TextEditingController _medicineNameController = TextEditingController();
 final TextEditingController _medicineDescController = TextEditingController();
 final TextEditingController _medicinePriceController = TextEditingController();
  CollectionReference medicine = FirebaseFirestore.instance.collection('medicine');
  Future<void> addMedicine(){
    String medicineTitle= _medicineNameController.text;
    String desc= _medicineDescController.text;
    int price= int.parse(_medicinePriceController.text);
    medicine.add({
      'title': medicineTitle,
      'desc' : desc,
      'price': price
    });
    Navigator.pop(context);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: Text("Add Medicine"),),
      body: Center(
      child:ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _medicineNameController,
              decoration: InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder()
              ),
            ),
            ),
            Padding(padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _medicineDescController,
              decoration: InputDecoration(
                labelText: "Medicine Description",
                border: OutlineInputBorder()
              ),
            ),
            ),
               Padding(padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _medicinePriceController,
              decoration: InputDecoration(
                labelText: "Medicine Price",
                border: OutlineInputBorder()
              ),
            ),
            ),
           Padding(padding: EdgeInsets.all(8.0),
           child: ElevatedButton(onPressed: addMedicine, child: Text("Add Medince")),
           )
        ],
      )
      )
    );
  }
}