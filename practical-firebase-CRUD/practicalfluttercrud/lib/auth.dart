import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create an account!"),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone No",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                       final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                         await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userCredential.user!.uid)
                        .set({
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'email': emailController.text,
                    });
                    print("User Account Created");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User Account Created")),
                    );
                    nameController.clear();
                    emailController.clear();
                    passwordController.clear();
                    phoneController.clear();
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("The password provided is too weak.")),
                    );
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("The account already exists for that email.")),
                    );
                    Navigator.pushNamed(context, '/login');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text("Sign Up"),
                ),
                ),
          ],
        ),
      ),
    );
  }
}

//LOGIN
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Login!"),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(

                  onPressed: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    try {
                       final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  prefs.setBool("isLoggedIn", true);
                  // prefs.setString("email", emailController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logged in as ${emailController.text}")),

                    );
                    Navigator.pushNamed(context, '/');
                    emailController.clear();
                    passwordController.clear();
                    } on FirebaseAuthException catch (e) {
                      prefs.setBool("isLoggedIn", false);

                      if (e.code == 'user-not found') {
                        print('No user found for that email');
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No user found for that email")),
                    );
                    Navigator.pushNamed(context, '/');
                      } else if (e.code == 'wrong password') {
                        print('Wrong password provided for that user');
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Wrong password provided for that user")),
                    );
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text("Sign in"),
                ),
                ),
          ],
        ),
      ),
    );
  }
}
